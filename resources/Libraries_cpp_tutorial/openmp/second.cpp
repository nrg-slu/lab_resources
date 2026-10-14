#include <iostream>
#include <omp.h>

using namespace std; 

int main(int argc, char *argv[]){

    cout << "TEST 1" << endl; 
    int x = 5;

    #pragma omp parallel 
    {
        int y; 
        cout << omp_get_thread_num() << "\n"; 
    }

    return 0; 
}