#include <iostream>
#include <omp.h>

using namespace std; 

int main(int argc, char *argv[]){

    cout << "TEST 1" << endl; 
    int x = 5;

    #pragma omp parallel private(x)
    {
        int y; 
        cout << omp_get_thread_num() << "\n"; 
    }

    #pragma omp master
    {
        //Here only one will work so 
        // In this case the first one 
        cout << omp_get_thread_num() << endl; 

    }


    return 0; 
}