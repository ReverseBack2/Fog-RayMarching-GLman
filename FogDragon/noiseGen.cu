#include <iostream>
#include <stdio.h>
#include <string>
#include <cstdlib>
#include <ctime>
#include <fstream>
#include <bits/stdc++.h>
#include <math.h>
#include <cuda.h>
#include <cuda_runtime_api.h>
#include <device_launch_parameters.h>

using namespace std;
///////////////////////////////////////////
// STRUCTS
///////////////////////////////////////////

//3D array of distances to points
typedef struct {
	int res;
	float*** field;
} DistanceField;

//3D array of int noise values
typedef struct {
	int res;
	float*** field;
} NoiseField;

//coord to keep track of array indexes
typedef struct {
	int x;
	int y;
	int z;
} coord;

//coord but in floats for points to calc
typedef struct {
	float* loc;
} point;

//3D array of points for noise field
typedef struct {
	int res;		// how many points in one direction
	float CS;		// side length of each point section
	point*** field;
} PointField;

//Point generation code
void printCoord(float x, float y, float z, float CS, PointField PF);
float genFloat( float max );
void genPoints ( PointField &PF );

//Noise generation code
int distVal( float dist );
__device__ void getPointfromCoord( coord ID, PointField PF, point &p );
__global__ void calcDistance( PointField PF, DistanceField* DF );
__global__ void calcNoise( DistanceField DF, NoiseField* NF );



///////////////////////////////////////////
// Main Program
///////////////////////////////////////////

int main() {
	cout << "starting\n";

	int resolution = 256;
	DistanceField* DF;
	NoiseField* NF;

	cudaMallocManaged(&DF, sizeof(DistanceField));
	cudaMallocManaged(&NF, sizeof(NoiseField));

	//allocate 3D field of distance and noise
	cudaMallocManaged(&(DF->field), resolution*sizeof(float**));
	cudaMallocManaged(&(NF->field), resolution*sizeof(float**));

	for (int i = 0; i < resolution; ++i) {
		cudaMallocManaged(&(DF->field[i]), resolution*sizeof(float*));
		cudaMallocManaged(&(NF->field[i]), resolution*sizeof(float*));

		for (int j = 0; j < resolution; ++j)
		{
			cudaMallocManaged(&(DF->field[i][j]), resolution*sizeof(float));
			cudaMallocManaged(&(NF->field[i][j]), resolution*sizeof(float));
		}
	}

	DF->res = resolution;
	NF->res = resolution;

	// create points in the field
	PointField PF;
	genPoints( PF );

	// cout << PF.field[3][13][9].loc[2] << "\n";


	//GPU code
	// setup the execution parameters:
	dim3 grid( resolution, 1, 1 );
	dim3 threads( resolution, 1, 1 );

	DF->field[32][32][64] = 15;

	// for (int i = 0; i < 32; ++i)
	// {
	// 	cout << DF->field[32][32][64+i] << "\n";
	// }

	cout << "starting distance Calc\n";

	calcDistance<<< grid, threads >>> (PF, DF); 
	cudaDeviceSynchronize();

	cout << "finsihed distance, starting noise value calc\n";

	calcNoise<<< grid, threads >>> (*DF, NF);
	cudaDeviceSynchronize();

	cudaError_t errSync  = cudaGetLastError();
	cudaError_t errAsync = cudaDeviceSynchronize();
	if (errSync != cudaSuccess) 
	  printf("\nSync kernel error: %s\n", cudaGetErrorString(errSync));
	if (errAsync != cudaSuccess)
	  printf("Async kernel error: %s\n", cudaGetErrorString(errAsync));

	cudaDeviceSynchronize();

	cout << "complete calc noise\n";

	// for (int i = 0; i < 32; ++i)
	// {
	// 	cout << DF->field[32][32][64+i] << "\n";
	// }

	// Find Stats about distance field

	float avg, max, min, count, current;
	min = 99999999.;
	max = -1;
	count = 0;

	for (int i = 0; i < 256; ++i)
	{
		for (int j = 0; j < 256; ++j)
		{
			for (int k = 0; k < 256; ++k)
			{
				current  = DF->field[i][j][k];

				avg += current;
				count++;

				if(max < current)
					max = current;
				if(min > current)
					min = current;
			}
		}
		// cout << DF->field[32][32][64+i] << "\n";
	}

	avg = avg / count;
	cout << "min :" << min << "\nmax :" << max << "\navg :" << avg << "\n";

	// Find Stats about noise field

	// float avg, max, min, count, current;
	min = 99999999.;
	max = -1;
	count = 0;

	for (int i = 0; i < 256; ++i)
	{
		for (int j = 0; j < 256; ++j)
		{
			for (int k = 0; k < 256; ++k)
			{
				current  = NF->field[i][j][k];

				avg += current;
				count++;

				if(max < current)
					max = current;
				if(min > current)
					min = current;
			}
		}
	}

	avg = avg / count;
	cout << "min :" << min << "\nmax :" << max << "\navg :" << avg << "\n";


	// write noise texture

	FILE *fp = fopen( "noise.tex", "wb" );
	if( fp == NULL )
	{
		cout << "error opening output file\n";
	}

	int clipping = 32;

	int num = NF->res - clipping;
	int numS = num - clipping;

	

	fwrite( &numS, 4, 1, fp );
	fwrite( &numS, 4, 1, fp );
	fwrite( &numS, 4, 1, fp );

	for( int p = clipping; p < num; p++ )
	{
		for( int t = clipping; t < num; t++ )
		{
			for( int s = clipping; s < num; s++ )
			{
				float red, green, blue, alpha;

				red = NF->field[p][t][s];
				green  = 0.5;
				blue = 0.5;
				alpha = 0.5;

				fwrite( &red, 4, 1, fp );
				fwrite( &green, 4, 1, fp );
				fwrite( &blue, 4, 1, fp );
				fwrite( &alpha, 4, 1, fp );
			}
		}
	}


	//free point field
	for (int i = 0; i < PF.res; ++i)
	{
		for (int j = 0; j < PF.res; ++j)
		{
			for (int k = 0; k < PF.res; ++k)
			{
				cudaFree(PF.field[i][j][k].loc);
			}
			cudaFree(PF.field[i][j]);
		}
		cudaFree(PF.field[i]);
	}
	cudaFree(PF.field);


	//free the 3D fields
	for (int i = 0; i < resolution; ++i) {
		for (int j = 0; j < resolution; ++j)
		{
			cudaFree(DF->field[i][j]);
			cudaFree(NF->field[i][j]);
		}
		cudaFree(DF->field[i]);
		cudaFree(NF->field[i]);
	}
	cudaFree(DF->field);
	cudaFree(NF->field);
}

