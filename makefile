NVCC = nvcc
GXX = g++

ARCH = -arch=sm_60

NVCC_FLAGS = $(ARCH) -std=c++11 -O3 -Xcompiler=-Wall,-Wextra,-Wshadow,-Werror
GXX_FLAGS = -std=c++11 -O3 -Wall -Wextra -Wpedantic -Wshadow -Werror

all: jac3d_cpu jac3d_gpu compare

jac3d_gpu: jac3d_gpu.cu
	$(NVCC) $(NVCC_FLAGS) $< -o $@ 

jac3d_cpu: jac3d_cpu.cpp
	$(GXX) $(GXX_FLAGS) $< -o $@ -lm

compare: compare.cpp
	$(GXX) $(GXX_FLAGS) $< -o $@


clean:
	rm -f jac3d_cpu jac3d_gpu compare *_out

run_compare: all
	./jac3d_cpu 256
	./jac3d_gpu 256
	./compare 256 jac3d_cpu_out jac3d_gpu_out

