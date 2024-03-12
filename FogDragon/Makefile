all: cloudGen opml noiseGen

cloudGen: cloudGen.cpp
	g++ -std=c++11 cloudGen.cpp -o cloudGen

opml: opml.cpp
	g++ -lm -fopenmp opml.cpp -o opml

noiseGen: noiseGen.cu
	nvcc noiseGen.cu -o noiseGen