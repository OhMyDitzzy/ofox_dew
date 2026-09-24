#
# Copyright (C) 2024-2026 The OrangeFox Recovery Project
#
# SPDX-License-Identifier: Apache-2.0
#

export TARGET_DEVICE="dew"
export FOX_TARGET_DEVICES="dew"
export TARGET_DEVICE_ALT="dew"
export OF_MAINTAINER="ditzzy_xyz"
export FOX_VARIANT="A15"
export TARGET_ARCH="arm64"

export FOX_VIRTUAL_AB_DEVICE=1
export FOX_VENDOR_BOOT_RECOVERY=1
export FOX_INSTALLER_VENDOR_BOOT_RAMDISK_INSTALL=1
export OF_DYNAMIC_FULL_SIZE=9126805504
export OF_NO_REFLASH_CURRENT_ORANGEFOX=1
export OF_NO_SPLASH_CHANGE=1

export OF_USE_LZ4_COMPRESSION=1
export FOX_REMOVE_AAPT=1
export FOX_EXCLUDE_NANO_EDITOR=1
export FOX_COMPRESS_EXECUTABLES=1
export FOX_USE_XZ_UTILS=1

export OF_SCREEN_H=2400
export OF_STATUS_H=100
export OF_STATUS_INDENT_LEFT=48
export OF_STATUS_INDENT_RIGHT=48
export OF_HIDE_NOTCH=1
export OF_CLOCK_POS=0
export OF_ALLOW_DISABLE_NAVBAR=0
export OF_USE_LOCKSCREEN_BUTTON=1

export OF_USE_GREEN_LED=0
export OF_FORCE_PREBUILT_KERNEL=1
export OF_USE_LEGACY_BATTERY_SERVICES=1
export OF_FBE_METADATA_MOUNT_IGNORE=1
# Required because manifest_fixed.xml declares a reduced target-level (6) and
# mixes HIDL (bootctrl, present via the custom HIDL bootctrl/ implementation)
# with AIDL (keymint, gatekeeper) HALs. Without this, recovery's VINTF
# compatibility check may reject the manifest. Same flag is set on tornado,
# which uses the identical manifest_fixed.xml pattern.
export OF_NO_TREBLE_COMPATIBILITY_CHECK=1

export OF_ENABLE_LPTOOLS=1
export OF_ENABLE_ALL_PARTITION_TOOLS=1
export OF_QUICK_BACKUP_LIST="/boot;/data;/super;"