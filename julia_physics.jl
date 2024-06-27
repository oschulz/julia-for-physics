#
# ## Verbs and nouns - functions and types
#
# * Julia is not Java: Verbs aren't owned by nouns
#
# * Julia has: types, functions and methods
#
# * Object-oriented languages: methods belong to types
#
# * Julia: methods belong to *functions*, not to types! \
#   In combination with multiple dispatch, much more powerful than OO.
#
#

#
# ## One-liner functions
#
# Short one-liner function:
#

f1(x) = x^2


f1(3)


#
# Function that needs more than one line:
#

#
# ## Multi-line funcions
#
# ```julia
# function f2(x)
#     # ... something ...
#     x^2
# end
# ```
#
# is equivalent to
#
# ```julia
# function f2(x)
#     # ... something ...
#     return x^2
# end
# ```
#
# The result of the last expression is returned by default\
# (like in Mathematica)
#
#

function f4(x)
    # ... something ...
    return x^2
end


#
# **Note:** `return` is optional, and often not used explicitly. Last expression in a function, block, etc. is automatically returned (like in Mathematica).
#

#
# ## Types
#
# An abstract type, must be empty:
#
# ```julia
# abstract type MySuperType end
# ```
#
# An immutable type, value of `i` can't change:
#
# ```julia
# struct MySubType <: MySuperType
#     i::Int
# 	j::Int
# end
# ```
#
# A mutable type, value of `i` can change:
#
# ```julia
# mutable struct MyMutableSubType <: MySuperType
#     i::Int
#     j::Int
# end
# ```
#

#
# ## Parametric types
#
# Julia has a powerful parametric type system, based on set theory:
#
# ```julia
# f(A::AbstractMatrix{<:Real}) = do_something_with(A)
# ```
#
# implements function `f` for *any* real-valued matrix,\
# but we may need to handle complex numbers differently:
#
# ```julia
# f(A::AbstractMatrix{<:Complex}) = do_something_else_with(A)
# ```
#
# Julia makes this easy.
#
#

#
# ## Type aliases and union types
#
# Type aliases are just const values:
#
# ```julia
# const Abstract2DArray{T} = AbstractArray{T,2}
# rand(2, 2) isa Abstract2DArray == true
# ```
#
# Type unions are unions of set of types.
#
# ```julia
# const RealVecOrMat{T} where {T<:Real} = Union{AbstractArray{T,1}, AbstractArray{T,2}}
# ```
#
# is the union of a 1D and 2D array types with real-valued elements.
#

#
# ## Syntax: Variables
#
# ```julia
# # Global variables:
# const a = 42
# b = 24
#
# function foo(x)
#     # Local variables:
#
#     c = a * x
#     d = b * x # Avoid, type of b can change!
#     #...
# end
# ```
#

#
# ## Loops
#
# For loop:
#
# ```julia
# for i in something_iterable
#     # ...
# end
# ```
#
# `something_iterable` can be a range, an array, anything that implements the Julia [iterator API](https://docs.julialang.org/en/v1/manual/interfaces/).
#
# While loop:
#
# ```julia
# while condition
#     # do something
# end
# ```
#

#
# ## Control flow
#
# If-else, evaluate only one branch:
#
# ```julia
# if condition
#     # do something
# elseif condition
#     # do something else
# else
#     # or something different
# end
# ```
#
# Ternary operator, evaluate only one branch:
#
# ```julia
# condition ? result_if_true : result_if_false
# ```
#
# `ifelse`, evaluate both results but return only one:
#
# ```julia
# ifelse(condition, result_if_true, result_if_false)
# ```
#

#
# ## Blocks and scoping
#
# Begin/end-block (does *not* introduce a new scope):
#
# ```julia
# begin
#     # *Not* a new scope in here
#     # ...
# end
# ```
#
# Let-block (*does* introduce a new scope):
#
# ```julia
# b = 24
#
# let my_b = b
#     # New scope in here.
#     # If b is bound to new value, my_b won't change.
#     # ...
# end
# ```
#

