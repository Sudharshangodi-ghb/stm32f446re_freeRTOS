# === Project Settings ===
TARGET = firmware
MCU = cortex-m4
LDSCRIPT = Project/00_Demo/STM32F446RETX_FLASH.ld

# === Toolchain ===
CC = arm-none-eabi-gcc
CXX = arm-none-eabi-g++
OBJCOPY = arm-none-eabi-objcopy
SIZE = arm-none-eabi-size

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

clean:
	@rm -rf $(BUILD_DIR) *.elf *.hex *.bin

flash: $(TARGET).elf
	st-flash write $(TARGET).elf 0x8000000
