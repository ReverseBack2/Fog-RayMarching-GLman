#include <iostream>
#include <string>
#include <cstdlib>
#include <ctime>
#include <fstream>
#include <bits/stdc++.h>

using namespace std;

struct point {
	float *loc;
};

void printCoord(float x, float y, float z, float CS, ofstream &oF);
float genFloat( float max );


int main() {
	srand(time(0)*394852.);

	float cubeSize = 4.;

	float Xstart = 0.;
	float Xend = 64.;

	float Ystart = 0.;
	float Yend = 64.;

	float Zstart = 0.;
	float Zend = 64.;

	

	ofstream oF;
	oF.open ("cloudPoints.txt", ios::trunc);

	if (oF.is_open()) {
		cout << "File opened\n";

		oF << "{\n";

		for (float i = Xstart; i < Xend; i+=cubeSize)
		{
			for (float j = Ystart; j < Yend; j+=cubeSize)
			{
				for (float k = Zstart; k < Zend; k+=cubeSize)
				{
					printCoord( i, j, k, cubeSize, oF);
					cout << i << " " << j << " " << k << "\n";
				}
			}
		}

		oF << "}";
		

	}else{
		cout << "Error opening file\n";
	}

	oF.close();
	cout << "finsihed writing points\n";

	






}


void printCoord(float x, float y, float z, float CS, ofstream &oF) {
	oF << "\t{ " << genFloat(CS)+x << ", " << genFloat(CS)+y << ", " << genFloat(CS)+z << " },\n";
}
float genFloat( float max ) {
	float num = float(rand())/100. * 4.53632792;
	return fmod(num, max);
}