#
# ## Arrays
#
# Vectors:
#
# ```julia
# v = [1, 2, 3]
#
# v = rand(5)
# ```
#
# Matrices:
#
# ```julia
# A = [1 2; 3 4]
#
# A = rand(4, 5)
# ```
#
# * Column-first memory layout!
#
# * Almost anything array-like is subtype of `AbstractArray`.
#

#
# ## Array indexing
#
# Get `i`-th element of vector `v`:
#
# ```julia
# v[i]
# ```
#
# Most higher-dimensional array types support cartesian and linear indexing (usually faster):
#
# ```julia
# A[i, j]
# A[lin_idx] 
# ```
#
# Use `eachindex(A)` to get indices of best type for given `A` (usually linear).
#
#
# In Julia, anything array-like can usually be an index as well
#
# ```julia
# A[2:3, [1, 4, 5]]
# ```
#

#
# ## Array comprehension and generators
#
# Returns an array:
#
# ```
# [f(x) for x in some_collection]
# ```
#
# Returns an iterable generator:
#
# ```
# (f(x) for x in some_collection)
# ```
#

#
# ## Hello World (and more) in Julia
#

println("Hello, World!")


#
# Let's define a function
#

f(x, y) = x * y


f(20, 2.1)


#
# Multiplication is also defined for vectors, so this works, too:
#

f(4.2, [1, 2, 3, 4])


#
# ## Julia compiler flow
#
# 1) Julia Code (`@less`, `@which`, `@edit`)
# 2) Julia AST (`@code_lowered`)
# 3) Julia typed IR (`@code_typed`)
# 4) LLVM IR (`@code_llvm`)
# 4) Native assembly code (`@code_native`)
# 5) Binary machine code
#
#

#
# ## Let's Look Under the Hood
#

@code_llvm debuginfo=:none f(20, 2.1)


@code_native debuginfo=:none f(20, 2.1)


#
# ## Multiple Dispatch
#

foo(x::Integer, y::Number) = x * y


foo(x::Integer, y::AbstractString) = join(fill(y, x))


foo(3, 4)


foo(3, "abc")


foo(4.5, 3)


#
# ## Functional Programming
#

myarray = rand(10)


idxs = findall(x -> 0.2 < x < 0.6, myarray)


myarray[idxs]


#
# Even types are first-class values:
#
#

subtypes(Real)


#
# Julia type hierarchy extends all the way down to primitive types:
#

Float64 <: AbstractFloat <: Real <: Number <: Any


#
# ## Broadcasting
#

A, B = [1.1, 2.2, 3.3], [4.4, 5.5, 6.6];


broadcast((x, y) -> (x + y)^2, A, B)


#
# Shorter broadcast syntax:
#
#

(A .+ B) .^ 2


#
# ## Loop Fusion and SIMD Vectorization
#

begin
    foo(X, Y) = (X .+ Y) .^ 2
    @code_llvm raw=false debuginfo=:none foo(A, B)
end


#
# ## Native SIMD code
#
#

@code_native debuginfo=:none foo(A, B)


#
# ## Package management
#
# * Julia probably has the best package management to date
#
# * Press \"]\" to enter package management console
#
# * Typically `add PACKAGE_NAME` is sufficient, can also do `add PACKAGE_NAME@VERSION`
#
# * To get an unreleased version, use `add PACKAGE_NAME#BRANCH_NAME`
#
# * Easy to start modifying a package via `dev PACKAGE_NAME`
#
# * Multiple package versions can be installed, selection via [Pkg.jl environments](https://julialang.github.io/Pkg.jl/v1/environments).
#
# * Also useful: `julia> using Pkg; pkg\"<Pkg console command>\"`
#

#
# ## Package creation
#
# * A Julia package needs:
#
#     * A \"Project.toml\" file
#     * A \"src/PackageName.jl\" file
#
# * That's it: Push to GitHub, and package is installable via `add PACKAGE_URL`
#
# * Use [Documenter.jl](https://github.com/JuliaDocs/Documenter.jl) to document your package
#
# * To enable `add PACKAGE_NAME`, package must be [registered](https://github.com/JuliaRegistries/Registrator.jl), there are [some rules](https://github.com/JuliaRegistries/RegistryCI.jl#automatic-merging-guidelines)
#
# * Use [PkgTemplates.jl](https://github.com/invenia/PkgTemplates.jl) to generate new package with CI config (Travis, Appveyor, ...), docs generation, etc.
#

