# === Project Settings ===
TARGET = firmware
MCU = cortex-m4
LDSCRIPT = 00_Demo/STM32F446RETX_FLASH.ld

# === Toolchain ===
CC = "C:\ST\STM32CubeIDE_1.18.1\STM32CubeIDE\plugins\com.st.stm32cube.ide.mcu.externaltools.gnu-tools-for-stm32.13.3.rel1.win32_1.0.0.202411081344\tools\bin\arm-none-eabi-gcc"
CXX = "C:\ST\STM32CubeIDE_1.18.1\STM32CubeIDE\plugins\com.st.stm32cube.ide.mcu.externaltools.gnu-tools-for-stm32.13.3.rel1.win32_1.0.0.202411081344\tools\bin\arm-none-eabi-g++.exe"
OBJCOPY = "C:\ST\STM32CubeIDE_1.18.1\STM32CubeIDE\plugins\com.st.stm32cube.ide.mcu.externaltools.gnu-tools-for-stm32.13.3.rel1.win32_1.0.0.202411081344\tools\bin\arm-none-eabi-objcopy.exe"
SIZE = "C:\ST\STM32CubeIDE_1.18.1\STM32CubeIDE\plugins\com.st.stm32cube.ide.mcu.externaltools.gnu-tools-for-stm32.13.3.rel1.win32_1.0.0.202411081344\tools\bin\arm-none-eabi-size.exe"

# === Directories ===
BUILD_DIR = build
SRC_DIRS = \
  Project/00_Demo/Core/Src \
  Project/00_Demo/Drivers \
  Project/00_Demo/Middlewares

# === Compiler Flags ===
CFLAGS   = -mcpu=$(MCU) -mthumb -Wall -O2 -ffunction-sections -fdata-sections
CXXFLAGS = $(CFLAGS) -std=c++17
LDFLAGS  = -T$(LDSCRIPT) -Wl,--gc-sections

# === Include Paths ===
INCLUDES = $(foreach dir, $(SRC_DIRS), -I$(dir))

# === Source Files (auto-detect) ===
C_SRCS   = $(foreach dir, $(SRC_DIRS), $(wildcard $(dir)/*.c))
CPP_SRCS = $(foreach dir, $(SRC_DIRS), $(wildcard $(dir)/*.cpp))
# Add assembler (.s) files
S_SRCS = $(shell find $(SRC_ROOT) -name 'startup_stm32f446xx.s')
OBJS += $(patsubst %.s, $(BUILD_DIR)/%.o, $(S_SRCS))
OBJS     = $(patsubst %.c, $(BUILD_DIR)/%.o, $(C_SRCS)) \
           $(patsubst %.cpp, $(BUILD_DIR)/%.o, $(CPP_SRCS))

# === Rules ===
all: $(TARGET).elf

$(TARGET).elf: $(OBJS)
	@echo "[LD] Linking $@"
	@$(CXX) $(CXXFLAGS) $(OBJS) -o $@ $(LDFLAGS)
	@$(SIZE) $@

$(BUILD_DIR)/%.o: %.c
	@mkdir -p $(dir $@)
	@echo "[CC] $<"
	@$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

$(BUILD_DIR)/%.o: %.cpp
	@mkdir -p $(dir $@)
	@echo "[C++] $<"
	@$(CXX) $(CXXFLAGS) $(INCLUDES) -c $< -o $@
	
$(BUILD_DIR)/%.o: %.s
	@mkdir -p $(dir $@)
	@echo "[ASM] $<"
	@$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@


clean:
	@rm -rf $(BUILD_DIR) *.elf *.hex *.bin

flash: $(TARGET).elf
	st-flash write $(TARGET).elf 0x8000000
