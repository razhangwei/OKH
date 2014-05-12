README file for RBM code from CVPR'08 paper:
Small Codes and Large Image Databases for Recognition,
A. Torralba, R. Fergus, Y. Weiss.

@inproceedings{Torralba08,
author = "A. Torralba and R. Fergus and Y. Weiss",
title = "Small Codes and Large Image Databases for Recognition",
booktitle = cvpr,
year = "2008"
}

Version 1.0, Rob Fergus, 08/03/08.
-------------------------------------------------------

Table of Contents

0. Acknowledgements

1. Overview

2. List of routines

3. Preliminaries

4. Example experiment

-------------------------------------------------------------
0. Acknowledgements
-------------------------------------------------------------

I'd like to thank Geoff Hinton and Ruslan Salakhutdinov for putting
their code up online. Two of the included functions (rbm2.m and
rbmvislinear3.m) are copies of their routines.

Since they also invented the whole Semantic Hashing concept you should
also cite their papers if you publish a paper using it. Some Bibtex
references of their papers:

@inproceedings{Salakhutdinov07a,
author = "R. R. Salakhutdinov and G. E. Hinton",
title = "Semantic Hashing",
booktitle = "SIGIR workshop on Information Retrieval and applications of Graphical Models",
year      = "2007"
}


@article{Hinton06,
author = "G. E. Hinton and R. R. Salakhutdinov",
title = "Reducing the dimensionality of data with neural networks",
journal = "Science",
volume = "313",
number = "5786",
pages = "504--507",
month = "July",
year      = "2006"
}


@inproceedings{Salakhutdinov07,
author = "R. R. Salakhutdinov and G. E. Hinton",
title = "Learning a Nonlinear Embedding by Preserving Class Neighbourhood Structure",
booktitle = "AISTATS",
year      = "2007"
}

The NCA backpropagation cost function is taken from this paper:

@inproceedings{Goldberger04,
author = "J. Goldberger and S. T. Roweis and R. R. Salakhutdinov and G. E. Hinton",
title = "Neighborhood Components Analysis",
booktitle = "NIPS",
year      = "2004"
}

------------------------------------------------------
1. Overview
------------------------------------------------------

This code package provides the routines, data and example files that
implement the experiments using RBMs in the CVPR '08 paper. Please
read this paper before attempting to use this code. Note that much of
the code as an adaptation of the RBM code posted on Geoff Hinton's
webpage, which is accompanying material to the Science '06 paper: 

The implementation is in Matlab code, which should run under any
version. There are a couple of MEX files that will need to be compiled
before use.

Broadly speaking there are three sections to the code: (i)
pre-training of the RBM stack using contrastive divergence; (ii)
fine-tuning of the deep network using neighborhood component analysis
(NCA); (iii) evaluation of test examples using either exhaustive
search or semantic hashing concept.

Each experiment is specified in a Matlab script that lays out all the
different parameters and variables used in the experiments (stored in
the "model" structure), as well as building a structure holding all
the training and test data (imaginatively named "data"). An example of
such a script is given in the file "rbm_script_gist.m". When this file
is run the two structures, "model" and "data" are generated.

Then the first phase (pre-training of RBM stack) can be started, using
the function "train_rbm.m", for example: "model = train_rbm(model,data);"
This routine uses an adapted version of Geoff Hinton's code to train
each RBM layer in turn.

Once pre-training is finished, the backpropagation phase can be
started. This uses the NCA objective function to fine-tune the weights
in the network so that neighboring images in the input space are
closeby in code space. Before this can performed, a binary matrix
defining the neighborhood structure relationship must be
constructed. This is done with the "add_label_data2.m" function,
e.g. "data=add_label_data(data,MODE)", where MODE is a flag that
selects different sets of data to use. This adds certain fields to the
data structure that will be used by the back-propagation
function "backprop5.m". This is called with the command
"model=backprop5(model,data);". This will runs the rather slow NCA
backprop. Once completed the training is finished. 

Test data can be mapped to binary codes with the
"compute_binary_codes" function. Then the hamming distance between
test and training data can be computed either exhaustively using the
"hashD2" MEX file or the semantic hashing routine "hashing3.m". The
retrieval curves plotted in the CVPR08 paper can be made by using the
"measure_retrieval_perf.m" function. 

The input data is assumed to be in the form of either a 384 or
512-dimensional GIST descriptor. Code for computing these can be found
on Antonio Torralba's webpage.

-------------------------------------------------------------
2. List of routines & files
-------------------------------------------------------------