#
# ## No free lunch
#
# * Package loading and code-gen can sometime some time, 
#   but mitigations available:
#
# * [Revise.jl](https://github.com/timholy/Revise.jl): Hot code-reloading at runtime
#
# * More and more packages use new Julia capabilities to precompile binary code
#
#

#
# ## Performance tips
#
# * Read the [official Julia performance tips](https://docs.julialang.org/en/v1/manual/performance-tips/)!
# * Do *not* call on (non-const) global variables from time-critical code
# * Type-stable code is fast code. Use [`@code_warntype`](https://docs.julialang.org/en/v1/manual/performance-tips/#man-code-warntype-1) and [`Test.@inferred`](https://docs.julialang.org/en/v1/stdlib/Test/#Test.@inferred) to check!
# * In some situations, closures [can be troublesome](https://docs.julialang.org/en/v1/manual/performance-tips/#man-performance-captured-1), using `let` can help the compiler
#

#
# This is efficient (not runtime reflection):
#

begin
    half_dynrange(T::Type{<:Number}) = (Int(typemax(T)) - Int(typemin(T))) / 2
    half_dynrange(Int16)
end


@code_llvm half_dynrange(Int16)


#
# ## SIMD
#
# Demo
#

#
# ## Shared-memory parallelism
#
# * Julia has native multithreading support
#
# * Simple cases: Use `@threads` macro
#
# * Since Julia v1.3: Cache-efficient [composable multi-threaded parallelism](https://julialang.org/blog/2019/07/multithreading/)
#

#
# ## Processes, Clusters, MPI
#
# * Julia brings a full API for remote processes and compute clusters
#
# * Native support for local processes and remote processes via SSH, SLURM, MPI, ...
#
#

#
# ## Benchmarking and profiling, digging deeper
#
# Demo
#

#
# ## Docs and help
#
# * [Official Julia docs](https://docs.julialang.org/en/v1/)
#
# * [Julia Cheat Sheet](https://juliadocs.github.io/Julia-Cheat-Sheet/)
#
# * [Learning Julia](https://julialang.org/learning/)
#
# * [Julia Discourse](https://discourse.julialang.org/)
#
# * [Julia Slack](https://slackinvite.julialang.org/)
#
# * [Julia on Youtube](https://www.youtube.com/user/JuliaLanguage)
#
#

#
# ## Visualization/Plotting: Plots, Makie, plotting recipes
#

#
# ## Let's Make a Plot
#

using Plots


Plots.gr(size = (400,300));


begin
    x_range = -π:0.01:π
    plot(x_range, sin.(x_range) + rand(length(x_range)))
end


#
# ## Histograms are easy, too
#

begin
    using Distributions
    dist = Normal(0.0, 5.0)
end


stephist(rand(dist, 10^4), size = (400, 300))


#
# ## Talking to Python
#
# Calling Python from Julia is easy, can even use inline Python code:
#
#

using PyCall


numpy = pyimport("numpy")


numpy.zeros(5) isa Array


A_jl = rand(5);


py"""type($A_jl)""" isa PyObject


#
# ## Automatic differentiation
#
# Let's define a simple neural network layer and loss function and auto-differentiate through it.
#

begin
	struct ADenseLayer{
		M<:AbstractMatrix{<:Real},V<:AbstractVector{<:Real},F<:Function
	} <: Function
		A::M
		b::V
		f::F
	end
	
	(l::ADenseLayer)(x::AbstractVector{<:Real}) = (l.f).(l.A * x + l.b)
end


#
# ## Instantiating the layer
#
#

f_loss(y) = sum(y .^ 2);


relu(x) = ifelse(x > zero(x), x, zero(x));


mylayer = ADenseLayer(rand(5,5), rand(5), relu);


#
# ## Evaluating and gradients
#
#

begin
    x = rand(5)
    mylayer(x)
