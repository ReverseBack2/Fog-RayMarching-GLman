#include <stdio.h>
#include <stdlib.h>
#include <omp.h>


int main(){

	omp_set_num_threads( 50 );

	int numprocs = omp_get_num_procs( );

	#pragma omp parallel for default(none)
	for( int i = 0; i < 30; i++ )
	{
		int numprocs = omp_get_num_procs( );
		printf("%d\n", i );
	}

	// printf("%d\n", numprocs );

}