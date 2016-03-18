# SIMD (FP/Int) performance test to run on ARM Linux
PROCESSOR:=$(shell uname -m)
ifeq ($(PROCESSOR), armv7l)
COMPILER=gcc
ASMTEST=test32
CFLAGS=-c -fPIE -mcpu=cortex-a7 -Wall -O3 -mfloat-abi=hard -mfpu=neon
LINKFLAGS=-lm -pie
else ifeq ($(PROCESSOR), aarch64)
COMPILER=gcc
ASMTEST=test64
CFLAGS=-c -fPIE -Wall -O3
LINKFLAGS=-lm -pie
else
# must be X86
$(error gcc_perf is only supported on ARMv7 and ARMv8 platforms)
endif

all: gcc_perf

gcc_perf: main.o $(ASMTEST).o
	$(COMPILER) main.o $(ASMTEST).o $(LINKFLAGS) -o gcc_perf

main.o: main.c
	$(COMPILER) $(CFLAGS) main.c

$(ASMTEST).o: $(ASMTEST).s
	$(COMPILER) $(CFLAGS) $(ASMTEST).s

clean:
	rm -rf *o gcc_perf

