# OpenMP Tutorial 

Compiling the code: 

```bash 
g++ -O3 -fopenmp <example.cpp> -o <name_executable>
```

## first.cpp

When running `first.cpp` you are going to see what is a race condition. 
Uses: 
- `pragma omp parallel`
- `omp_get_thread_num()`
- `pragma omp critical`
- `pragma omp single`
- `OMP_NUM_THREADS`: You can run the test like 
```bash 
OMP_NUM_THREADS=6 ./test
```

## second.cpp 

```cpp
// Public scope 
int x; 
#pragma omp parallel 
{
    // Private scope
    int y; 

}
```