end


f_loss(mylayer(x))


begin
    using Zygote
    g = Zygote.gradient((mylayer, x) -> f_loss(mylayer(x)), mylayer, x)
    g[1].A
end


g[1].b


#
# ## Julia sets in Julia
#
#

using Colors, ColorSchemes, Images


using CUDA # Take this out if you don't want to install and load CUDA:


#
# Julia sets are the points where iteration of $$z_{i+1} = z_i^2 + c$$ stays bounded.
#
#

f_jls(z, c) = @fastmath z^2 + c;


#
# Function to count for how many iterations $$|z| < 8$$:
#
#

function n_f_jls(z, c, nmax)
    n = 0
    while abs2(z) < 8 && n < nmax
        z = f_jls(z, c)
        n += 1
    end
    return n - 1
end;


#
# Increase `n_iterations` from `10^3` to `10^4` or to `10^5` to show "almost connected" sets in higher quality, for example at c = -1.2387388f0 - 0.082582586f0im . Will make things slower, enable CUDA above to speed things up significantly.
#
#

@bind n_iterations Select([10^3, 10^4, 10^5])


#
# ## Interactive Julia-Set plots
#
#

#
# ```julia
# use_cuda, c_re, c_im =
# ```
#
#

@bind(use_cuda, CheckBox(default = false)),
@bind(c_re, Slider(range(-2.5, 1, length = 1000); default = -0.786)),
@bind(c_im, Slider(range(-1.5, 1.5, length = 1000); default = 0.147))


let	c = T(c_re) + T(c_im) * im
	@time @. N_iter = n_f_jls(eval_points, c, n_iterations)
	N_plot = copyto!(N_plotbuf, N_iter)
	#heatmap(N_plot, ratio = 1, format = :jpg)
	@info "max iterations: $(maximum(N_iter))"
	get.(Ref(ColorSchemes.magma), N_plot .* inv(maximum(N_plot)))
end


MyArray = use_cuda ? CuArray : Array;


