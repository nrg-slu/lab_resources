#include <iostream>
#include <omp.h>

using namespace std; 

int main(int argc, char *argv[]){

    cout << "TEST 1" << endl; 

    #pragma omp parallel 
    {
        cout << omp_get_thread_num() << "\n"; 
    }

    cout << "TEST 2" << endl; 

    #pragma omp parallel 
    {
        //Only one thread at a time can run here. 
        #pragma omp critical 
        {
            cout << omp_get_thread_num() << "\n"; 
        }
    }

    cout << "TEST 3" << endl; 

    #pragma omp parallel 
    {
        //Only one thread at a time can run here. 
        #pragma omp single 
        {
            cout << omp_get_thread_num() << "\n"; 
        }
    }
    return 0; 
}