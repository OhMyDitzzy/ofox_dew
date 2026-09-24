#
# Copyright (C) 2025 The TWRP Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

DEVICE_PATH := device/xiaomi/dew

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/aosp_base.mk)

# Configure Virtual A/B
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota.mk)

# Configure virtual_ab compression.mk
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/compression.mk)

# Configure launch_with_vendor_ramdisk.mk
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/launch_with_vendor_ramdisk.mk)

# API
PRODUCT_SHIPPING_API_LEVEL := 31
PRODUCT_TARGET_VNDK_VERSION := 35

# Enable Fuse Passthrough
PRODUCT_PROPERTY_OVERRIDES += persist.sys.fuse.passthrough.enable=true

# TWRP in Vendor Boot
PRODUCT_PROPERTY_OVERRIDES += ro.twrp.vendor_boot=true

# A/B
AB_OTA_UPDATER := true
ENABLE_VIRTUAL_AB := true
TARGET_ENFORCE_AB_OTA_PARTITION_LIST := true
AB_OTA_PARTITIONS += \
    init_boot \
    boot \
    dtbo \
    product \
    system \
    system_ext \
    system_dlkm \
    odm_dlkm \
    vbmeta \
    vbmeta_system \
    vbmeta_vendor \
    vendor \
    vendor_boot \
    vendor_dlkm

# Update engine
PRODUCT_PACKAGES_DEBUG += \
    update_engine_client

PRODUCT_PACKAGES += \
    otapreopt_script \
    cppreopts.sh \
    update_engine \
    update_verifier \
    update_engine_sideload

AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_system=true \
    POSTINSTALL_PATH_system=system/bin/otapreopt_script \
    FILESYSTEM_TYPE_system=ext4 \
    POSTINSTALL_OPTIONAL_system=true

# Dynamic
PRODUCT_USE_DYNAMIC_PARTITIONS := true

# Bootctrl
PRODUCT_PACKAGES += \
    android.hardware.boot@1.2-mtkimpl \
    android.hardware.boot@1.2-mtkimpl.recovery

PRODUCT_PACKAGES_DEBUG += \
    bootctrl

# Health
PRODUCT_PACKAGES += \
    android.hardware.health@2.1-impl \
    android.hardware.health@2.1-service

# preloader devices utils
PRODUCT_PACKAGES += \
    create_pl_dev \
    create_pl_dev.recovery

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += $(DEVICE_PATH)

