# Постановка задачи
Задача состоит в максимально оптимизированном распараллеливании программы 3х мерного Якоби. 
Для данного кода на C++ была написана модифицированная версия использующая CUDA и изменена оригинальная чтобы она корректно вычисляла время выполнения и возвращала последнюю матрицу.

# Сборка
```bash
make
```

# Сравнение результатов между версией на CPU и GPU
```bash
make run_compare
```
запускает обе версии с параметром L размера матрицы 256 и сравнивает через compare.cpp возвращаемые массивы

# Запуск GPU версии на Polus
```
Sender: LSF System <lsfadmin@polus-c2-ib.bmc.hpc.cs.msu.ru>
Subject: Job 1523837: <./jac3d_gpu 900> in cluster <MSUCluster> Done

Job <./jac3d_gpu 900> was submitted from host <polus-ib.bmc.hpc.cs.msu.ru> by user <edu-cmc-nvidia26-04> in cluster <MSUCluster> at Sun Apr  5 19:40:00 2026
Job was executed on host(s) <polus-c2-ib.bmc.hpc.cs.msu.ru>, in queue <short>, as user <edu-cmc-nvidia26-04> in cluster <MSUCluster> at Sun Apr  5 19:40:00 2026
</home_edu/edu-cmc-nvidia26/edu-cmc-nvidia26-04> was used as the home directory.
</home_edu/edu-cmc-nvidia26/edu-cmc-nvidia26-04/first_prac_CUDA> was used as the working directory.
Started at Sun Apr  5 19:40:00 2026
Terminated at Sun Apr  5 19:40:09 2026
Results reported at Sun Apr  5 19:40:09 2026

Your job looked like:

------------------------------------------------------------
# LSBATCH: User input
./jac3d_gpu 900
------------------------------------------------------------

Successfully completed.

Resource usage summary:

    CPU time :                                   7.36 sec.
    Max Memory :                                 5575 MB
    Average Memory :                             4181.50 MB
    Total Requested Memory :                     -
    Delta Memory :                               -
    Max Swap :                                   -
    Max Processes :                              3
    Max Threads :                                6
    Run time :                                   16 sec.
    Turnaround time :                            9 sec.

The output (if any) follows:

 IT =    1   EPS = 2.6980000e+03
 IT =    2   EPS = 1.3495000e+03
 IT =    3   EPS = 5.2458333e+02
 IT =    4   EPS = 3.3714352e+02
 IT =    5   EPS = 2.7466667e+02
 IT =    6   EPS = 2.3302469e+02
 IT =    7   EPS = 1.9677308e+02
 IT =    8   EPS = 1.6295002e+02
 IT =    9   EPS = 1.3928905e+02
 IT =   10   EPS = 1.2331360e+02
 IT =   11   EPS = 1.1221165e+02
 IT =   12   EPS = 1.0546532e+02
 IT =   13   EPS = 9.8133253e+01
 IT =   14   EPS = 9.1255019e+01
 IT =   15   EPS = 8.4403267e+01
 IT =   16   EPS = 7.8237112e+01
 IT =   17   EPS = 7.2296906e+01
 IT =   18   EPS = 6.7634362e+01
 IT =   19   EPS = 6.3714148e+01
 IT =   20   EPS = 6.0632024e+01
 Jacobi3D Benchmark Completed.
 Size            =  900 x  900 x  900
 Iterations      =                 20
 Time in seconds =               1.03
 Operation type  =     floating point
 END OF Jacobi3D Benchmark
```