add_label_data2.m -- adds "nmat" binary matrix, defining neighborhood
relations in GIST space to data structure. Also adds "label_train" to
the data structure. This is the data that will be used for the
backpropagation phase of training.

backprop5.m -- main backprop routine. Uses "minimize.m" to optimize
"CG_NCA_new.m" cost function. 

bit2ndx.m -- converts binary vectors to vectors of uint8

compute_binary_code.m -- function that converts GIST vectors to binary
codes (in uint8 format). Calls "evaluate_rbm.m".

dist_mat.m -- computes L2 distance between set of points.

evaluate_rbm.m -- function that actually passes data forward through
model to obtain codes. Can also be used to form reconstructions of
original data.

hammD2.cpp -- source code for exhaustive Hamming distance computation.

hash_ham6.cpp -- source code for semantic hashing routine. Compiled
to MEX file with "mex hash_ham6" in Matlab. Requires a machine with
>10Gb of memory to be used in its current form. This version allows a variable number of
bits (including beyond 30) as it uses a double hashing approach (not
in the CVPR08 paper). The first hash is the feed-forward network that
maps GIST to a binary code. The second (traditional) hash maps the binary code to a
more compact binary space that fits in memory using a standard
randomizing hash function. The allows the use of deep networks with
more bits than would normally fit in memory. The total memory usage is
controlled by the TABLE_BITS definition in the source code. As it is
currently set to 30 bits you need (2^30 * 8 bytes/table entry = 8Gb of
memory). 

hashing3.m -- top-level function for semantic hashing. Calls
hash_ham3 MEX file. 

LabelMe_gist.mat -- data file holding Gist descriptors (gist) computed from
LabelMe 22,019 images (of size 256x256). Also holds Gist descriptor
parameters (param); training and test indices (ndxtrain,ndxtest);
ground truth similarity matrix (DistLM); pixel images (at 32x32 color)
(img); neighborhood matrix for NCA (nmat); object segmentation masks
(seg) and associated nouns (names).

Peekaboom_gist.m -- as per the LabelMe_gist.mat file, but for 57,637
images from Peekaboom. 

rbm_script_tiny.m -- MAIN CONFIGURATION SCRIPT, controls most things.

rbmvislinear3.m -- CD pre-training of RBM with Gaussian visibles and
binary hidden units. Code provided by Ruslan Salakhutdinov and Geoff Hinton

rbm2.m -- CD pre-training of RBM with binary visible and hidden units.
Code provided by Ruslan Salakhutdinov and Geoff Hinton.

train_rbm.m -- top-level script for CD pre-training of RBM.

visualize_neighbors.m -- plot out neighbors of the test images using
(i) ground truth (human labels); (ii) RBM codes; (iii) raw 512-dim
GIST descriptors; (iv) L2 distance on pixel intensities.

-------------------------------------------------------------
3. Preliminaries
-------------------------------------------------------------

1. You need a machine with Matlab. Version shouldn't be critical provided
   it is fairly recent, i.e. >7.0.

2. You will need to download the minimize.m routine by Carl Rasmussen
   from: http://www.kyb.tuebingen.mpg.de/bs/people/carl/code/minimize/.

3. If you want to use the semantic hashing, then you will need a
   machine with more than 8Gb or so (unless you alter the # bits in
   the hash code, see hash_ham6.cpp for this). This is optional since
   you can always just compute the Hamming distances exhaustively
   using the hammD2 function.

4. Compile the two MEX files. At the Matlab prompt, type:
	   " mex hash_ham6.cpp "
and	   " mex hammD2.cpp "

you should see two .mex??? files appear in the directory. The exact
extension will depend on your platform.

-------------------------------------------------------------
4. Walkthough of example experiment
-------------------------------------------------------------

1. Type "rbm_script_gist". This generates two structures, model and data.

2. Type "model=train_rbm(model,data);". This performs the pre-training (slow).

3. Type "data = add_label_data2(data,0);". This adds the labeled data
   from LabelMe to data.

4. Type "model = backprop5(model,data,10);". This performs the NCA
   backprop for 10 iterations (it is slow).

5. Type "data = compute_binary_code(model,data);". This computes
   binary codes for both training and test data (labeled). 

6. Type "measure_retrieval_perf". This runs the evaluation script.

7. Type "visualize_neighbors". This plot out neighbors for the test
   images using a variety of metrics.

8. Type "[neighbors_out,t] = hashing3(data.label_train_code,data.label_test_code,2);" to try out
   the semantic hashing.

