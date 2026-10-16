#include <iostream>
#include <omp.h>
#include <math.h> 
#include <string>

using namespace std; 
//Integrate from 0 to 1 
// sin(pix) = 2/pi


int main(int argc, char* argv[]){

    int N = stoi(argv[1]); 
    double PI = 3.141592653589; 
    double sum = 0; 
    double start = omp_get_wtime(); 
    #pragma omp parallel 
    {
        #pragma omp for reduction(+:sum)
        for (int m=0; m<N-1; m++)
        {
            sum += sin(PI*double(m)/N); 
        }
    }   

    cout.precision(15); 
    cout << "Answer: " << PI*sum/N << endl; 
    double end = omp_get_wtime(); 
    cout << "Time needed: " << end-start << endl; 
}
