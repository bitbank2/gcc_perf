# SIMD (FP/Int) performance test to run on ARM Linux
COMPILER=gcc
PROCESSOR:=$(shell uname -m)
ifeq ($(PROCESSOR), armv7l)
ASMTEST=test32
CFLAGS=-c -marm -std=c99 -pedantic -fPIE -D USE_NEON -mcpu=cortex-a7 -Wall -O3 -mfloat-abi=hard -mfpu=neon
LINKFLAGS=-lm -pie
else ifeq ($(PROCESSOR), riscv64)
ASMTEST=empty
CFLAGS=-c -std=c99 -march=rv64gv -D USE_RISCV -Wall -O3
LINKFLAGS=-lm -pie
else ifeq ($(PROCESSOR), arm64)
ASMTEST=empty
CFLAGS=-c -fPIE -D USE_NEON -D NO_ASM -Wall -O3
LINKFLAGS=-lm -pie
else ifeq ($(PROCESSOR), aarch64)
ASMTEST=test64
CFLAGS=-c -fPIE -D USE_NEON -D NO_ASM -Wall -O3
LINKFLAGS=-lm -pie
else ifeq ($(PROCESSOR), arm64)
ASMTEST=test64
CFLAGS=-c -fPIE -D USE_NEON -Wall -O3
LINKFLAGS=-lm
else ifeq ($(PROCESSOR), x86_64)
CFLAGS=-c -fPIC -D USE_SSE -Wall -O3 -mavx2 -mfma
else
# must be something other than ARM/X86
$(error gcc_perf is only supported on x86 and ARMv7/ARMv8 platforms)
endif

all: gcc_perf

ifeq ($(PROCESSOR), $(filter $(PROCESSOR), x86_64 arm64))

gcc_perf: main.o
	$(COMPILER) main.o $(LINKFLAGS) -o gcc_perf

main.o: main.c
	$(COMPILER) $(CFLAGS) main.c

else

gcc_perf: main.o $(ASMTEST).o
	$(COMPILER) main.o $(ASMTEST).o $(LINKFLAGS) -o gcc_perf

main.o: main.c
	$(COMPILER) $(CFLAGS) main.c

$(ASMTEST).o: $(ASMTEST).s
	$(COMPILER) $(CFLAGS) $(ASMTEST).s

endif

clean:
	rm -rf *.o gcc_perf

