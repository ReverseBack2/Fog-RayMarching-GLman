// C++ program for the above approach 
#include <cstdio> 
#include <cstring> 
#include <iostream> 
using namespace std; 

// Creating a structure for customers 
struct Customers { 
	int ID; 
	char name[30]; 
	int age; 
}; 

// Driver Code 
int main() 
{ 
	struct Customers cs; 
	int rec_size; 
	rec_size = sizeof(struct Customers); 
	cout << "Size of record is: "
		<< rec_size << endl; 

	// Create File Pointers fp_input for 
	// text file, fp_output for output 
	// binary file 
	FILE *fp_input, *fp_output; 

	// Open input text file, output 
	// binary file. 
	// If we cannot open them, work 
	// cannot be done, so return -1 
	fp_input = fopen("custdata.txt", "r"); 

	if (fp_input == NULL) { 
		cout << "Could not open input file"
			<< endl; 
		return -1; 
	} 

	fp_output = fopen("Customerdb", "wb"); 

	if (fp_output == NULL) { 
		cout << "Could not open "
			<< "output file" << endl; 
		return -1; 
	} 

	// Read one line from input text file, 
	// into 3 variables id, n & a 
	int id, a; 
	char n[30]; 

	// Count for keeping count of total 
	// Customers Records 
	int count = 0; 
	cout << endl; 

	// Read next line from input text 
	// file until EOF is reached 
	while (!feof(fp_input)) { 

		// Reading the text file 
		fscanf(fp_input, "%d %s %d ", 
			&id, n, &a); 

		// Increment the count by one 
		// after reading a record 
		count++; 

		// Structure variable cs is set 
		// to values to elements 
		cs.ID = id, strcpy(cs.name, n), cs.age = a; 

		// Write the structure variable 
		// cs to output file 
		fwrite(&cs, rec_size, 1, fp_output); 
		printf( 
			"Customer number %2d has"
			" data %5d %30s %3d \n", 
			count, cs.ID, 
			cs.name, cs.age); 
	} 

	cout << "Data from file read"
		<< " and printed\n"; 
	cout << "Database created for "
		<< "Customers info\n"; 

	// Count contains count of total records 
	cout << "Total records written: "
		<< count << endl; 

	// Close both the files 
	fclose(fp_input); 
	fclose(fp_output); 

	return 0; 
}