//Point generation functions
void printCoord(float x, float y, float z, float CS, PointField PF) {
	float X = x+genFloat(CS);
	float Y = y+genFloat(CS);
	float Z = z+genFloat(CS);

	int cx = int(x/CS);
	int cy = int(y/CS);
	int cz = int(z/CS);

	//cout << X << " " << Y << " " << Z << "; " << cx << " " << cy << " " << cz << ";\n";

	PF.field[cx][cy][cz].loc[0] = X;
	PF.field[cx][cy][cz].loc[1] = Y;
	PF.field[cx][cy][cz].loc[2] = Z;

	// cout << "\t{ " << X << ", " << Y << ", " << Z << " }, ";
}

float genFloat( float max ) {
	float num = float(rand())/1000000. * 4.53632792;
	//cout << num << " ";
	return fmod(num, max);
}

void genPoints( PointField &PF ) {
	srand(time(0)*394852.);

	float cubeSize = 4.;

	float start = 0.;
	float end = 64.;

	int res = int((end-start)/cubeSize);
	PF.res = res;
	PF.CS = cubeSize;


	// PF.field = new point**[res];
	cudaMallocManaged(&(PF.field), res*sizeof(point**));
	for (float i = start; i < end; i+=cubeSize)
	{
		// PF.field[(int)(i/cubeSize)] = new point*[res];
		cudaMallocManaged(&(PF.field[(int)(i/cubeSize)]), res*sizeof(point*));
		for (float j = start; j < end; j+=cubeSize)
		{
			// PF.field[(int)(i/cubeSize)][(int)(j/cubeSize)] = new point[res];
			cudaMallocManaged(&(PF.field[(int)(i/cubeSize)][(int)(j/cubeSize)]), res*sizeof(point));
			for (float k = start; k < end; k+=cubeSize)
			{
				// PF.field[(int)(i/cubeSize)][(int)(j/cubeSize)][(int)(k/cubeSize)].loc = new float[3];
				cudaMallocManaged(&(PF.field[(int)(i/cubeSize)][(int)(j/cubeSize)][(int)(k/cubeSize)].loc), 3*sizeof(float));
				printCoord( i, j, k, cubeSize, PF);
			}
		}
	}
}

//Noise generation functions
int distVal( float dist ){
	dist = 255.*(1./dist);
	int final = (int)(dist);
	return final;
}

