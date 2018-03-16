#include <string.h>
#include <stdio.h>
#include <stdlib.h>

// CUDA runtime
#include <cuda_runtime.h>

// includes
#include <helper_functions.h> // helper for shared functions common to CUDA Samples
#include <helper_cuda.h>	  // helper functions for CUDA error checking and initialization

extern "C"
{
#include <cuda.h>
}
#define MEMSIZE 30

__global__ void kern_compute_string(char *res, char *a, char *b, char *c, int length)
{
	int i;
	i = blockIdx.x * blockDim.x + threadIdx.x;
	if (i < length)
	{
		res[i] = a[i] + b[i] + c[i];
	}
}

/* Function computing the final string to print */
void compute_string(char *res, char *a, char *b, char *c, int length)
{
	int i;

	for (i = 0; i < length; i++)
	{
		res[i] = a[i] + b[i] + c[i];
	}
}

extern "C" int nameOfFunction()
{

	char *res;

	char a[30] = {40, 70, 70, 70, 80, 0, 50, 80, 80, 70, 70, 0, 40, 80, 79,
				  70, 0, 40, 50, 50, 0, 70, 80, 0, 30, 50, 30, 30, 0, 0};
	char b[30] = {10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10,
				  10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 0, 0};
	char c[30] = {22, 21, 28, 28, 21, 22, 27, 21, 24, 28, 20, 22, 20, 24, 22,
				  29, 22, 21, 20, 25, 22, 25, 20, 22, 27, 25, 28, 25, 0, 0};

	res = (char *)malloc(30 * sizeof(char));

	/* This function call should be programmed in CUDA */
	/* -> need to allocate and transfer data to/from the device */
	char *d_a, *d_b, *d_c, *d_res;
	dim3 gridDim;
	gridDim.x = 8;
	dim3 blockDim;
	blockDim.x = 8;

	checkCudaErrors(cudaMalloc((void **)&d_a, MEMSIZE * sizeof(char)));
	checkCudaErrors(cudaMalloc((void **)&d_b, MEMSIZE * sizeof(char)));
	checkCudaErrors(cudaMalloc((void **)&d_c, MEMSIZE * sizeof(char)));
	checkCudaErrors(cudaMalloc((void **)&d_res, MEMSIZE * sizeof(char)));

	//initialize the device memory
	checkCudaErrors(cudaMemcpy(d_a, a, MEMSIZE,	cudaMemcpyHostToDevice));
	checkCudaErrors(cudaMemcpy(d_b, b, MEMSIZE,	cudaMemcpyHostToDevice));
	checkCudaErrors(cudaMemcpy(d_c, c, MEMSIZE,	cudaMemcpyHostToDevice));
	
	kern_compute_string<<<gridDim, blockDim>>>(d_res, d_a, d_b, d_c, MEMSIZE);
	
	checkCudaErrors(cudaMemcpy(res, d_res, MEMSIZE,	cudaMemcpyDeviceToHost));
	
	// compute_string(res, a, b, c, MEMSIZE);

	printf("%s\n", res);

	return 0;
}
