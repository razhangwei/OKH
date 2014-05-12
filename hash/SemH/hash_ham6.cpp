#include <mex.h>
#include <stdio.h>
#include <math.h>

#define HASH_PRIME     805306457 // for 30 bit table (see hash_primes.txt for other suitable values)

#define TABLE_BITS     30 // Number of bits in table.

//#define HASH_PRIME     786433
//#define TABLE_BITS     20

#define MAX_RETURN     1000 // Max. number of neighbors returned.
/* Input Arguments */
#define	MAT      prhs[0] // Uint8 vector of size n x m - matrix of training data
#define HAM_RAD       prhs[1] // Uint8 integer of hamming distance to search

/* Output Arguments */
#define	OUTPUT	plhs[0] // Double vector p x MAX_RETURN, list of all  binary hamming distance to the p test cases

 
typedef struct ns {
        int data;
        unsigned long long key;
        struct ns *next;
} node;
 
node *list_add(node **p, node*n,  int i, unsigned long long j) {
    /* some compilers don't require a cast of return value for malloc */
    //node *n = (node *)mxMalloc(sizeof(node));
  
  // mexPrintf("Existing pointer: %p, new pointer: %p, new value: %d\n",*p,n,i);
    if ((n) == NULL)
        return NULL;
    (n)->next = *p;                                                                            
    *p = (n);
    (n)->data = i;
    (n)->key = j;
    return (n);
}
 
node* list_remove(node **p) { /* remove head */
    if (*p != NULL) {
        node *n = *p;
        *p = (*p)->next;
        mxFree(n);
    }
    return *p;
}
 
unsigned long long node_key(node *n) {
  return n->key;
}
 
node **list_search(node **n, int i) {
    while (*n != NULL) {
        if ((*n)->data == i) {
            return n;
        }
        n = &(*n)->next;
    }
    return NULL;
}
 
void list_print(node *n) {
    if (n == NULL) {
        printf("list is empty\n");
    }
    while (n != NULL) {
      printf("print %p %p %d %llu\n", n, n->next, n->data, n->key);
        n = n->next;
    }
}
 
int list_copy(node *n, int** output, int offset, int limit) {
  int i=0;
    if (n == NULL) {
        printf("list is empty\n");
    }
    while ((n != NULL)  && (i<limit)){
      //printf("print %p %p %d\n", n, n->next, n->data);
      //  mexPrintf("Index: %d, pointer: %p\n",i,(*output+offset+i));
	*(*output+offset+i) = (n->data)+1;  // 1 based indexing
	//	mexPrintf("Index: %d, pointer: %p, value: %d, correct value: %d\n",i,(*output+offset+i),*(*output+offset+i),(n->data)+1);
	i++;
	n = n->next;
    }
   
    return i; 
}
 

static int initialized = 0;
static node* linked_list_nodes=NULL;
static node** pHashTable=NULL;
static unsigned long long* xor_vectors=NULL;
static int num_xor_vectors = 0;

void cleanup(void) {
    mexPrintf("MEX-file is terminating\nDestroying linked-list nodes...");
    mxFree(linked_list_nodes);
    mexPrintf("done\nDestroying hash table...");
    mxFree(xor_vectors);
    mxFree(pHashTable);
    mexPrintf("done\n");
}

void mexFunction( int nlhs, mxArray *plhs[], 
		  int nrhs, const mxArray*prhs[] )
     
