# Copyright Statement:
#

LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)
WIFI_PROJ_CONFIG_FILE := $(LOCAL_PATH)/config/$(TARGET_DEVICE).config

ifeq ($(TARGET_PRODUCT), $(filter $(TARGET_PRODUCT), abc123))
WIFI_PROJ_CONFIG_FILE_2 := $(LOCAL_PATH)/config/$(TARGET_DEVICE)_dual.config
WIFI_DRIVER_MODULE_NAME_2 := wlan_mt76x8_usb
endif

local_path_full := $(shell pwd)/$(LOCAL_PATH)
wifi_module_out_path := $(ANDROID_PRODUCT_OUT)$(WIFI_DRIVER_MODULE_PATH)
wifi_module_target := $(wifi_module_out_path)
PRIVATE_DRIVER_OUT_DIR := $(ANDROID_PRODUCT_OUT)$(WIFI_DRIVER_MODULE_DIR)

#Default enable prealloc memory
CFG_MTK_PREALLOC_DRIVER := y

ifneq ($(filter abc123 abc123,$(TARGET_DEVICE)),)
MTK_STRIP_DRIVER := n
else
MTK_STRIP_DRIVER := y
endif

ifeq ($(filter abc123,$(TARGET_DEVICE)),)
MTK_DUAL_CARD_DUAL_DRIVER := n
else
MTK_DUAL_CARD_DUAL_DRIVER := y
endif

#current parameter name for target arch on VSB is $(TARGET_ARCH)
ifeq ($(TARGET_KERNEL_ARCH),)
TARGET_KERNEL_ARCH := $(TARGET_ARCH)
endif

#avoid $(KERNEL_OUT)is not defined
ifeq ($(KERNEL_OUT),)
KERNEL_OUT := $(ANDROID_PRODUCT_OUT)/obj/KERNEL_OBJ
endif

LOCAL_MODULE := $(WIFI_DRIVER_MODULE_NAME)
LOCAL_MODULE_TAGS := optional
LOCAL_ADDITIONAL_DEPENDENCIES := $(wifi_module_target)

include $(BUILD_PHONY_PACKAGE)

ifeq ($(TARGET_PRODUCT), $(filter $(TARGET_PRODUCT), abc123))
$(LOCAL_ADDITIONAL_DEPENDENCIES): wifi_usb
endif
$(LOCAL_ADDITIONAL_DEPENDENCIES): PRIVATE_DRIVER_LOCAL_DIR := $(local_path_full)
$(LOCAL_ADDITIONAL_DEPENDENCIES): PRIVATE_DRIVER_OUT := $(wifi_module_out_path)
$(LOCAL_ADDITIONAL_DEPENDENCIES): $(INSTALLED_KERNEL_TARGET)
	$(hide) rm -rf $(PRIVATE_DRIVER_OUT) $(PRIVATE_DRIVER_LOCAL_DIR)/.config
ifeq ($(CFG_MTK_PREALLOC_DRIVER), y)
	$(hide) rm -rf $(PRIVATE_DRIVER_OUT_DIR)/$(WIFI_DRIVER_MODULE_NAME)_prealloc.ko
endif
	$(hide) cp -f $(WIFI_PROJ_CONFIG_FILE) $(PRIVATE_DRIVER_LOCAL_DIR)/.config
	$(MAKE) -C $(KERNEL_OUT) M=$(PRIVATE_DRIVER_LOCAL_DIR) ARCH=$(TARGET_KERNEL_ARCH) CROSS_COMPILE=$(KERNEL_CROSS_COMPILE) CFG_MTK_PREALLOC_DRIVER=$(CFG_MTK_PREALLOC_DRIVER) modules
	$(MAKE) -C $(KERNEL_OUT) M=$(PRIVATE_DRIVER_LOCAL_DIR) ARCH=$(TARGET_KERNEL_ARCH) CROSS_COMPILE=$(KERNEL_CROSS_COMPILE) CFG_MTK_PREALLOC_DRIVER=$(CFG_MTK_PREALLOC_DRIVER) INSTALL_MOD_PATH=$(ANDROID_PRODUCT_OUT)/obj/KERNEL_OBJ modules_install