begin
	T = Float32
	# Whether we compute on GPU or GPU just depends on the array type:
	N_iter = MyArray{Int}(undef, 250, 500)
	N_plotbuf = Array{Int}(undef, size(N_iter))
	range_re = range(T(-2), T(2), length = size(N_iter, 2))
	range_im = range(T(-2), T(2), length = size(N_iter, 1))
	eval_points = MyArray(range_re' .+ range_im * im)
end;


#
# ## Differential equations
#
# A dampened spring oscillator:
#
#

function harmonic_osc_eq(u, p, t)
    x, v = u[1], u[2]
	k, m, c = p[1], p[2], p[3]
    dx_dt = v
    dv_dt = - k/m * x - c/m * v
	du_dt = [dx_dt, dv_dt]
	return du_dt
end;


#
# Spring constant $k$, mass $$m$$, friction coefficient $$c$$:
#
#

ho_pars = (k = 5.0, m = 1.0, c = 0.5);


x0, v0 = [1.0, 0.0];


t_span = (0.0, 15.0);


#
# ## Solving the ODE
#
#

using OrdinaryDiffEq


sol = solve(
	ODEProblem(harmonic_osc_eq, [x0, v0], t_span, [ho_pars...]),
	saveat = 0:0.1:15
)


#
# ## Plotting the ODE solution
#
#

let t = sol.t, x = sol[1, :], v = sol[2, :]
	plot(t, x, label="x", linecolor = :blue, linewidth=2)
	plot!(t, v, label="v", linecolor = :green, linewidth=2)
end


#
# ## Fitting measured data
#
#

#
# A statistical forward model:
#
#

function fwd_model(t_obs::AbstractVector{<:Real}, pars::NamedTuple)
	m = 1.0
	(;x0, v0, k, c) = pars
	sol = solve(
		ODEProblem(
			harmonic_osc_eq, [x0, v0],
			(first(t_obs), last(t_obs)), [k, m, c]
		),
		# sensealg = SciMLSensitivity.EnzymeVJP(),
		saveat = t_obs
	)
	x_expected = sol[1, :]
	σ_noise = 0.1
	return MvNormal(x_expected, σ_noise)
end;


#
# ## Toy data generation
#
#

t_obs = 0:0.1:30;


p_truth = (x0 = 1.0, v0 = 0.0, k = 5.0, c = 0.5);


x_obs = rand(fwd_model(t_obs, p_truth));


scatter(t_obs, x_obs)


#
# ## Likelihood definition
#
#

using DensityInterface, MeasureBase


ℒ = Likelihood(p -> fwd_model(t_obs, p), x_obs);


p_init = (x0 = 0.1, v0 = 0.0, k = 1.0, c = 1.0);


logdensityof(ℒ, p_init)


#
# ## Maximum Likelihood fit
#
#

p_ctor = NamedTuple{propertynames(p_init)}


f_opt = logdensityof(ℒ) ∘ p_ctor;


using Optim


opt_result = Optim.maximize(ℒ ∘ p_ctor, collect(p_init))


p_max_likelihood = p_ctor(Optim.maximizer(opt_result))


#
# ## Parameter uncertainly and correlation estimate
#
#

using ForwardDiff


p_Σ = inv(ForwardDiff.hessian(f_opt, Optim.maximizer(opt_result)))


#
# Can also use reverse-mode AD:
#
# ```julia
# import SciMLSensitivity
# inv(Zygote.hessian(f_opt, Optim.maximizer(opt_result)))
# ```
#
#

#
# ## Bayesian maxmium posterior (MAP)
#
#

using BAT


prior = BAT.distprod((
	x0 = Normal(0, 1), v0 = Normal(0, 1), k = Exponential(3.0), c = Exponential(0.5)
));


posterior = lbqintegral(ℒ, prior);


p_max_postior = bat_findmode(posterior, BATContext()).result


#
# ## An incomplete tour of the Julia package ecosystem
#

#
# ## Math
#
# * [ApproxFun.jl](https://github.com/JuliaApproximation/ApproxFun.jl): Powerful function approximations
#
# * [FFTW.jl](https://github.com/JuliaMath/FFTW.jl): Fast fourier transforms via [FFTW](http://www.fftw.org/)
#
# * [DifferentialEquations.jl](https://github.com/JuliaDiffEq/DifferentialEquations.jl): A suite for numerically solving differential equations
#
# * ... many many many more ...
#
#

#
# ## Optimization
#
# * [JuMP.jl](https://github.com/JuliaOpt/JuMP.jl): Modeling language for Mathematical Optimization
#
# * [NLopt.jl](https://github.com/JuliaOpt/NLopt.jl): Optimization via [NLopt](https://github.com/stevengj/nlopt)
#
# * [Optim](https://github.com/JuliaNLSolvers/Optim.jl): Julia native nonlinear optimization
#

#
# ## TypedTables and DataFrames
#
# * [Tables.jl](https://github.com/JuliaData/Tables.jl): Abstract API for tabular data
#
# * [DataFrames.jl](https://github.com/JuliaData/DataFrames.jl): Python/R-like dataframes
#
# * [TypedTables.jl](https://github.com/JuliaData/TypedTables.jl): Type-stable tables
#
# * [Query.jl](https://github.com/queryverse/Query.jl) LINQ-inspired data query and transformation
#

#
# ## Plotting and Visualization
#
# * [IJulia.jl](https://github.com/JuliaLang/IJulia.jl): Julia Jupyter kernel
#
# * [Images.jl](https://github.com/JuliaImages/Images.jl): Image processing
#
# * [PyPlot.jl](https://github.com/JuliaPy/PyPlot.jl): Use matplotlib/PyPlot from Julia
#
# * [Makie.jl](https://github.com/JuliaPlots/Makie.jl): Hardware-accelerated plotting
#
# * [Plots.jl](https://github.com/JuliaPlots/Plots.jl): Plotting with generic recipes and multiple backends
#

#
# ## Statistics
#
# * [Distributions.jl](https://github.com/JuliaStats/Distributions.jl): Probability distributions and associated functions
#
# * [StatsBase.jl](https://github.com/JuliaStats/StatsBase.jl): Statistics, histograms, etc.
#
# * [Turing.jl](https://github.com/TuringLang/Turing.jl): Probabilistic model inference
#
# * [BAT.jl](https://github.com/bat/BAT.jl): Bayesian analysis toolkit
#
# * Many, many specialized packages
#
#

#
# ## Automatic Differentiation
#
# * Meta-packages [DifferentiationInterface.jl](https://github.com/gdalle/DifferentiationInterface.jl) and [AutoDiffOperators.jl](https://github.com/oschulz/AutoDiffOperators.jl)
# * [ForwardDiff.jl](https://github.com/JuliaDiff/ForwardDiff.jl): Forward-mode automatic differentiation
# * [Zyote.jl](https://github.com/FluxML/Zygote.jl): Source-level reverse-mode automatic differentiation
# * [Enzyme.jl](https://github.com/wsmoses/Enzyme.jl): LLVM-level reverse-mode automatic differentiation
# * Several other packages available ([ReverseDiff.jl](https://github.com/JuliaDiff/ReverseDiff.jl), [Nabla.jl](https://github.com/invenia/Nabla.jl), [Yota.jl](https://github.com/dfdx/Yota.jl), ...)
# * Exciting developements to come with new Julia Compiler features
#

#
# ## Machine learning
#
# * [Lux.jl](https://github.com/LuxDL/Lux.jl)
#
# * [SimpleChains.jl](https://github.com/PumasAI/SimpleChains.jl)
#
# * [Flux.jl](https://github.com/FluxML/Flux.jl): Julia native deep learning library
#
# * ...
#
# Orthogonal to GPU-Support and automatic differentiation (unlike Python ML)
#
#

#
# ## Calling code in other languages
#
# * Can natively call plain-C and Fortran code without overhead
#
# * [CxxWrap.jl](https://github.com/JuliaInterop/CxxWrap.jl): Wrap C++ packages for Julia (used by ROOT.jl and Geant4.jl)
# * [PyCall.jl](https://github.com/JuliaPy/PyCall.jl) and [PythonCall.jl](https://github.com/JuliaPy/PythonCall.jl): Call Python from Julia
#
# * [RCall.jl](https://github.com/JuliaInterop/RCall.jl): Call R from Julia
#
# * [MathLink.jl](https://github.com/JuliaInterop/MathLink.jl): Mathematica/Wolfram Engine integration
#
# * ...
#

#
# ## Efficient memory layout
#
# * [ArraysOfArrays.jl](https://github.com/oschulz/ArraysOfArrays.jl): Duality of flat and nested arrays
#
# * [StructArrays.jl](https://github.com/JuliaArrays/StructArrays.jl), [TypedTables.jl](https://github.com/JuliaData/TypedTables.jl): AoS and SoA duality
#
# * [ValueShapes.jl](https://github.com/oschulz/ValueShapes.jl): Duality of flat and nested structures
#
# * ...
#

#
# ## GPU Programming
#
# * [AMDGPU.jl](https://github.com/JuliaGPU/AMDGPU.jl): Julia on AMD GPUs (WIP)
#
# * [CUDA.jl](https://github.com/JuliaGPU/CUDA.jl): Julia on NVIDIA GPUs
#
# * [Metal.jl](https://github.com/JuliaGPU/Metal.jl): Julia on Apple M-series GPUs
#
# * [oneAPI.jl](https://github.com/JuliaGPU/oneAPI.jl): Julia on Intel oneAPI
#
# * Experimental work on other accelerator platforms (e.g. Graphcore IPUs)
#
#

#
# ## IDEs
#
# * [julia-vscode](https://www.julia-vscode.org/): Excellent Julia support in Visual Studio Code
#
# * Plugins for many other code editors
#
#

#
# ## Summary
#
# * Julia is productive, fast and fun - give it a chance!
#
# * Multiple dispatch opens up powerful ways of combining code
#
# * Upcoming events:
#     * [JuliaCon 2024, July 9th–13th, Eindhoven](https://juliacon.org/2024/)
#     * [JuliaHEP 2024, September 30th to October 4th, CERN](https://indico.cern.ch/event/1410341/)
#
#
