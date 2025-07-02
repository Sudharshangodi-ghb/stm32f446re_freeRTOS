
######################################
# Project Configuration
######################################

PROJECT_NAME := stm32f446re_freertos
BUILD_DIR := build

######################################
# Toolchain Configuration
######################################

#TOOLCHAIN_PATH := C:/ST/STM32CubeIDE_1.18.1/STM32CubeIDE/plugins/com.st.stm32cube.ide.mcu.externaltools.gnu-tools-for-stm32.13.3.rel1.win32_1.0.0.202411081344/tools/bin
CC := $(TOOLCHAIN_PATH)/arm-none-eabi-gcc
AS := $(TOOLCHAIN_PATH)/arm-none-eabi-as
CP := $(TOOLCHAIN_PATH)/arm-none-eabi-objcopy
SZ := $(TOOLCHAIN_PATH)/arm-none-eabi-size

CFLAGS := -mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16
CFLAGS += -Wall -fdata-sections -ffunction-sections -g -O0
CFLAGS += -DSTM32F446xx -DUSE_HAL_DRIVER

LDFLAGS := -TSTM32F446RETx_FLASH.ld -Wl,-Map=$(BUILD_DIR)/$(PROJECT_NAME).map -Wl,--gc-sections

ASFLAGS := -mcpu=cortex-m4 -mthumb

######################################
# Source and Include Auto Detection
######################################

C_SOURCES := $(shell find Core Drivers Middlewares -name *.c)
ASM_SOURCES := $(shell find Core Drivers -name *.s)

INCLUDES := $(shell find Core Drivers Middlewares -type d)
INCLUDES := $(addprefix -I, $(INCLUDES))

######################################
# Build Rules
######################################

OBJS := $(addprefix $(BUILD_DIR)/, $(C_SOURCES:.c=.o))
AS_OBJS := $(addprefix $(BUILD_DIR)/, $(ASM_SOURCES:.s=.o))

all: $(BUILD_DIR)/$(PROJECT_NAME).elf

$(BUILD_DIR)/%.o: %.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

$(BUILD_DIR)/%.o: %.s
	@mkdir -p $(dir $@)
	$(CC) $(ASFLAGS) -c $< -o $@

$(BUILD_DIR)/$(PROJECT_NAME).elf: $(OBJS) $(AS_OBJS)
	$(CC) $(CFLAGS) $(OBJS) $(AS_OBJS) -o $@ $(LDFLAGS)
	$(CP) -O ihex $@ $(BUILD_DIR)/$(PROJECT_NAME).hex
	$(CP) -O binary $@ $(BUILD_DIR)/$(PROJECT_NAME).bin
	$(SZ) $@

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all clean