ifeq ($(MTK_STRIP_DRIVER), y)
	$(KERNEL_CROSS_COMPILE)strip -g $(PRIVATE_DRIVER_LOCAL_DIR)/$(WIFI_DRIVER_MODULE_NAME).ko
	$(KERNEL_CROSS_COMPILE)strip -g $(PRIVATE_DRIVER_LOCAL_DIR)/$(WIFI_DRIVER_MODULE_NAME)_prealloc.ko
endif
	$(hide) mkdir -p $(PRIVATE_DRIVER_OUT_DIR)
	$(hide) cp -f $(PRIVATE_DRIVER_LOCAL_DIR)/$(WIFI_DRIVER_MODULE_NAME).ko $(PRIVATE_DRIVER_OUT_DIR)
ifeq ($(CFG_MTK_PREALLOC_DRIVER), y)
	$(hide) cp -f $(PRIVATE_DRIVER_LOCAL_DIR)/$(WIFI_DRIVER_MODULE_NAME)_prealloc.ko $(PRIVATE_DRIVER_OUT_DIR)
endif
	$(MAKE) -C $(KERNEL_OUT) M=$(PRIVATE_DRIVER_LOCAL_DIR) ARCH=$(TARGET_KERNEL_ARCH) CROSS_COMPILE=$(KERNEL_CROSS_COMPILE) clean

ifeq ($(TARGET_PRODUCT), $(filter $(TARGET_PRODUCT), abc123))
wifi_usb :
ifeq ($(CFG_MTK_PREALLOC_DRIVER), y)
	$(hide) rm -rf $(PRIVATE_DRIVER_OUT_DIR)/$(WIFI_DRIVER_MODULE_NAME_2)_prealloc.ko
endif
	$(hide) cp -f $(WIFI_PROJ_CONFIG_FILE_2) $(PRIVATE_DRIVER_LOCAL_DIR)/.config
	$(MAKE) -C $(KERNEL_OUT) M=$(PRIVATE_DRIVER_LOCAL_DIR) ARCH=$(TARGET_KERNEL_ARCH) CROSS_COMPILE=$(KERNEL_CROSS_COMPILE) CFG_MTK_PREALLOC_DRIVER=$(CFG_MTK_PREALLOC_DRIVER) modules
	$(MAKE) -C $(KERNEL_OUT) M=$(PRIVATE_DRIVER_LOCAL_DIR) ARCH=$(TARGET_KERNEL_ARCH) CROSS_COMPILE=$(KERNEL_CROSS_COMPILE) CFG_MTK_PREALLOC_DRIVER=$(CFG_MTK_PREALLOC_DRIVER) INSTALL_MOD_PATH=$(ANDROID_PRODUCT_OUT)/obj/KERNEL_OBJ modules_install
ifeq ($(MTK_STRIP_DRIVER), y)
	$(KERNEL_CROSS_COMPILE)strip -g $(PRIVATE_DRIVER_LOCAL_DIR)/$(WIFI_DRIVER_MODULE_NAME_2).ko
	$(KERNEL_CROSS_COMPILE)strip -g $(PRIVATE_DRIVER_LOCAL_DIR)/$(WIFI_DRIVER_MODULE_NAME_2)_prealloc.ko
endif
	$(hide) mkdir -p $(PRIVATE_DRIVER_OUT_DIR)
	$(hide) cp -f $(PRIVATE_DRIVER_LOCAL_DIR)/$(WIFI_DRIVER_MODULE_NAME_2).ko $(PRIVATE_DRIVER_OUT_DIR)
ifeq ($(CFG_MTK_PREALLOC_DRIVER), y)
	$(hide) cp -f $(PRIVATE_DRIVER_LOCAL_DIR)/$(WIFI_DRIVER_MODULE_NAME_2)_prealloc.ko $(PRIVATE_DRIVER_OUT_DIR)
endif
endif

local_path_full :=
wifi_module_out_path :=
wifi_module_target :=
