# === Project Settings ===
TARGET = firmware
MCU = cortex-m4

# === Toolchain ===
CC      = arm-none-eabi-gcc
CXX     = arm-none-eabi-g++
AS      = arm-none-eabi-as
LD      = arm-none-eabi-g++
OBJCOPY = arm-none-eabi-objcopy
SIZE    = arm-none-eabi-size

# === Directories ===
BUILD_DIR = build
SRC_DIRS = Core/Src Drivers/STM32F4xx_HAL_Driver/Src FreeRTOS/Source Src

# === Flags ===
CFLAGS   = -mcpu=$(MCU) -mthumb -Wall -O2 -ffunction-sections -fdata-sections
CXXFLAGS = $(CFLAGS) -std=c++17
ASFLAGS  = -mcpu=$(MCU) -mthumb
LDFLAGS  = -TSTM32F446RE_FLASH.ld -Wl,--gc-sections

# === Include Paths ===
INCLUDES = \
  -ICore/Inc \
  -IDrivers/CMSIS/Device/ST/STM32F4xx/Include \
  -IDrivers/CMSIS/Include \
  -IDrivers/STM32F4xx_HAL_Driver/Inc \
  -IFreeRTOS/Source/include \
  -IFreeRTOS/Source/portable/GCC/ARM_CM4F \
  -ISrc

# === Source Files (auto-detected) ===
C_SRCS   = $(foreach dir, $(SRC_DIRS), $(wildcard $(dir)/*.c))
CPP_SRCS = $(foreach dir, $(SRC_DIRS), $(wildcard $(dir)/*.cpp))
OBJS     = $(patsubst %.c, $(BUILD_DIR)/%.o, $(C_SRCS)) \
           $(patsubst %.cpp, $(BUILD_DIR)/%.o, $(CPP_SRCS))

# === Build Rules ===
all: $(TARGET).elf

$(TARGET).elf: $(OBJS)
	@echo "[LD] Linking $@"
	@$(CXX) $(CXXFLAGS) $(OBJS) -o $@ $(LDFLAGS)
	@$(SIZE) $@

# C source file compilation
$(BUILD_DIR)/%.o: %.c
	@mkdir -p $(dir $@)
	@echo "[CC] Compiling $<"
	@$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

# C++ source file compilation
$(BUILD_DIR)/%.o: %.cpp
	@mkdir -p $(dir $@)
	@echo "[C++] Compiling $<"
	@$(CXX) $(CXXFLAGS) $(INCLUDES) -c $< -o $@

clean:
	@rm -rf $(BUILD_DIR) *.elf

flash: $(TARGET).elf
	st-flash write $(TARGET).elf 0x8000000
