/* Jacobi-3 program */

#include <cmath>
#include <iostream>
#include <iomanip>
#include <ctime>
#include <string>
#include <fstream>

#define Max(a, b) ((a) > (b) ? (a) : (b))

#define ITMAX 1000

int i, j, k, it;
double eps;
double MAXEPS = 0.5f;

inline int IDX(int i, int j, int k, int L)
{
    return i * L * L + j * L + k;
}

int main(int an, char **as)
{

    if (an != 2)
    {
        std::cout << "Usage: " << as[0] << " L" << std::endl;
    }

    int L = std::stoi(as[1]);

    auto A = new double[L * L * L];
    auto B = new double[L * L * L];

    clock_t startt = clock();

    for (i = 0; i < L; i++)
        for (j = 0; j < L; j++)
            for (k = 0; k < L; k++)
            {
                A[IDX(i, j, k, L)] = 0;
                if (i == 0 || j == 0 || k == 0 || i == L - 1 || j == L - 1 || k == L - 1)
                    B[IDX(i, j, k, L)] = 0;
                else
                    B[IDX(i, j, k, L)] = 4 + i + j + k;
            }

    /* iteration loop */
    for (it = 1; it <= ITMAX; it++)
    {
        eps = 0;

        for (i = 1; i < L - 1; i++)
            for (j = 1; j < L - 1; j++)
                for (k = 1; k < L - 1; k++)
                {
                    double tmp = fabs(B[IDX(i, j, k, L)] - A[IDX(i, j, k, L)]);
                    eps = Max(tmp, eps);
                    A[IDX(i, j, k, L)] = B[IDX(i, j, k, L)];
                }

        for (i = 1; i < L - 1; i++)
            for (j = 1; j < L - 1; j++)
                for (k = 1; k < L - 1; k++)
                    B[IDX(i, j, k, L)] = (A[IDX(i - 1, j, k, L)] + A[IDX(i, j - 1, k, L)] + A[IDX(i, j, k - 1, L)] + A[IDX(i, j, k + 1, L)] + A[IDX(i, j + 1, k, L)] + A[IDX(i + 1, j, k, L)]) / 6.0f;

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

    auto filename = std::string(as[0]) + "_out";
    std::ofstream out(filename, std::ios::binary);

    out.write(reinterpret_cast<const char *>(A), L*L*L*sizeof(double));
    out.close();

    delete[] A;
    delete[] B;

    return 0;
}