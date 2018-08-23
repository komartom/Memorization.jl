# Memorization.jl [![Build Status](https://travis-ci.org/komartom/Memorization.jl.svg?branch=master)](https://travis-ci.org/komartom/Memorization.jl) [![codecov.io](http://codecov.io/github/komartom/Memorization.jl/coverage.svg?branch=master)](http://codecov.io/github/komartom/Memorization.jl?branch=master)

Implementation of a simple binary classification model presented in [Chatterjee, S.. (2018). Learning and Memorization. Proceedings of the 35th International Conference on Machine Learning, in PMLR 80:755-763](http://proceedings.mlr.press/v80/chatterjee18a.html)

* model's architecture is similar to neural networks
* neurons are realized as lookup tables
* binary features are supported only
* binary classification
* neurons are connected randomly
* learning happens through memorizing training data into lookup tables
* parameters: number of layers (depth), number of neurons in layers, lookup table sizes, class preference on ties


## To install
Memorization.jl can be installed using Julia's package manager
```julia
Pkg.clone("https://github.com/komartom/Memorization.jl.git")
```

## Experiment on Binary-MNIST dataset
Separate digits 0-4 (class 0) from 5-9 (class 1) on 1-bit quantized pixel images
```julia
# Prepare Binary-MNIST dataset
download("https://pjreddie.com/media/files/mnist_train.csv", "./mnist_train.csv")
download("https://pjreddie.com/media/files/mnist_test.csv", "./mnist_test.csv")

const LABELS = 1
const PIXELS = 2:785

Dtrain = readdlm("./mnist_train.csv", ',', UInt8)
Xtrain = convert(Matrix{Bool}, Dtrain[:, PIXELS] .> 0)'
ytrain = convert(Vector{Bool}, Dtrain[:, LABELS] .>= 4)

Dtest = readdlm("./mnist_test.csv", ',', UInt8)
Xtest = convert(Matrix{Bool}, Dtest[:, PIXELS] .> 0)'
ytest = convert(Vector{Bool}, Dtest[:, LABELS] .>= 4)


using Memorization

# Definition of neural network architecture
# 4 hidden layers including 128 lookup tables of size 2^8
# The last output neuron (lookup table) has size 2^16 records
model = Network(784, [128, 128, 128, 128, 1], [8, 8, 8, 8, 16]);

# Effective number of neurons in layers
# Some neurons are not connected due to network shape and randomization
Memorization.numberofneurons(model)
# Returns approx. [128, 127, 83, 16, 1]

# Model training
@time mean(ytrain .== model(Xtrain, ytrain))
# Accuracy approx. 95% and time 7 seconds

# Model testing
@time mean(ytest .== model(Xtest))
# Accuracy approx. 92% and time 0.3 seconds
```
