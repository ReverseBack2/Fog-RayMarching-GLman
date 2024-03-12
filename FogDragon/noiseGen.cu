#include <iostream>
#include <string>
#include <cstdlib>
#include <ctime>
#include <fstream>
#include <bits/stdc++.h>
#include <math.h>

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
	int*** field;
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
	int res;
	point*** field;
} PointField;

//Point generation code
void printCoord(float x, float y, float z, float CS, PointField PF);
float genFloat( float max );
void genPoints ( PointField &PF );

//Noise generation code
int distVal( float dist );
coord correctPoint( coord ID, int res );
__global__ void calcNoise();


int main() {
	cout << "compiles\n";

	float resolution = 256;
	DistanceField DF;
	NoiseField NF;

	//allocate 3D field of distance and noise
	cudaMallocManaged(&DF.field, resolution*sizeof(float**));
	cudaMallocManaged(&NF.field, resolution*sizeof(int**));

	for (int i = 0; i < resolution; ++i) {
		cudaMallocManaged(&DF.field[i], resolution*sizeof(float*));
		cudaMallocManaged(&NF.field[i], resolution*sizeof(int*));

		for (int j = 0; j < resolution; ++j)
		{
			cudaMallocManaged(&DF.field[i][j], resolution*sizeof(float));
			cudaMallocManaged(&NF.field[i][j], resolution*sizeof(int));
		}
	}


	// create points in the field
	PointField PF;
	genPoints( PF );

	cout << PF.field[3][13][9].loc[2] << "\n";



	//free the 3D fields
	for (int i = 0; i < resolution; ++i) {
		for (int j = 0; j < resolution; ++j)
		{
			cudaFree(DF.field[i][j]);
			cudaFree(NF.field[i][j]);
		}
		cudaFree(DF.field[i]);
		cudaFree(NF.field[i]);
	}
	cudaFree(DF.field);
	cudaFree(NF.field);
}

//Point generation functions
void printCoord(float x, float y, float z, float CS, PointField PF) {
	float X = x+genFloat(CS);
	float Y = y+genFloat(CS);
	float Z = z+genFloat(CS);

	int cx = int(x/CS);
	int cy = int(y/CS);
	int cz = int(z/CS);

	cout << X << " " << Y << " " << Z << "; " << cx << " " << cy << " " << cz << ";\n";

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


	PF.field = new point**[res];
	for (float i = start; i < end; i+=cubeSize)
	{
		PF.field[(int)(i/cubeSize)] = new point*[res];
		for (float j = start; j < end; j+=cubeSize)
		{
			PF.field[(int)(i/cubeSize)][(int)(j/cubeSize)] = new point[res];
			for (float k = start; k < end; k+=cubeSize)
			{
				PF.field[(int)(i/cubeSize)][(int)(j/cubeSize)][(int)(k/cubeSize)].loc = new float[3];
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

coord correctPoint( coord ID, int res ) {
	if (ID.x >= res)
		ID.x = 0;
	if (ID.y >= res)
		ID.y = 0;
	if (ID.z >= res)
		ID.z = 0;
	return ID;
}

// (__global__) functions to be run by GPU
__global__ void calcNoise(){


}