# GPU

For research purpose, I started digging into GPU for the first time.
Spent some time just learning the basics. And for now just want to
know how large systems are using GPUs, esp. CUDA. Just get a basic sense.

## Systems

- tensorflow
    - CUDA: `tensorflow/core/common_runtime/gpu`
    - quite complicated.
- tvm
    - CUDA: `src/runtime/cuda`
    - OpenCL: `src/runtime/opencl`
    - both seem quite small. And they have documentation: https://tvm.apache.org/docs/dev/codebase_walkthrough.html?highlight=cuda. Hooray!
- pytorch and caffee2
    - CUDA: over all the places. well.
- nvidia cuda samples
