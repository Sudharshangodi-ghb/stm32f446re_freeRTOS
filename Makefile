
######################################
# Project Configuration
######################################

PROJECT_NAME := stm32f446re_freertos
BUILD_DIR := build

######################################
# Toolchain Configuration
######################################

CC := arm-none-eabi-gcc
AS := arm-none-eabi-as
CP := arm-none-eabi-objcopy
SZ := arm-none-eabi-size

CFLAGS := -mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16
CFLAGS += -Wall -fdata-sections -ffunction-sections -g -O0
CFLAGS += -DSTM32F446xx -DUSE_HAL_DRIVER

LDFLAGS := -TSTM32F446RETx_FLASH.ld -Wl,-Map=$(BUILD_DIR)/$(PROJECT_NAME).map -Wl,--gc-sections

ASFLAGS := -mcpu=cortex-m4 -mthumb

######################################
# Source and Include Directories
######################################

C_SOURCES :=  \
Core/Src/main.c \
Core/Src/stm32f4xx_it.c \
Core/Src/system_stm32f4xx.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_gpio.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_rcc.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_exti.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_flash.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_dma.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_tim.c \
Middlewares/Third_Party/FreeRTOS/Source/croutine.c \
Middlewares/Third_Party/FreeRTOS/Source/event_groups.c \
Middlewares/Third_Party/FreeRTOS/Source/list.c \
Middlewares/Third_Party/FreeRTOS/Source/queue.c \
Middlewares/Third_Party/FreeRTOS/Source/tasks.c \
Middlewares/Third_Party/FreeRTOS/Source/timers.c \
Middlewares/Third_Party/FreeRTOS/Source/portable/MemMang/heap_4.c \
Middlewares/Third_Party/FreeRTOS/Source/portable/GCC/ARM_CM4F/port.c

ASM_SOURCES := startup_stm32f446xx.s

INCLUDES :=  \
-ICore/Inc \
-IDrivers/CMSIS/Include \
-IDrivers/CMSIS/Device/ST/STM32F4xx/Include \
-IDrivers/STM32F4xx_HAL_Driver/Inc \
-IDrivers/STM32F4xx_HAL_Driver/Inc/Legacy \
-IMiddlewares/Third_Party/FreeRTOS/Source/include \
-IMiddlewares/Third_Party/FreeRTOS/Source/portable/GCC/ARM_CM4F

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