__device__ void getPointfromCoord( coord ID, PointField PF, point &p ) {
	int offsetX = 0;
	int offsetY = 0;
	int offsetZ = 0;

	// find offsets and tile point field
	
	if (ID.x < 0) {
		offsetX = ID.x;
		ID.x = PF.res + offsetX;
	}else if (ID.x >= PF.res) {
		offsetX = ID.x - PF.res + 1;
		ID.x = offsetX - 1;
	}
	if (ID.y < 0) {
		offsetY = ID.y;
		ID.y = PF.res + offsetY;
	}else if (ID.y >= PF.res) {
		offsetY = ID.y - PF.res + 1;
		ID.y = offsetY - 1;
	}
	if (ID.z < 0) {
		offsetZ = ID.z;
		ID.z = PF.res + offsetZ;
	}else if (ID.z >= PF.res) {
		offsetZ = ID.z - PF.res + 1;
		ID.z = offsetZ - 1;
	}

	//printf("actually access: %d, %d, %d", ID.x, ID.y, ID.z);

	//grab new points
	p.loc[0] = PF.field[ID.x][ID.y][ID.z].loc[0] + ( (float)(offsetX) * PF.CS );
	p.loc[1] = PF.field[ID.x][ID.y][ID.z].loc[1] + ( (float)(offsetY) * PF.CS );
	p.loc[2] = PF.field[ID.x][ID.y][ID.z].loc[2] + ( (float)(offsetZ) * PF.CS );

	if (offsetX < 0) {
		p.loc[0] = PF.field[ID.x][ID.y][ID.z].loc[0] - ((float)(PF.res)*PF.CS);
	}else if (offsetX >= 0) {
		p.loc[0] = PF.field[ID.x][ID.y][ID.z].loc[0] + ((float)(PF.res)*PF.CS);
	}else{
		p.loc[0] = PF.field[ID.x][ID.y][ID.z].loc[0];
	}
	if (offsetY < 0) {
		p.loc[1] = PF.field[ID.x][ID.y][ID.z].loc[1] - ((float)(PF.res)*PF.CS);
	}else if (offsetY >= 0) {
		p.loc[1] = PF.field[ID.x][ID.y][ID.z].loc[1] + ((float)(PF.res)*PF.CS);
	}else{
		p.loc[1] = PF.field[ID.x][ID.y][ID.z].loc[1];
	}
	if (offsetZ < 0) {
		p.loc[2] = PF.field[ID.x][ID.y][ID.z].loc[2] - ((float)(PF.res)*PF.CS);
	}else if (offsetZ >= 0) {
		p.loc[2] = PF.field[ID.x][ID.y][ID.z].loc[2] + ((float)(PF.res)*PF.CS);
	}else{
		p.loc[2] = PF.field[ID.x][ID.y][ID.z].loc[2];
	}

}


// (__global__ & __device__) functions to be run by GPU
// get distance from points to each point in the distance field
__global__ void calcDistance( PointField PF, DistanceField* DF ) {
	float x = 0.;
	int xCubeID = 0;
	float y = 0.;
	int yCubeID = 0;
	float z = 0.;
	int zCubeID = 0;

	// distance calc variables
	float distance = 2. * PF.CS;
	float mindistance = distance;

	point p;
	coord id;
	p.loc = new float[3];



	// point location
	// DF.field[blockID][threadID][idx]
	// X = (x coord of distance field / distance field res) * point field res * cube size

	for (int idx = 0; idx < DF->res; ++idx)
	{
		distance = 2. * PF.CS;
		mindistance = distance;

		x = ((float)(blockIdx.x) / (float)(DF->res)) * (float)(PF.res) * PF.CS;
		xCubeID = (int)( x/PF.CS );
		y = ((float)(threadIdx.x) / (float)(DF->res)) * (float)(PF.res) * PF.CS;
		yCubeID = (int)( y/PF.CS );
		z = ((float)(idx) / (float)(DF->res)) * (float)(PF.res) * PF.CS;
		zCubeID = (int)( z/PF.CS );

		//find min distance to local points in a 5x5x5 cube of points sectors
		for (int i = -2; i <= 2; ++i)
		{
			for (int j = -2; j <= 2; ++j)
			{
				for (int k = -2; k <= 2; ++k)
				{
					id.x = i + xCubeID;
					id.y = j + yCubeID;
					id.z = k + zCubeID;
					//printf("attemptting to access: %d, %d, %d -- ", id.x, id.y, id.z);
					getPointfromCoord( id, PF, p );
					// distance = pow( pow(x-p.loc[0], 2) + pow(y-p.loc[1], 2) + pow(z-p.loc[2], 2), 0.5);
					distance = pow(x-p.loc[0], 2) + pow(y-p.loc[1], 2) + pow(z-p.loc[2], 2);
					//printf("Distance: %f\n", distance);
					if ( distance < mindistance)
						mindistance = distance;
				}
			}
		}

		DF->field[blockIdx.x][threadIdx.x][idx] = distance;
	}

	delete p.loc;
}

// turn distance values into noise values
__global__ void calcNoise( DistanceField DF, NoiseField* NF ) {

	// point location
	// DF.field[blockID][threadID][idx]
	// X = (x coord of distance field / distance field res) * point field res * cube size

	float value = 0;

	float max = 18000;
	float min = 64;

	for (int idx = 0; idx < DF.res; ++idx)
	{
		value = DF.field[blockIdx.x][threadIdx.x][idx];

		value = (value - min) / (max-min); 	// (~7.0->132.0) => (~0.0->1.0)
		value = 1. - value;					// (~0.0->1.0) => (1.0->0.0)

		NF->field[blockIdx.x][threadIdx.x][idx] = value;
	}
}