# Gatekeeper / KeyMint / TEE (Microtrust "beanpod") blobs for recovery ramdisk.
# BOARD_MOVE_RECOVERY_RESOURCES_TO_VENDOR_BOOT=true means recovery/root/ is
# NOT auto-merged into the ramdisk (source.android.com: generic-boot docs) —
# it only builds vendor-ramdisk/. Each file must be listed explicitly here,
# same pattern as device/xiaomi/tornado.
#
# NOTE: the files physically staged under recovery/root/vendor/... in this
# tree are placeholders (0 bytes). Replace them with the real blobs pulled
# from the stock ROM (missi-user 16 BP2A.250605.031.A3) at the SAME paths
# before building, matching proprietary-files.txt.
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/recovery/root/debug_boot.sh:$(TARGET_COPY_OUT_RECOVERY)/root/debug_boot.sh \
    $(DEVICE_PATH)/recovery/root/init.recovery.mt6768.rc:$(TARGET_COPY_OUT_RECOVERY)/root/init.recovery.mt6768.rc \
    $(DEVICE_PATH)/recovery/root/manifest_fixed.xml:$(TARGET_COPY_OUT_RECOVERY)/root/manifest_fixed.xml \
    $(DEVICE_PATH)/recovery/root/vendor/bin/hw/android.hardware.gatekeeper-service.beanpod:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/bin/hw/android.hardware.gatekeeper-service.beanpod \
    $(DEVICE_PATH)/recovery/root/vendor/bin/hw/vendor.microtrust.hardware.thh-service:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/bin/hw/vendor.microtrust.hardware.thh-service \
    $(DEVICE_PATH)/recovery/root/vendor/bin/teei_daemon:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/bin/teei_daemon \
    $(DEVICE_PATH)/recovery/root/vendor/bin/bp_kmsetkey_ca:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/bin/bp_kmsetkey_ca \
    $(DEVICE_PATH)/recovery/root/vendor/bin/hw/android.hardware.security.keymint@3.0-service.beanpod:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/bin/hw/android.hardware.security.keymint@3.0-service.beanpod \
    $(DEVICE_PATH)/recovery/root/vendor/etc/init/android.hardware.gatekeeper-service.beanpod.rc:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/etc/init/android.hardware.gatekeeper-service.beanpod.rc \
    $(DEVICE_PATH)/recovery/root/vendor/etc/init/microtrust.bp_kmsetkey_ca.rc:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/etc/init/microtrust.bp_kmsetkey_ca.rc \
    $(DEVICE_PATH)/recovery/root/vendor/etc/init/microtrust.init_thh.rc:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/etc/init/microtrust.init_thh.rc \
    $(DEVICE_PATH)/recovery/root/vendor/etc/init/microtrust.rc:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/etc/init/microtrust.rc \
    $(DEVICE_PATH)/recovery/root/vendor/etc/init/vendor.microtrust.hardware.thh-service.rc:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/etc/init/vendor.microtrust.hardware.thh-service.rc \
    $(DEVICE_PATH)/recovery/root/vendor/etc/init/android.hardware.security.keymint-service.beanpod.rc:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/etc/init/android.hardware.security.keymint-service.beanpod.rc \
    $(DEVICE_PATH)/recovery/root/vendor/etc/vintf/manifest/android.hardware.gatekeeper-service.beanpod.xml:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/etc/vintf/manifest/android.hardware.gatekeeper-service.beanpod.xml \
    $(DEVICE_PATH)/recovery/root/vendor/etc/vintf/manifest/android.hardware.security.keymint-service.beanpod.xml:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/etc/vintf/manifest/android.hardware.security.keymint-service.beanpod.xml \
    $(DEVICE_PATH)/recovery/root/vendor/etc/vintf/manifest/android.hardware.security.secureclock-service.beanpod.xml:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/etc/vintf/manifest/android.hardware.security.secureclock-service.beanpod.xml \
    $(DEVICE_PATH)/recovery/root/vendor/etc/vintf/manifest/android.hardware.security.sharedsecret-service.beanpod.xml:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/etc/vintf/manifest/android.hardware.security.sharedsecret-service.beanpod.xml \
    $(DEVICE_PATH)/recovery/root/vendor/lib/libteei_daemon_vfs.so:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib/libteei_daemon_vfs.so \
    $(DEVICE_PATH)/recovery/root/vendor/lib/libthhclient.so:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib/libthhclient.so \
    $(DEVICE_PATH)/recovery/root/vendor/lib/hw/kmsetkey.beanpod.so:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib/hw/kmsetkey.beanpod.so \
    $(DEVICE_PATH)/recovery/root/vendor/lib64/libteei_daemon_vfs.so:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib64/libteei_daemon_vfs.so \
    $(DEVICE_PATH)/recovery/root/vendor/lib64/libTEECommon.so:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib64/libTEECommon.so \
    $(DEVICE_PATH)/recovery/root/vendor/lib64/libthhclient.so:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib64/libthhclient.so \
    $(DEVICE_PATH)/recovery/root/vendor/lib64/vendor.microtrust.hardware.thh-V1-ndk.so:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib64/vendor.microtrust.hardware.thh-V1-ndk.so \
    $(DEVICE_PATH)/recovery/root/vendor/lib64/hw/wechat.default.so:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib64/hw/wechat.default.so \
    $(DEVICE_PATH)/recovery/root/vendor/lib64/hw/kmsetkey.beanpod.so:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib64/hw/kmsetkey.beanpod.so \
    $(DEVICE_PATH)/recovery/root/vendor/lib64/lib_android_keymaster_keymint_utils.so:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib64/lib_android_keymaster_keymint_utils.so \
    $(DEVICE_PATH)/recovery/root/vendor/lib64/libcppbor.so:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib64/libcppbor.so \
    $(DEVICE_PATH)/recovery/root/vendor/lib64/libcppbor_external.so:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib64/libcppbor_external.so \
    $(DEVICE_PATH)/recovery/root/vendor/lib64/libkeymint.so:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib64/libkeymint.so \
    $(DEVICE_PATH)/recovery/root/vendor/thh/ta/0102030405060708090a0b0c0d0e0f10.ta:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/thh/ta/0102030405060708090a0b0c0d0e0f10.ta \
    $(DEVICE_PATH)/recovery/root/vendor/thh/ta/020f0000000000000000000000000000.ta:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/thh/ta/020f0000000000000000000000000000.ta \
    $(DEVICE_PATH)/recovery/root/vendor/thh/ta/06090000000000000000000000000000.ta:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/thh/ta/06090000000000000000000000000000.ta \
    $(DEVICE_PATH)/recovery/root/vendor/thh/ta/08010203000000000000000000000000.ta:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/thh/ta/08010203000000000000000000000000.ta \
    $(DEVICE_PATH)/recovery/root/vendor/thh/ta/08030000000000000000000000000000.ta:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/thh/ta/08030000000000000000000000000000.ta \
    $(DEVICE_PATH)/recovery/root/vendor/thh/ta/08110000000000000000000000000000.ta:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/thh/ta/08110000000000000000000000000000.ta \
    $(DEVICE_PATH)/recovery/root/vendor/thh/ta/123af5d1d6f5cc54f78fa19030b2e76a.ta:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/thh/ta/123af5d1d6f5cc54f78fa19030b2e76a.ta \
    $(DEVICE_PATH)/recovery/root/vendor/thh/ta/40188311faf343488db888ad39496f9a.ta:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/thh/ta/40188311faf343488db888ad39496f9a.ta \
    $(DEVICE_PATH)/recovery/root/vendor/thh/ta/4e4ad23924a442ac941eec18e072750c.ta:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/thh/ta/4e4ad23924a442ac941eec18e072750c.ta \
    $(DEVICE_PATH)/recovery/root/vendor/thh/ta/5020170115e016302017012521300000.ta:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/thh/ta/5020170115e016302017012521300000.ta \
    $(DEVICE_PATH)/recovery/root/vendor/thh/ta/511ead0a000000000000000000000000.ta:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/thh/ta/511ead0a000000000000000000000000.ta \
    $(DEVICE_PATH)/recovery/root/vendor/thh/ta/5f7a5b3b29b041bca249524a031a00e3.ta:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/thh/ta/5f7a5b3b29b041bca249524a031a00e3.ta \
    $(DEVICE_PATH)/recovery/root/vendor/thh/ta/7778c03fc30c4dd0a319ea29643d4d4b.ta:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/thh/ta/7778c03fc30c4dd0a319ea29643d4d4b.ta \
    $(DEVICE_PATH)/recovery/root/vendor/thh/ta/86f623f6a2994dfdb560ffd3e5a62c29.ta:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/thh/ta/86f623f6a2994dfdb560ffd3e5a62c29.ta \
    $(DEVICE_PATH)/recovery/root/vendor/thh/ta/8888c03fc30c4dd0a319ea29643d4d4b.ta:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/thh/ta/8888c03fc30c4dd0a319ea29643d4d4b.ta \
    $(DEVICE_PATH)/recovery/root/vendor/thh/ta/8aaaf201246000007143fe4f7c823c80.ta:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/thh/ta/8aaaf201246000007143fe4f7c823c80.ta \
    $(DEVICE_PATH)/recovery/root/vendor/thh/ta/93feffccd8ca11e796c7c7a21acb4932.ta:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/thh/ta/93feffccd8ca11e796c7c7a21acb4932.ta \
    $(DEVICE_PATH)/recovery/root/vendor/thh/ta/c09c9c5daa504b78b0e46eda61556c3a.ta:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/thh/ta/c09c9c5daa504b78b0e46eda61556c3a.ta \
    $(DEVICE_PATH)/recovery/root/vendor/thh/ta/c1882f2d885e4e13a8c8e2622461b2fa.ta:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/thh/ta/c1882f2d885e4e13a8c8e2622461b2fa.ta \
    $(DEVICE_PATH)/recovery/root/vendor/thh/ta/c2882f2d885e4e13a8c8e2622461b2ff.ta:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/thh/ta/c2882f2d885e4e13a8c8e2622461b2ff.ta \
    $(DEVICE_PATH)/recovery/root/vendor/thh/ta/d78d338b1ac349e09f65f4efe179739d.ta:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/thh/ta/d78d338b1ac349e09f65f4efe179739d.ta \
    $(DEVICE_PATH)/recovery/root/vendor/thh/ta/d91f322ad5a441d5955110eda3272fc0.ta:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/thh/ta/d91f322ad5a441d5955110eda3272fc0.ta \
    $(DEVICE_PATH)/recovery/root/vendor/thh/ta/e5140b3376fa4c63ab18062caab2fb5c.ta:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/thh/ta/e5140b3376fa4c63ab18062caab2fb5c.ta \
    $(DEVICE_PATH)/recovery/root/vendor/thh/ta/e97c270ea5c44c58bcd3384a2fa2539e.ta:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/thh/ta/e97c270ea5c44c58bcd3384a2fa2539e.ta \
    $(DEVICE_PATH)/recovery/root/vendor/thh/ta/isee_model.json:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/thh/ta/isee_model.json