{ 
  int nBytes, nTrain, nTest, i, j, k, l, found, tally, offset, limit, ham_dist, max_xor_vectors;
  unsigned long hash_table_size, hash_key, nNodes;
  unsigned long long big_hash_key, xor_vec,  xor_vec2,  xor_vec3,  xor_vec4, new_hash_key, new_hash_key2, xor_vec_max, tmp;
  int *outputp, *outputp_base;
  unsigned char *pMat;
  double *pHam_Radius;
  unsigned long long byte_offset[8];

  byte_offset[0] = 1;
  byte_offset[1] = 256;
  byte_offset[2] = 65536;
  byte_offset[3] = 16777216;
  byte_offset[4] = 4294967296;
  byte_offset[5] = 1099511627776;
  byte_offset[6] = 281474976710656;
  byte_offset[7] = 72057594037927936;
 
  if (!initialized) {
    // Training phase
   
    /* Check for proper number of arguments */
    
    if (nrhs != 2) { 
      mexErrMsgTxt("Hash table creation - two arguments required."); 
    } else if (nlhs != 1) {
      mexErrMsgTxt("Hash table creation - one output argument rqeuired."); 
    } 

    if (!mxIsUint8(MAT))
      mexErrMsgTxt("Train matrix must be uInt8");

  /* Get dimensions of image and kernel */
    nBytes = (int)  mxGetM(MAT); 
    nTrain = (int)  mxGetN(MAT); 
    
    
    mexPrintf("Creating hash table....\n");
    mexPrintf("Bytes: %d Bits: %d  Train vectors: %d\n",nBytes,TABLE_BITS,nTrain);
    
    //if (nBytes>(1+ceil(TABLE_BITS/8)))
    //  mexErrMsgTxt("Too many bits -- please reduce or alter hard-coded limit and recompile");
    
    OUTPUT = mxCreateNumericMatrix(1,1,mxINT32_CLASS,mxREAL);
    outputp = (int*) mxGetPr(OUTPUT);

    // Get radius
    pHam_Radius = mxGetPr(HAM_RAD);
    ham_dist = (int) round(pHam_Radius[0]);
    max_xor_vectors = (int) round(pow(nBytes*8,pHam_Radius[0]));
    // allocate memory
    mexPrintf("Hamming distance: %d, created space for %d xor vectors\n",ham_dist,max_xor_vectors);
    xor_vectors =  (unsigned long long*) mxCalloc(max_xor_vectors+1, sizeof(unsigned long long));


    // Create pointer array
    hash_table_size = (0x1 << TABLE_BITS); // can reduce to HASH_PRIME, I think.
    pHashTable = (node**) mxCalloc(hash_table_size, sizeof(node*));
    mexPrintf("Created hash table pointers (%u of them), each %d bytes\n",hash_table_size,sizeof(node*));
  
    // Create linked_list array
    linked_list_nodes = (node*) mxCalloc(nTrain, sizeof(node));
    mexPrintf("Create linked list pointers (%d of them), each %d bytes\n",nTrain,sizeof(node));

    // Make persistent 
    mexMakeMemoryPersistent(pHashTable);
    mexMakeMemoryPersistent(linked_list_nodes);
    mexMakeMemoryPersistent(xor_vectors);


    pMat = (unsigned char*) mxGetPr(MAT);
    nNodes = 0;

       
    for (i=0;i<nTrain;i++){
      
      big_hash_key = 0;
      
      for (j=0;j<nBytes;j++)
	big_hash_key += ( pMat[i*nBytes+j] * byte_offset[j] );
      
      // Now reduce to fit in table of 2^TABLE_BITS
      hash_key = big_hash_key % HASH_PRIME;

      k=15;
      while ( (pHashTable[hash_key]!=NULL) && (node_key(pHashTable[hash_key])!=big_hash_key) ){
	//mexPrintf("i: %d Big hash key: %llu, hash_key: %lu, offset: %llu, k: %d\n",i,big_hash_key,hash_key,node_key(pHashTable[hash_key]),k);
	hash_key = (big_hash_key+k) % HASH_PRIME;
	//mexPrintf("new hash key: %llu\n",hash_key);
	//mexPrintf("%d\n",k);
	k += k;
      }

      //mexPrintf("Big hash key: %llu, hash_key: %lu\n",big_hash_key,hash_key);

      // Empty, so add in entry
      pHashTable[hash_key] = list_add(&pHashTable[hash_key],&linked_list_nodes[nNodes], i, big_hash_key);
      //mexPrintf("Added element to list\n");
      //list_print(pHashTable[hash_key]);
	
      nNodes++;
      
    }
    
    mexPrintf("Hash table successfully built, %d occupied bins using %d training examples\n",nNodes,nTrain);
 
    // Create xor vectors for hamming ball
    num_xor_vectors = 1;
    xor_vectors[0] = 0;

    if (ham_dist==1){
      xor_vec = 0x1;
      for (i=0;i<=((nBytes*8)-1);i++){
	xor_vectors[num_xor_vectors] = xor_vec;
	num_xor_vectors++;
	//	mexPrintf("Vector: %llu, nBits: %d, accum: %d\n",xor_vec,i,num_xor_vectors);
	xor_vec += xor_vec;
      }
    }
    else if (ham_dist==2){
      
     xor_vec = 0x1;
     for (i=0;i<=((nBytes*8)-1);i++){
       xor_vec2 = 0x1;
       for (j=0;j<=((nBytes*8)-1);j++){
	 xor_vectors[num_xor_vectors] = xor_vec + xor_vec2;
	 num_xor_vectors++;
	 //	 mexPrintf("Vector: %llu, nBits: %d, accum: %d\n",xor_vec+xor_vec2,i,num_xor_vectors);
	 xor_vec2 += xor_vec2;
       }
       xor_vec += xor_vec;
      
     }
 
    }
    else if (ham_dist==3){
      
     xor_vec = 0x1;
     for (i=0;i<=((nBytes*8)-1);i++){
       xor_vec2 = 0x1;
       for (j=0;j<=((nBytes*8)-1);j++){
	 xor_vec3 = 0x1;
	 for (k=0;k<=((nBytes*8)-1);k++){
	   xor_vectors[num_xor_vectors] = xor_vec + xor_vec2 + xor_vec3;
	   num_xor_vectors++;
	   //	 mexPrintf("Vector: %llu, nBits: %d, accum: %d\n",xor_vec+xor_vec2,i,num_xor_vectors);
	   xor_vec3 += xor_vec3;
	 }
	 xor_vec2 += xor_vec2;
       } 
       xor_vec += xor_vec;
     }
 
    }
    else{
    }


    // Resize
    xor_vectors = (unsigned long long*) mxRealloc(xor_vectors,num_xor_vectors*sizeof(unsigned long long));
    mexPrintf("Pre-computed all %d xor vectors\n\n",num_xor_vectors);

    // Sanity check
    //for (xor_vec=0; xor_vec<num_xor_vectors; xor_vec++){
    //  mexPrintf("Vector: %d, xor_vector: %llu\n",xor_vec,xor_vectors[xor_vec]);
    //}


    // Setup clean-up routine
    mexAtExit(cleanup);
    // Set initialized flag
    initialized = 1;
    // Set output
    outputp[0]=1;

  }
  else{ 

    /* Check for proper number of arguments */
    
    if (nrhs != 1) { 
      mexErrMsgTxt("Hash table use - one argument required."); 
    } else if (nlhs != 1) {
      mexErrMsgTxt("Hash table use- one output argument rqeuired."); 
    } 

    if (!mxIsUint8(MAT))
      mexErrMsgTxt("Test matrix must be uInt8");

    /* Get dimensions of image and kernel */
    nBytes = (int)  mxGetM(MAT); 
    nTest = (int)  mxGetN(MAT); 
        
    // Check to see if hash table exist
    if ((pHashTable==NULL) || (linked_list_nodes==NULL) || (xor_vectors==NULL))
      mexErrMsgTxt("Cannot find hash table or linked list nodes");
    else{
      //mexPrintf("Found hash table....\n");
      //mexPrintf("Bits: %d  Test vectors: %d\n",nBytes,nTest);
    }
    
    //if (nBytes>(1+ceil(TABLE_BITS/8)))
    //  mexErrMsgTxt("Too many bits -- please reduce or alter hard-coded limit and recompile");
    
    // Make output matrix
    //mexPrintf("Creating output matrix of size: %d  by %d\n",nTest,MAX_RETURN);
    OUTPUT = mxCreateNumericMatrix(MAX_RETURN,nTest,mxINT32_CLASS,mxREAL);
    outputp = (int*) mxGetPr(OUTPUT);
    outputp_base = (int*) mxGetPr(OUTPUT);

    
    // Test mode
    //mexPrintf("Now put test data into hash\n");
    pMat = (unsigned char*) mxGetPr(MAT);
 
    //mexPrintf("Output array start address: %p\n",outputp);
    
    for (i=0;i<nTest;i++){
      
      big_hash_key = 0; tally = 0;
      
      for (j=0;j<nBytes;j++)
	big_hash_key += ( pMat[i*nBytes+j] * byte_offset[j] );
      
      //mexPrintf("Test: %d, hash key: %u\n",i,hash_key);
      
      // Now search over hamming ball
      // Reverse order so we check distance 0 first, before checking distance 1.
      for (k=0;k<num_xor_vectors;k++){
	
	if (tally<MAX_RETURN){
	  
	  new_hash_key = big_hash_key ^ xor_vectors[k];
	  new_hash_key2 = new_hash_key % HASH_PRIME;
	  
	  //mexPrintf("Big hash key: %llu, Xor vec: %llu, new hash key: %lu\n",big_hash_key,xor_vectors[k],new_hash_key);
	  j=15;
	  while ( (pHashTable[new_hash_key2]!=NULL) && (node_key(pHashTable[new_hash_key2])!=new_hash_key) ){
	    new_hash_key2 = (new_hash_key + j) % HASH_PRIME;
	    //    mexPrintf("Big hash key: %u, hash_key: %u, offset: %d\n",new_hash_key,new_hash_key2,j);
	    j+=j;
	  }
	  // mexPrintf("Big hash key: %llu, Xor vec: %llu, new hash key: %lu\n",big_hash_key,xor_vectors[k],new_hash_key2);

	  // Now see if there is a linked list at this location
	  if (pHashTable[new_hash_key2]!=NULL){

	    //list_print(pHashTable[new_hash_key2]);
	  
	    // We found a list
	    offset = (i*MAX_RETURN) + tally;
	    limit = MAX_RETURN - tally;
	    //mexPrintf("Cigar! - Found list with pointer: %p, passing in output location: %p\n",pHashTable[new_hash_key],&outputp,offset);
	    // Now copy the contents of the list into output array
	    found = list_copy(pHashTable[new_hash_key2],&outputp,offset,limit);
	    //mexPrintf("Copied %d elements from list\n",found);
	    
	    // inc. pointer
	    tally += found;
	    //mexPrintf("Tally is %d\n",tally);
	    
	  } 
	  
	  
	} // safety on max_return
	else{
	  //mexPrintf("Too many found for example: %d, skipping..\n",i);
	} 
	
      } // loop over xor vectors
      
       
    } // loop over testing images
  } // end of else


  return;
    
}

