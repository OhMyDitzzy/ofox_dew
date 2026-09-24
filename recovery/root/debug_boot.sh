#!/system/bin/sh
set -x
# TWRP Debug Boot Script - adapted from tornado (heppysingh) for dew/beanpod
LOGFILE="/tmp/debug_boot.log"

log_msg() {
    echo "$1"
    echo "$1" > /dev/kmsg
}

exec > $LOGFILE 2>&1

log_msg "--- TWRP DEW DEBUG BOOT START ---"
date
id

# 0. Force SELinux Permissive and keep it that way
log_msg "Forcing SELinux Permissive..."
setenforce 0
getenforce

# 0.5 Universal Decryption: Dynamic Version Detection
log_msg "Detecting OS version for Universal Crypto..."

# Wait up to 10 seconds for /vendor/build.prop (Vendor partition mount)
V_WAIT=0
while [ ! -f /vendor/build.prop ] && [ $V_WAIT -lt 10 ]; do
    log_msg "Waiting for /vendor/build.prop... (${V_WAIT}s)"
    sleep 1
    V_WAIT=$((V_WAIT + 1))
done

if [ -f /vendor/build.prop ]; then
    OS_VER=$(grep "ro.vendor.build.version.release=" /vendor/build.prop | head -n 1 | cut -d'=' -f2)
    PATCH_LEVEL=$(grep "ro.vendor.build.security_patch=" /vendor/build.prop | head -n 1 | cut -d'=' -f2)
    SDK_VER=$(grep "ro.vendor.build.version.sdk=" /vendor/build.prop | head -n 1 | cut -d'=' -f2)
    log_msg "Detected /vendor OS version: $OS_VER, patch: $PATCH_LEVEL, sdk: $SDK_VER"

    if [ -n "$OS_VER" ]; then
        resetprop ro.build.version.release "$OS_VER"
        resetprop ro.build.version.release_or_codename "$OS_VER"
        resetprop ro.vendor.build.version.release "$OS_VER"
        resetprop ro.system.build.version.release "$OS_VER"
        resetprop ro.odm.build.version.release "$OS_VER"
        resetprop ro.product.build.version.release "$OS_VER"
        resetprop ro.system_ext.build.version.release "$OS_VER"
    fi
    if [ -n "$PATCH_LEVEL" ]; then
        resetprop ro.build.version.security_patch "$PATCH_LEVEL"
        resetprop ro.vendor.build.security_patch "$PATCH_LEVEL"
    fi
    if [ -n "$SDK_VER" ]; then
        resetprop ro.build.version.sdk "$SDK_VER"
        resetprop ro.vendor.build.version.sdk "$SDK_VER"
        resetprop ro.system.build.version.sdk "$SDK_VER"
    fi
else
    log_msg "Warning: /vendor/build.prop not found after wait. Using ramdisk defaults."
fi

# Ensure device identity properties match dew (SKU-based, see init_dew.cpp)
# NOTE: model_property_override() in libinit_dew already handles the
# p15ape/p15apg (POCO C85) vs default (REDMI 15C) split at early boot.
# This block only pins the device/board name that debug_boot.sh needs.
resetprop ro.product.device "dew"
resetprop ro.product.board "dew"

# Ensure keystore directories exist with system permissions
mkdir -p /tmp/misc/keystore
mkdir -p /tmp/keystore
chown -R system:system /tmp/misc 2>/dev/null
chmod -R 0775 /tmp/misc 2>/dev/null

# 1. Fix Block Device Paths
log_msg "Fixing block device paths..."
mkdir -p /dev/block/platform/bootdevice/by-name/
chcon u:object_r:block_device:s0 /dev/block/platform/bootdevice/by-name/ 2>/dev/null

for part in preloader_raw_a preloader_raw_b; do
    if [ ! -L /dev/block/platform/bootdevice/by-name/$part ]; then
        ln -s /dev/block/by-name/$part /dev/block/platform/bootdevice/by-name/$part 2>/dev/null
    fi
done

# 2. TEE nodes permissions (beanpod / Microtrust TEE, same node names as mitee)
log_msg "Waiting for TEE device nodes..."
TIMER=0
while [ ! -c /dev/teepriv0 ] && [ $TIMER -lt 10 ]; do
    sleep 1
    TIMER=$((TIMER + 1))
done

if [ -c /dev/teepriv0 ]; then
    log_msg "Found TEE nodes — setting perms"
    chmod 0666 /dev/teepriv0 /dev/tee0 2>/dev/null
    chown system:system /dev/teepriv0 /dev/tee0 2>/dev/null
    ls -lZ /dev/teepriv0 /dev/tee0
fi

# 3. VINTF patching (Version 4.0 compatibility)
log_msg "Applying VINTF overrides..."
if [ -d /vendor/etc/vintf ]; then
    mkdir -p /tmp/vintf
    cp -rf /vendor/etc/vintf/* /tmp/vintf/
    find /tmp/vintf -type f -name "*.xml" -exec sed -i 's/version="5.0"/version="4.0"/g' {} +
    chmod -R 755 /tmp/vintf
    chown -R system:system /tmp/vintf
    mount -o bind /tmp/vintf /vendor/etc/vintf
fi

# 4. Stop early services, signal VINTF ready
# This will trigger the TEE chain startup in init.recovery.dew.rc
log_msg "Stopping stale services, signaling VINTF ready..."
stop keystore2
stop gatekeeper-beanpod
stop keymint-beanpod
stop thh-service
setprop twrp.vintf.ready 1

# 5. Wait for keymint AIDL to register, then start keystore2
log_msg "Waiting for keymint AIDL registration..."
WAIT=0
while [ $WAIT -lt 30 ]; do
    if service list 2>/dev/null | grep -q "IKeyMintDevice"; then
        log_msg "keymint AIDL registered after ${WAIT}s"
        break
    fi
    sleep 1
    WAIT=$((WAIT + 1))
done

# Start keystore2 - it will use /tmp/misc/keystore (standard TWRP staging)
log_msg "Starting keystore2..."
start keystore2

# 6. Diagnostics
log_msg "--- DIAGNOSTICS ---"
getprop | grep -E 'init.svc.(tee|keystore|keymint|gatekeeper|thh)|twrp|vintf|vold'

log_msg "--- DEW DEBUG BOOT SYNC END (Loop continuing in background) ---"

# 7. Persistence loop — restart security daemons if they die
while true; do
    STATUS=$(getprop init.svc.keymint-beanpod)
    if [ "$STATUS" != "running" ]; then
        log_msg "RECOVERY: keymint-beanpod status is $STATUS, restarting..."
        start keymint-beanpod
    fi

    STATUS=$(getprop init.svc.gatekeeper-beanpod)
    if [ "$STATUS" != "running" ]; then
        log_msg "RECOVERY: gatekeeper-beanpod status is $STATUS, restarting..."
        start gatekeeper-beanpod
    fi

    STATUS=$(getprop init.svc.thh-service)
    if [ "$STATUS" != "running" ]; then
        log_msg "RECOVERY: thh-service status is $STATUS, restarting..."
        start thh-service
    fi

    setenforce 0 2>/dev/null
    sleep 30
done
