#include <stdio.h>
#include <stdlib.h>


int main(){

#ifdef _OPENMP
	printf("OpenMP version %d is supported here\n", _OPENMP);
#else
	printf("OpenMP is not supported here - sorry\n");
	exit( 0 );
#endif

}