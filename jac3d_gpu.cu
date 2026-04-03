#include <cmath>
#include <iostream>
#include <iomanip>
#include <ctime>
#include <cuda_runtime.h>
#include <thrust/device_ptr.h>
#include <thrust/extrema.h>
#include <string>
#include <fstream>

#define ITMAX 1000

__host__ __device__ inline int IDX(int i, int j, int k, int L)
{
    return i * L * L + j * L + k;
}

__global__ void initKernel(double *A, double *B, int L)
{
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    int j = blockIdx.y * blockDim.y + threadIdx.y;
    int k = blockIdx.z * blockDim.z + threadIdx.z;

    if (i >= L || j >= L || k >= L)
        return;

    int idx = IDX(i, j, k, L);
    A[idx] = 0;
    if (i == 0 || j == 0 || k == 0 || i == L - 1 || j == L - 1 || k == L - 1)
        B[idx] = 0;
    else
        B[idx] = 4 + i + j + k;
}

__global__ void copyDiffKernel(double *A, double *B, double *diff, int L)
{
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    int j = blockIdx.y * blockDim.y + threadIdx.y;
    int k = blockIdx.z * blockDim.z + threadIdx.z;

    if (i >= L || j >= L || k >= L)
        return;

    int idx = IDX(i, j, k, L);
    double tmp = fabs(B[idx] - A[idx]);
    diff[idx] = tmp;
    A[idx] = B[idx];
}

__global__ void updateKernel(double *A, double *B, int L)
{
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    int j = blockIdx.y * blockDim.y + threadIdx.y;
    int k = blockIdx.z * blockDim.z + threadIdx.z;

    if (i <= 0 || j <= 0 || k <= 0 || i >= L - 1 || j >= L - 1 || k >= L - 1)
        return;

    int idx = IDX(i, j, k, L);
    B[idx] = (A[IDX(i - 1, j, k, L)] + A[IDX(i, j - 1, k, L)] + A[IDX(i, j, k - 1, L)] +
              A[IDX(i, j, k + 1, L)] + A[IDX(i, j + 1, k, L)] + A[IDX(i + 1, j, k, L)]) /
             6.0;
}

int main(int an, char **as)
{

    if (an != 2)
    {
        std::cout << "Usage: " << as[0] << " L" << std::endl;
    }

    int L = std::stoi(as[1]);

    size_t size = L * L * L * sizeof(double);
    double *d_A, *d_B, *d_diff;

    cudaMalloc(&d_A, size);
    cudaMalloc(&d_B, size);
    cudaMalloc(&d_diff, size);

    dim3 blockSize(8, 8, 8);
    dim3 gridSize((L + 7) / 8, (L + 7) / 8, (L + 7) / 8);

    initKernel<<<gridSize, blockSize>>>(d_A, d_B, L);

    clock_t startt = clock();
    double eps = 0;
    double MAXEPS = 0.5f;

    for (int it = 1; it <= ITMAX; it++)
    {
        copyDiffKernel<<<gridSize, blockSize>>>(d_A, d_B, d_diff, L);

        thrust::device_ptr<double> d_ptr(d_diff);
        thrust::device_ptr<double> max_ptr = thrust::max_element(d_ptr, d_ptr + L * L * L);
        cudaMemcpy(&eps, thrust::raw_pointer_cast(max_ptr), sizeof(double), cudaMemcpyDeviceToHost);

        updateKernel<<<gridSize, blockSize>>>(d_A, d_B, L);

        std::cout << " IT = " << std::setw(4) << it << "   EPS = " << std::scientific << std::setprecision(7) << eps << '\n';

        if (eps < MAXEPS)
            break;
    }

    clock_t endt = clock();
    double duration_sec = (double)(endt - startt) / CLOCKS_PER_SEC;

    std::cout << " Jacobi3D Benchmark Completed." << '\n';
    std::cout << " Size            = " << std::setw(4) << L << " x " << std::setw(4) << L << " x " << std::setw(4) << L << '\n';
    std::cout << " Iterations      =       " << std::setw(12) << ITMAX << '\n';
    std::cout << " Time in seconds =       " << std::setw(12) << std::fixed << std::setprecision(2) << duration_sec << '\n';
    std::cout << " Operation type  =     floating point" << '\n';
    std::cout << " END OF Jacobi3D Benchmark" << std::endl;

    auto A = new double[size];
    cudaMemcpy(A, d_A,size,  cudaMemcpyDeviceToHost);

    auto filename = std::string(as[0]) + "_out";
    std::ofstream out(filename, std::ios::binary);
    
    out.write(reinterpret_cast<const char *>(A), size);
    out.close();

    delete[] A;

    cudaFree(d_A);
    cudaFree(d_B);
    cudaFree(d_diff);

    return 0;
}