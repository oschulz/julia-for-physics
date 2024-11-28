# Copyright (c) 2023 Oliver Schulz <oschulz@mpp.mpg.de>
# This software is licensed under the MIT License (MIT).


using Flux, StatsBase, Symbolics, SparseArrays, StaticArrays, Functors, BenchmarkTools

# Simple dummy ML classifier model:

ninputs = 10
nlatent = 40

model = Chain(
    Dense(ninputs => nlatent, relu),
    Dense(nlatent => nlatent, relu),
    Dense(nlatent => 1, sigmoid, bias=false)
)

# Turn it into a dummy sparse model by setting randomly selected weights to zero:

for i in eachindex(model)
    A = model[i].weight
    nzeros = trunc(Int, 9//10 * length(A))
    A[sample(eachindex(A), nzeros, replace = false)] .= 0
end

model[2].weight


# Run model:

x = randn(Float32, ninputs)
model(x)

# Iterate above until model(x) is not exactly 0.5 to get an interesting sparse dummy model.

# Benchmark model performance:

@benchmark $model($x)


# Use SparseArrays (only helps if model is very sparse and layer sizes are large):

sparse_model = fmap(A -> (A isa AbstractMatrix ? sparse(A) : A), model)

sparse_model[2].weight
sparse_model(x)

@benchmark $sparse_model($x)


# Use StaticArrays (only works well if model layer sizes are small):

static_model = fmap(A -> (A isa AbstractArray ? SArray{Tuple{size(A)...}}(A) : A), model)
static_x = SVector(x...)

static_model(static_x)

@benchmark $static_model($static_x)


# Use symbolic optimization:

@variables symbolic_x[1:ninputs]

symbolic_x[1] isa Real
relu(symbolic_x[1])
sigmoid(symbolic_x[1])

model_symexpr = simplify(only(model([symbolic_x...])))
symopt_model_jlcode = build_function(model_symexpr, symbolic_x, expression = Val(true))
symopt_model = build_function(model_symexpr, symbolic_x, expression = Val(false))

symopt_model(x)

@benchmark $symopt_model($x)


# Generate plain C code for symbolic model:

c_model_code = build_function(model_symexpr, symbolic_x, target = Symbolics.CTarget(), fname = "model")

# Some fixes since build_function currently thinks everything is a double in C code:
fixed_c_model_code = replace(c_model_code, "double" => "float", "f0" => "f", "abs(" => "fabs(", "exp(" => "expf(")

print(fixed_c_model_code)

c_code_out = IOBuffer()
println(c_code_out, """
#include <stdio.h>
#include <stdbool.h>

float ifelse(bool cond, float a, float b) { return cond ? a : b; }
""")
println(c_code_out, fixed_c_model_code)
println(c_code_out, "
int main() {
    float x[] = {$(join(string.(x) .* "f", ", "))};
")
println(c_code_out, """
    float y[] = {0};
    model(y, x);
    printf("%f\\n", y[0]);
    return 0;
}
""")

write("run_c_model.c", take!(c_code_out))
println("run_c_model.c")

# Run C-model using

#=
```shell
gcc -O3 run_c_model.c -lm -o run_c_model
./run_c_model
```
=#
