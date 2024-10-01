### A Pluto.jl notebook ###
# v0.19.46

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 6af6b562-e920-4975-b253-c169ab58456e
begin
	import Pkg; Pkg.activate(".")
	
	using PlutoUI, HypertextLiteral# PlutoStyles
		
	julia_logo = PlutoUI.LocalResource("images/logos/julia-logo.svg")
	mpg_logo = PlutoUI.LocalResource("images/logos/mpg-logo.svg")
	mpp_logo = PlutoUI.LocalResource("images/logos/mpp-logo.svg")

	detcap_impurity_measurement = PlutoUI.LocalResource("images/figures/detcap-impurity-measurement.svg")
	parton_posterior = PlutoUI.LocalResource("images/figures/parton-posterior.svg")
	ssd_electron_shower = PlutoUI.LocalResource("images/figures/ssd_electron_shower.gif")
	
	html"""
		<style>
		input[type*="range"] { width: 100%; }
	
		pluto-output h2 {
		    border-bottom: 0;
			text-align: center;
			//background-color: #888888;
		    //font-size: 1.8rem;
		    //margin-bottom: .5rem
		}
	
	    main {
		    //flex: 1;
		    //max-width: 80ex;
		    //padding: 0 0 0 0;
		    //width: 80ex;
		}
	
 		pluto-editor main {
		    align-self: center;
			margin-left:10ex;	
			margin-right:10ex;
		}
		</style>
	"""
end

# ╔═╡ 1174e4de-7433-49ec-bf8e-8b4dbed1728c
using Plots

# ╔═╡ 5f661f5c-8072-43d7-8202-f0214058041a
begin
    using Distributions
    dist = Normal(0.0, 5.0)
end

# ╔═╡ 19deea61-306c-43cd-bae7-0dd49647cb08
using PyCall

# ╔═╡ d4b37b8e-3b58-42e0-90e0-e7827d325355
using Colors, ColorSchemes, Images

# ╔═╡ ee20ed92-3101-492d-8a9e-4b6ffe548919
using CUDA # Take this out if you don't want to install and load CUDA:

# ╔═╡ c3850185-e3be-401a-a3e0-5036ab88c071
@htl """
<h2 style="text-align: center;">
    <span style="display: block; text-align: center;">
        <img alt="(Julia)" src="$(julia_logo.src)" style="height: 1.5em; display: inline-block; margin: 0em;"/> <br>
		for Physics (and Physicists)
    </span>
    <span style="display: block; text-align: center;">
        
    </span>
</h2>

<div style="text-align: center;">
    <p style="text-align: center; display: inline-block; vertical-align: middle;">
        Oliver Schulz<br>
        <small>
            Max Planck Institute for Physics <br/>
            <a href="mailto:oschulz@mpp.mpg.de" target="_blank">oschulz@mpp.mpg.de</a>
        </small>
    </p>
</div>
<div style="text-align: center;">
    <p style="text-align: center; display: inline-block; vertical-align: middle;">
        <img src="$(mpg_logo.src)" style="height: 5em; display: inline-block; vertical-align: middle; margin: 1em;"/>
        <img src="$(mpp_logo.src)" style="height: 5em; display: inline-block; vertical-align: middle; margin: 1em;"/>
    </p>
</div>

<p style="text-align: center;"> 
	<em>JuliaHep 2024, CERN, October 2024</em>
</p>"""

# ╔═╡ be8c934c-9f4a-4b37-bdb2-2bf3be1698b6
md"""
## Why Julia?
"""

# ╔═╡ 2c3033a3-f9a6-445e-9b85-c013734fa299
md"""
## Science needs code - but how to write it?

* Choice of programming language(s) matter!

* Need to balance:
    * Learning time
    * Productivity
    * Performance

* Usually involves compromises
"""

# ╔═╡ 3d67632f-2e27-4d74-86ac-6851079cb5fd
md"""
## Programming Language Options

* C++:
    * Pro: Very fast (in expert hands)
    * Pro: Really cool new concepts (even literally) in C++11/14/17/...
    * Con: Complex, takes long time to learn and much longer to master
    * Con: Straightforward tasks often result in lengthy code
    * Con: No memory management (General protection faults)  
    * Con: No universal package management
    * Con: Composability isn't great
"""

# ╔═╡ e92bdc7e-92bf-4534-baf3-bda98136689a
md"""
## Programming Language Options

* Python:
    * Pro: Broad user base, popular first programming language
    * Pro: Easy to learn, good standard library
    * Con: Can't write time-critical loops in Python,  
      workarounds like Numba/Cython have
      [many limitations](http://www.stochasticlifestyle.com/why-numba-and-cython-are-not-substitutes-for-julia/),  
      don't compose well
    * Con: Language itself fairly primitive, not very expressive
    * Con: Duck-Typing necessitates lots of test code
    * Con: No effective multi-threading
    * Con: Composability isn't great
"""

# ╔═╡ 7f016f40-1f3f-44d4-8e74-cd596c8acbd8
md"""
## What else is there?

* Fortran:
    * Pro: Math can be really fast
    * Con: Old language, few modern concepts
    * Con: Shrinking user base
    * Con: Composability isn't great
    * Do you *really* want to ...?


* Scala, Go, Kotlin etc.:
    * Pro: Lots of individual strengths
    * Con: Math either fast *or* generic *or* or complicated
    * Con: Calling C, Fortran or Phython code often difficult
    * Con: Composability isn't great
"""

# ╔═╡ ea08384d-79a6-48e1-a893-0bb0f8134c9c
md"""
## The 97 and the 3 Percent

> We should forget about small efficiencies, say about 97% of the time: *premature optimization is the root of all evil. Yet we should not pass up our opportunities in that critical 3%*.

Donald E. Knuth

* Some programming languages (e.g. Python) great for the 97% - but can't make the 3% fast.
* Some other languages (e.g. C/C++, Fortran) can handle the 3% - but makes the 97% complicated."""

# ╔═╡ efb5333b-f5e4-4ca3-8664-11c277d4f24b
md"""
## The Two-language Problem

* Common approach nowadays:  
  Write time critical code in C/C++, rest in Python

* Pro: End-user can code comfortably in Python, with good performance

* Con: Complexity of C/C++ **plus** complexity of Python

* Con: Need proficiency in **two** languages, barrier that prevents  
  non-expert users from contributing to important parts of code

* Con: Limits generic implementation of algorithms

* Con: Severely limits metaprogramming, automatic differentiation, etc."""

# ╔═╡ 84196e50-44c8-4f77-9f23-b87234efce4d
md"""
## The Expression Problem

> The expression problem is a new name for an old problem. The goal is to define a datatype by cases, where one can add new cases to the datatype and new functions over the datatype, without recompiling existing code, and while retaining static type safety (e.g., no casts).

*Philip Wadler*

* In other words: The capability to add both new subtypes and new functionality for a type defined in a package you don't own
* Object oriented languages typically can't do this \
  (Ruby has a dirty way, Scala a clean workaround)
* If you have programming experience, you have felt this, even if you didn't name it
* Result: Packages tend not to compose well
"""

# ╔═╡ b8113ef0-4126-49ba-b57c-ada2da42696a
md"""
## What we want is a language ...

* as fast as C/C++/Fortran
* as easy to learn and productive as Python
* with a solution for the expression problem
* with first class math support (vectors, matrices, etc.)
* with excellent package management
* with true functional programming
* with great Fortran/C/C++/Python integration
* with true metaprogramming (like Lisp or Scala)
* good at parallel and distributed programming
* suitable for interactive, small and large applications
"""

# ╔═╡ 45c86bad-8692-4d5b-9cea-d2a0a12a0fc1
md"""
## Julia

* Designed for scientific/technical computing
* Originated at MIT, first public version 2012
* Covers the whole wish-list
* Clear focus on user productivity and software quality
* Rapid growth of user base and software packages
* Current version: Julia v1.10 (v1.11 release candidate available)"""

# ╔═╡ efecd9a4-94af-494d-b63d-91a4ccf3357d
md"""
## Julia Language Properties

* Fast: JAOT compilation to native CPU and GPU code
* Multiple-dispatch (more powerful than object-oriented): \
  solves the expression problem
* Dynamically typed
* Very powerful type system, types are first-class values
* Functional programming and metaprogramming
* First-class math support (like Fortran or Matlab)
* ..."""

# ╔═╡ 9633ccf3-ec6f-4cb2-aaa1-0aab71c3c160
md"""
## Julia Language Properties, cont.

* ...
* Local and distributed code execution
* State-of-the-art multi-threading: parallel code \
  can call parallel code that can call parallel code, ..., \
  without oversubscribing threads
* Software package management: \
  Trivial to create and install packages \
  built-in good scientific practice
* Excellent REPL (console)
* Easy to call Fortran, C/C++ and Python code"""

# ╔═╡ c0bbf02e-2315-46be-953f-095c2fcaeca4
md"""
## Particle physics publications with Julia

Incomplete selection of some particle physics papers partially or fully based on Julia:

* GERDA *Final Results of GERDA on the Search for Neutrinoless Double-$$\beta$$ Decay* [Phys. Rev. Lett. (2020)](https://doi.org/10.1103/PhysRevLett.125.252502)

* LHCb *Study of the doubly charmed tetraquark $$T^+_{cc}$$*[nature comm., 2021](https://doi.org/10.1038/s41467-022-30206-w)

* LHCb *Observation of excited $$\Omega_c^0$$ baryons in $$\Omega_b^- \to \Xi_c^+ K^-m\pi^-$$ decays* [Phys. Rev. D, (2021)](https://doi.org/10.1103/PhysRevD.104.L091102)

* Eschle et al., *Potential of the Julia programming language for high energy physics computing* [Comput Softw Big Sci (2023)](https://doi.org/10.1007/s41781-023-00104-x)

* Botje et al. *Constraints on the Up-Quark Valence Distribution in the Proton* [PhysRevLett (2023)](https://doi.org/10.1103/PhysRevLett.130.141901)


* An et al., *The determination of the spin and parity of a vector-vector system* [acc. by JHEP (2024)](https://arxiv.org/abs/2007.05501)
"""

# ╔═╡ 1b7696a4-124f-4bee-b967-b2ecfcee35a4
md"""
## Julia in high-performance computing (HPC)

Julia at scale (very incomplete list):

* Celeste: Variational Bayesian inference for astronomical images (doi:10.1214/19-AOAS1258), 1.54 petaflops using 1.3 million threads on 9,300 Knights Landing (KNL) nodes on Cori at NERSC

* Clima: Full-earth climate simulation, https://clima.caltech.edu, large team, uses everything from MPI to GPUs

* Ice-flow simulations with FastIce.jl on supercomputer LUMI (AMD GPUs), excellent scaling

* ...
"""

# ╔═╡ 613a920a-1fcc-4b09-b6f8-7181d43c572d
md"""
## When (not) to use Julia

* *Do* use Julia for computations, visualization, data processing ... pretty much anything scientific/technical

* *Do not* use Julia for scripts what will only run for a second (code gen overhead), use Python or shell scripts

* *Do not (at least not yet)* use Julia for (non-computational) web apps, etc., use Go or Node.js

* *Do not (at least not yet)* use Julia for big machine learning with standard building blocks (LLMs, etc.), use Python frameworks

* *Do* try Julia for custom machine learning that mixes physics models and ML blocks
"""

# ╔═╡ cd8d42d6-fd19-4478-b038-a66ccd2131d2
md"""
## The Julia language
"""

# ╔═╡ 553560a1-9874-4d27-9fcc-305ecd433a5d
md"""
## Verbs and nouns - functions and types

* Julia is not Java: Verbs aren't owned by nouns

* Julia has: types, functions and methods

* Object-oriented languages: methods belong to types

* Julia: methods belong to *functions*, not to types! \
  In combination with multiple dispatch, much more powerful than OO.
"""

# ╔═╡ 00191462-4c08-471b-a817-d534cad5012b
md"""
## One-liner functions

Short one-liner function:"""

# ╔═╡ 06fa27f2-2f7a-4495-a479-8ae98d6ea215
f1(x) = x^2

# ╔═╡ e02b4c51-e14e-4ad0-bdf4-0d344966e827
f1(3)

# ╔═╡ c9482218-33d0-410d-bdbe-446d2c16491e
md"""
Function that needs more than one line:"""

# ╔═╡ f4b7a78c-56cb-42f8-91ea-ca07c64fe1ba
md"""
## Multi-line funcions

```julia
function f2(x)
    # ... something ...
    x^2
end
```

is equivalent to

```julia
function f2(x)
    # ... something ...
    return x^2
end
```

The result of the last expression is returned by default\
(like in Mathematica)
"""

# ╔═╡ c0e5d5bf-1c08-43e6-9e50-1d088b2df7d3
function f4(x)
    # ... something ...
    return x^2
end

# ╔═╡ 145683b3-456d-4eb5-b90b-96ce5387d5be
md"""
**Note:** `return` is optional, and often not used explicitly. Last expression in a function, block, etc. is automatically returned (like in Mathematica)."""

# ╔═╡ 5e6a2ab3-cca0-4d56-9568-3cacd180a245
md"""
## Types

An abstract type, must be empty:

```julia
abstract type MySuperType end
```

An immutable type, value of `i` can't change:

```julia
struct MySubType <: MySuperType
    i::Int
	j::Int
end
```

A mutable type, value of `i` can change:

```julia
mutable struct MyMutableSubType <: MySuperType
    i::Int
    j::Int
end
```"""

# ╔═╡ 3dfe1b03-6c33-4072-9054-c737e8b8cf47
md"""
## Parametric types
== AbstractMatrix{T} where {T<:Real}
Julia has a powerful parametric type system, based on set theory:

```julia
f(A::AbstractMatrix{<:Real}) = do_something_with(A)
```

implements function `f` for *any* real-valued matrix,\
but we may need to handle complex numbers differently:

```julia
f(A::AbstractMatrix{<:Complex}) = do_something_else_with(A)
```

Julia makes this easy!

Semantics: `AbstractMatrix{<:Real} == AbstractMatrix{T} where {T<:Real}` is the set of all matrix types that have the element type parameter set to an element of the set of all real number types.
"""

# ╔═╡ 72a72497-dac1-4c4f-ae12-b67dee6cf8f3
md"""
## Type aliases and union types

Type aliases are basically just const values:

```julia
const Abstract2DArray{T} = AbstractArray{T,2}
rand(2, 2) isa Abstract2DArray == true
```

Type unions are unions of set of types.

```julia
const RealVecOrMat{T} where {T<:Real} = Union{AbstractArray{T,1}, AbstractArray{T,2}}
```

is the union of a 1D and 2D array types with real-valued elements."""

# ╔═╡ 88ddcb51-fdde-48ce-b9f3-b8635a358ded
md"""
## Syntax: Variables

```julia
# Global variables:
const a = 42
b = 24

function foo(x)
    # Local variables:

    c = a * x
    d = b * x # Avoid, type of b can change!
    #...
end
```"""

# ╔═╡ 728d524f-c794-4c04-8ab8-92ec495447de
md"""
## Loops

For loop:

```julia
for i in something_iterable
    # ...
end
```

`something_iterable` can be a range, an array, anything that implements the Julia [iterator API](https://docs.julialang.org/en/v1/manual/interfaces/).

While loop:

```julia
while condition
    # do something
end
```"""

# ╔═╡ 75337c92-df8a-4d2b-a570-fff2523bb86a
md"""
## Control flow

If-else, evaluate only one branch:

```julia
if condition
    # do something
elseif condition
    # do something else
else
    # or something different
end
```

Ternary operator, evaluate only one branch:

```julia
condition ? result_if_true : result_if_false
```

`ifelse`, evaluate both results but return only one:

```julia
ifelse(condition, result_if_true, result_if_false)
```

All of these can return a value!
"""

# ╔═╡ c8c6806e-0333-4498-afdb-4f0e2c492698
md"""
## Blocks and scoping

Begin/end-block (does *not* introduce a new scope):

```julia
begin
    # *Not* a new scope in here
    # ...
end
```

Let-block (*does* introduce a new scope):

```julia
b = 24

let my_b = b
    # New scope in here.
    # If b is bound to new value, my_b won't change.
    # ...
end
```"""

# ╔═╡ abf717dd-32a5-45c6-889f-0ce17c5710b1
md"""
## Arrays

Vectors:

```julia
v = [1, 2, 3]

v = rand(5)
```

Matrices:

```julia
A = [1 2; 3 4]

A = rand(4, 5)
```

* Column-first memory layout!

* Almost anything array-like is subtype of `AbstractArray`."""

# ╔═╡ 30745fee-1c83-4842-9e35-5d18c7fb08b2
md"""
## Array indexing

Get `i`-th element of vector `v`:

```julia
v[i]
```

Most higher-dimensional array types support cartesian and linear indexing (usually faster):

```julia
A[i, j]
A[lin_idx] 
```

Use `eachindex(A)` to get indices of best type for given `A` (usually linear).


In Julia, anything array-like can usually be an index as well

```julia
A[2:3, [1, 4, 5]]
```"""

# ╔═╡ 73ea6c0e-5b72-446a-a869-6faee5fae48b
md"""
## Array comprehension and generators

Returns an array:

```
[f(x) for x in some_collection]
```

Returns an iterable generator:

```
(f(x) for x in some_collection)
```"""

# ╔═╡ a85133da-593c-4c3f-9aaf-df00a8265656
md"""
## Hello World (and more) in Julia"""

# ╔═╡ 047b9bac-d692-4520-bff0-7b2a7e294ba5
println("Hello, World!")

# ╔═╡ f6f65bc9-f4b2-4565-bf87-2cf1c68c2142
md"""
Let's define a function"""

# ╔═╡ 6839328b-8e1c-4874-b966-5400cb17b327
f(x, y) = x * y

# ╔═╡ d27c43a3-cf78-4b1f-bda7-e761f63e2b08
f(20, 2.1)

# ╔═╡ 3c2858f4-97bd-42ef-a1ff-45d8e3101d96
md"""
Multiplication is also defined for vectors, so this works, too:"""

# ╔═╡ 05837a64-d61a-40f1-b4c9-0fcc8592a732
f(4.2, [1, 2, 3, 4])

# ╔═╡ 0272e720-03d4-45b0-b615-aaef019bec7f
md"""
## Julia compiler flow

1) Julia Code (`@less`, `@which`, `@edit`)
2) Julia AST (`@code_lowered`)
3) Julia typed IR (`@code_typed`)
4) LLVM IR (`@code_llvm`)
4) Native assembly code (`@code_native`)
5) Binary machine code
"""

# ╔═╡ 93da2a4e-0bb5-4ff8-b237-fd514c1a3c21
md"""
## Let's Look Under the Hood"""

# ╔═╡ bc4af845-12ce-47f6-9320-a7372a5c5892
@code_llvm debuginfo=:none f(20, 2.1)

# ╔═╡ 79af3ef2-a18e-41c5-bffb-c1a452592204
@code_native debuginfo=:none f(20, 2.1)

# ╔═╡ bc7710c5-8638-4039-99ef-a411964a12c5
md"""
## Multiple Dispatch"""

# ╔═╡ 3a95425b-f714-49c4-b11f-8b087806b57b
foo(x::Integer, y::Number) = x * y

# ╔═╡ ea5769cf-41ba-42cd-baa0-6e6843b50d00
foo(x::Integer, y::AbstractString) = join(fill(y, x))

# ╔═╡ 146caca6-0abe-4b7c-9338-55ae46d1555e
foo(3, 4)

# ╔═╡ 181e6357-88dd-4311-98fd-b677d4c23498
foo(3, "abc")

# ╔═╡ 1827c0ed-32c3-4a8a-a75c-ac32bda032c1
try
	foo(4.5, 3)
catch err
	@info err
end

# ╔═╡ c7df5aab-44bf-47fc-822b-2c1dbcce5910
md"""
## Functional Programming"""

# ╔═╡ c06d9035-8e32-4f6a-ac13-8efa2998e682
myarray = rand(10)

# ╔═╡ b9f0135a-94d0-4f70-869f-17a8965bf198
idxs = findall(x -> 0.2 < x < 0.6, myarray)

# ╔═╡ 7dc8c7d3-829a-4d54-9c2e-bd8f53279e28
myarray[idxs]

# ╔═╡ 7f9bdbd6-437d-47b4-ba3e-ce7a005388b0
md"""
Even types are first-class values:
"""

# ╔═╡ f762d6c0-a6f9-4956-92d6-45727b18bd87
subtypes(Real)

# ╔═╡ 91713101-f555-47d7-ab88-a33b77259552
md"""
Julia type hierarchy extends all the way down to primitive types:"""

# ╔═╡ 7b8e97f9-0515-4b4d-ae29-c10c161c8f0f
Float64 <: AbstractFloat <: Real <: Number <: Any

# ╔═╡ e6a551bd-8288-4bf1-b7dc-0015506a7d98
md"""
## Broadcasting"""

# ╔═╡ 6d75221c-7ed1-4b3d-8caf-80f54b48955f
A, B = [1.1, 2.2, 3.3], [4.4, 5.5, 6.6];

# ╔═╡ f965b60e-b0d4-4908-b2a8-c956fcb85157
broadcast((x, y) -> (x + y)^2, A, B)

# ╔═╡ 703dc474-d4ab-45cb-a1b0-a1cde30d311d
md"""
Shorter broadcast syntax:
"""

# ╔═╡ 05d3b4b6-e0aa-4db0-bc5b-6e7f710a3551
(A .+ B) .^ 2

# ╔═╡ eb1c9614-daf3-4a86-b056-52581bd0b07c
md"""
## Loop Fusion and SIMD Vectorization"""

# ╔═╡ 1d256fff-72c5-4057-928d-9cb0bbef572d
begin
    bar(X, Y) = (X .+ Y) .^ 2
    @code_llvm raw=false debuginfo=:none bar(A, B)
end

# ╔═╡ 558799cf-c133-4558-ba3e-7ecafd9ce62e
md"""
## Native SIMD code
"""

# ╔═╡ 2f673b0f-69c4-4954-a2d5-4166ad01c9f1
@code_native debuginfo=:none bar(A, B)

# ╔═╡ e117e215-63b2-4a4a-a80d-76c00453b04e
md"""
## Package management

* Julia probably has the best package management to date

* Press \"]\" to enter package management console

* Typically `add PACKAGE_NAME` is sufficient, can also do `add PACKAGE_NAME@VERSION`

* To get an unreleased version, use `add PACKAGE_NAME#BRANCH_NAME`

* Easy to start modifying a package via `dev PACKAGE_NAME`

* Multiple package versions can be installed, selection via [Pkg.jl environments](https://julialang.github.io/Pkg.jl/v1/environments).

* Also useful: `julia> using Pkg; pkg\"<Pkg console command>\"`"""

# ╔═╡ 65d1344c-75be-4f96-959c-542c601c53da
md"""
## Package creation

* A Julia package needs:

    * A \"Project.toml\" file
    * A \"src/PackageName.jl\" file

* That's it: Push to GitHub, and package is installable via `add PACKAGE_URL`

* Use [Documenter.jl](https://github.com/JuliaDocs/Documenter.jl) to document your package

* To enable `add PACKAGE_NAME`, package must be [registered](https://github.com/JuliaRegistries/Registrator.jl), there are [some rules](https://github.com/JuliaRegistries/RegistryCI.jl#automatic-merging-guidelines)

* Use [PkgTemplates.jl](https://github.com/invenia/PkgTemplates.jl) to generate new package with CI config (Travis, Appveyor, ...), docs generation, etc."""

# ╔═╡ a81d2d19-5789-4c63-bfde-59399dcf57ab
md"""
## No free lunch

* Package loading and code-gen can take some time, 
  but mitigations available:

* [Revise.jl](https://github.com/timholy/Revise.jl): Hot code-reloading at runtime

* More and more packages use new Julia capabilities to precompile binary code
"""

# ╔═╡ b699c7a6-5bbf-42fe-91b6-764ee8134389
md"""
## Performance tips

* Read the [official Julia performance tips](https://docs.julialang.org/en/v1/manual/performance-tips/)!
* Do *not* call on (non-const) global variables from time-critical code
* Type-stable code is fast code. Use [`@code_warntype`](https://docs.julialang.org/en/v1/manual/performance-tips/#man-code-warntype-1) and [`Test.@inferred`](https://docs.julialang.org/en/v1/stdlib/Test/#Test.@inferred) to check!
* In some situations, closures [can be troublesome](https://docs.julialang.org/en/v1/manual/performance-tips/#man-performance-captured-1), using `let` can help the compiler"""

# ╔═╡ ca78ed7d-7b04-435e-8d0b-44dd69fccb49
md"""
This is efficient (not runtime reflection):"""

# ╔═╡ d4e3f14f-dffb-45d6-b079-5aecd37cbfe6
half_dynrange(T::Type{<:Number}) = (Int(typemax(T)) - Int(typemin(T))) / 2;

# ╔═╡ 0e6af487-0bb3-4e6f-aa9c-8fe5aff98219
half_dynrange(Int16)

# ╔═╡ 43e5fe19-63d1-4b62-b654-85b62bdf66c7
@code_llvm half_dynrange(Int16)

# ╔═╡ 2c38ce67-c44c-4dfa-b5e8-157be5593d9a
md"""
## Shared-memory parallelism

* Julia has native multithreading support

* Simple cases: Use `@threads` macro

* Since Julia v1.3: Cache-efficient [composable multi-threaded parallelism](https://julialang.org/blog/2019/07/multithreading/)"""

# ╔═╡ f962af6e-6f6a-4edf-b4d4-d59b95db7315
md"""
## Processes, Clusters, MPI

* Julia brings a full API for remote processes and compute clusters

* Native support for local processes and remote processes via SSH, SLURM, MPI, ...
"""

# ╔═╡ 9afcf0ae-951a-44d7-b8e6-dbe58062b8cf
md"""
## Benchmarking and profiling, digging deeper

Demo"""

# ╔═╡ e5a1dcd9-cc13-4c0d-953c-a87245dbf975
md"""
## Docs and help

* [Official Julia docs](https://docs.julialang.org/en/v1/)

* [Julia Cheat Sheet](https://juliadocs.github.io/Julia-Cheat-Sheet/)

* [Learning Julia](https://julialang.org/learning/)

* [Julia Discourse](https://discourse.julialang.org/)

* [Julia Slack](https://slackinvite.julialang.org/)

* [Julia on Youtube](https://www.youtube.com/user/JuliaLanguage)
"""

# ╔═╡ 0f13def9-9f6b-41ed-bfd5-c72066e2e651
md"""
## Visualization/Plotting: Plots, Makie, plotting recipes"""

# ╔═╡ 55567c61-1d16-4415-87c4-20778e05533e
md"""
## Let's Make a Plot"""

# ╔═╡ 0d0353b1-bed3-496e-8f7a-a3c52bb418ea
Plots.gr(size = (400,300));

# ╔═╡ 8f8349d7-a150-41cc-8e51-7a0853824443
begin
    x_range = -π:0.01:π
    plot(x_range, sin.(x_range) + rand(length(x_range)))
end

# ╔═╡ 076d772e-1220-4e2e-8696-7c512e8c8928
md"""
## Histograms are easy, too"""

# ╔═╡ 68e607e6-ec96-4c99-ba40-930bc24fc3a2
stephist(rand(dist, 10^4), size = (400, 300))

# ╔═╡ ad607724-a401-445b-ab8c-e87f1c3f4d05
md"""
## Talking to Python

Calling Python from Julia is easy, can even use inline Python code:
"""

# ╔═╡ c464df43-d8fd-4909-a22f-3d00038eb96c
numpy = pyimport("numpy")

# ╔═╡ 66003d1e-57f8-4517-9827-32fc7eb7425e
numpy.zeros(5) isa Array

# ╔═╡ 0c4410e1-1a78-4015-a372-5ac1b072cf02
A_jl = rand(5);

# ╔═╡ a959204e-cf65-419d-91ed-628271367aa6
py"""type($A_jl)""" isa PyObject

# ╔═╡ f041e729-818e-4d90-9499-06f4c66d5a66
md"""
## Automatic differentiation

Let's define a simple neural network layer and loss function and auto-differentiate through it."""

# ╔═╡ bcd308e3-5595-452e-864c-75876ebb2d7e
begin
	struct DenseLayer{
		M<:AbstractMatrix{<:Real}, V<:AbstractVector{<:Real}, F<:Function
	} <: Function
		A::M
		b::V
		f::F
	end
	
	(l::DenseLayer)(x::AbstractVector{<:Real}) = (l.f).(l.A * x + l.b)
end

# ╔═╡ 356f23fd-d347-4b9e-9f53-609c03ba73b4
md"""
## Instantiating the layer
"""

# ╔═╡ da5dc5e5-c733-4b05-9e7d-2c27863742a0
f_loss(y) = sum(y .^ 2);

# ╔═╡ 948e4086-363f-45a3-b365-8895f8bda2d9
relu(x) = ifelse(x > zero(x), x, zero(x));

# ╔═╡ 3345ae31-ca00-4fe2-99bb-7782afac08f7
mylayer = DenseLayer(rand(5,5), rand(5), relu);

# ╔═╡ 1b53cb2c-5e99-4048-804b-a6476992f4be
md"""
## Evaluating and gradients
"""

# ╔═╡ cdfa9259-c085-42a4-8dae-00e523018d34
begin
    x = rand(5)
    mylayer(x)
end

# ╔═╡ 3d78a62c-dc97-4fbc-ba79-73bd183473a2
begin
    using Zygote
    g = Zygote.gradient((mylayer, x) -> f_loss(mylayer(x)), mylayer, x)
    g[1].A
end

# ╔═╡ 9f5b2e51-0ce8-45af-9aa6-ca8eb2265be1
f_loss(mylayer(x))

# ╔═╡ f5928c6a-e50c-4909-9d04-47f1b5337061
g[1].b

# ╔═╡ f869f8f9-586f-4f0e-8e46-e3c42796445e
md"""
## Julia sets in Julia
"""

# ╔═╡ 52e08586-7943-4964-b317-a2de065287dd
md"""
Julia sets are the points where iteration of $$z_{i+1} = z_i^2 + c$$ stays bounded.
"""

# ╔═╡ e21be748-ccca-486d-a262-9c23cb5da89e
f_jls(z, c) = @fastmath z^2 + c;

# ╔═╡ d52e66ab-fe4b-46fb-8a8c-42e4e6a431c2
md"""
Function to count for how many iterations $$|z| < 8$$:
"""

# ╔═╡ dc328c02-1ec0-4b95-ab42-e4d3d1352f7b
function n_f_jls(z, c, nmax)
    n = 0
    while abs2(z) < 8 && n < nmax
        z = f_jls(z, c)
        n += 1
    end
    return n - 1
end;

# ╔═╡ 9f31536e-9d94-4e46-ad1f-b96a0e04524e
md"""
Increase `n_iterations` from `10^3` to `10^4` or to `10^5` to show "almost connected" sets in higher quality, for example at c = -1.2387388f0 - 0.082582586f0im . Will make things slower, enable CUDA above to speed things up significantly.
"""

# ╔═╡ aa2547fa-86a1-4777-9106-f19c58ac4fac
@bind n_iterations Select([10^3, 10^4, 10^5])

# ╔═╡ d11fd6d2-7b71-45d2-8856-2e8315417376
md"""
## Interactive Julia-Set plots
"""

# ╔═╡ b1e6c795-0749-4f9c-865e-a43fca0992b1
md"""
```julia
use_cuda, c_re, c_im =
```
"""

# ╔═╡ 40394f1c-2c7d-4309-b9d4-3c2b4f55db99
@bind(use_cuda, CheckBox(default = false)),
@bind(c_re, Slider(range(-2.5, 1, length = 1000); default = -0.786)),
@bind(c_im, Slider(range(-1.5, 1.5, length = 1000); default = 0.147))

# ╔═╡ d5191740-521c-4913-94bb-ca3d55f01d12
MyArray = use_cuda ? CuArray : Array;

# ╔═╡ 4aba92af-a16b-4623-8a74-7ecc489e9634
begin
	T = Float32
	# Whether we compute on GPU or GPU just depends on the array type:
	N_iter = MyArray{Int}(undef, 250, 500)
	N_plotbuf = Array{Int}(undef, size(N_iter))

	range_re = range(T(-2), T(2), length = size(N_iter, 2))
	range_im = range(T(-2), T(2), length = size(N_iter, 1))
	eval_points = MyArray(range_re' .+ range_im * im)
end;

# ╔═╡ 8d8fbb75-ad99-4a78-9476-e1f388217fef
let	c = T(c_re) + T(c_im) * im

	@time @. N_iter = n_f_jls(eval_points, c, n_iterations)

	N_plot = copyto!(N_plotbuf, N_iter)
	#heatmap(N_plot, ratio = 1, format = :jpg)
	@info "max iterations: $(maximum(N_iter))"
	get.(Ref(ColorSchemes.magma), N_plot .* inv(maximum(N_plot)))
end

# ╔═╡ 437bdbfd-6e29-461f-885a-d47428c3b6cf
md"""
## An incomplete tour of the Julia package ecosystem"""

# ╔═╡ 74603261-3b3b-4128-8ddc-a79511c1ca16
md"""
## Math

* [ApproxFun.jl](https://github.com/JuliaApproximation/ApproxFun.jl): Powerful function approximations

* [FFTW.jl](https://github.com/JuliaMath/FFTW.jl): Fast fourier transforms via [FFTW](http://www.fftw.org/)

* [DifferentialEquations.jl](https://github.com/JuliaDiffEq/DifferentialEquations.jl): A suite for numerically solving differential equations

* ... many many many more ...
"""

# ╔═╡ ec31832a-36d7-484d-8a1d-fc3c3abe4990
md"""
## Optimization

* [JuMP.jl](https://github.com/JuliaOpt/JuMP.jl): Modeling language for Mathematical Optimization

* [NLopt.jl](https://github.com/JuliaOpt/NLopt.jl): Optimization via [NLopt](https://github.com/stevengj/nlopt)

* [Optim](https://github.com/JuliaNLSolvers/Optim.jl): Julia native nonlinear optimization"""

# ╔═╡ 7adee901-a5db-4526-8131-660a637ae0f5
md"""
## TypedTables and DataFrames

* [Tables.jl](https://github.com/JuliaData/Tables.jl): Abstract API for tabular data

* [DataFrames.jl](https://github.com/JuliaData/DataFrames.jl): Python/R-like dataframes

* [TypedTables.jl](https://github.com/JuliaData/TypedTables.jl): Type-stable tables

* [Query.jl](https://github.com/queryverse/Query.jl) LINQ-inspired data query and transformation"""

# ╔═╡ 41a32c0e-6a37-4c30-900e-265ba5755320
md"""
## Plotting and Visualization

* [IJulia.jl](https://github.com/JuliaLang/IJulia.jl): Julia Jupyter kernel

* [Images.jl](https://github.com/JuliaImages/Images.jl): Image processing

* [PyPlot.jl](https://github.com/JuliaPy/PyPlot.jl): Use matplotlib/PyPlot from Julia

* [Makie.jl](https://github.com/JuliaPlots/Makie.jl): Hardware-accelerated plotting

* [Plots.jl](https://github.com/JuliaPlots/Plots.jl): Plotting with generic recipes and multiple backends"""

# ╔═╡ 736fd82a-4da0-4b9e-842b-135ca38b6053
md"""
## Statistics

* [Distributions.jl](https://github.com/JuliaStats/Distributions.jl): Probability distributions and associated functions

* [StatsBase.jl](https://github.com/JuliaStats/StatsBase.jl): Statistics, histograms, etc.

* [Turing.jl](https://github.com/TuringLang/Turing.jl): Probabilistic model inference

* [BAT.jl](https://github.com/bat/BAT.jl): Bayesian analysis toolkit

* Many, many specialized packages
"""

# ╔═╡ d6e54613-9d12-479d-a7d2-920b1f8dcdac
md"""
## Automatic Differentiation

* Meta-packages [DifferentiationInterface.jl](https://github.com/gdalle/DifferentiationInterface.jl) and [AutoDiffOperators.jl](https://github.com/oschulz/AutoDiffOperators.jl)
* [ForwardDiff.jl](https://github.com/JuliaDiff/ForwardDiff.jl): Forward-mode automatic differentiation
* [Zyote.jl](https://github.com/FluxML/Zygote.jl): Source-level reverse-mode automatic differentiation
* [Enzyme.jl](https://github.com/wsmoses/Enzyme.jl): LLVM-level reverse-mode automatic differentiation
* [Mooncake.jl](https://github.com/compintell/Mooncake.jl) (WIP): Source-level reverse AD
* Several other packages available ([ReverseDiff.jl](https://github.com/JuliaDiff/ReverseDiff.jl), [Nabla.jl](https://github.com/invenia/Nabla.jl), [Yota.jl](https://github.com/dfdx/Yota.jl), ...)
* Exciting developements to come with new Julia Compiler features"""

# ╔═╡ 11b7bbf5-2a31-495d-8d53-da531aed0868
md"""
## Machine learning

* [Lux.jl](https://github.com/LuxDL/Lux.jl)

* [SimpleChains.jl](https://github.com/PumasAI/SimpleChains.jl)

* [Flux.jl](https://github.com/FluxML/Flux.jl): Julia native deep learning library

* ...

Orthogonal to GPU-Support and automatic differentiation (unlike Python ML)
"""

# ╔═╡ 0e06b851-820e-4ab6-bea5-f069e55bf12e
md"""
## Calling code in other languages

* Can natively call plain-C and Fortran code without overhead

* [CxxWrap.jl](https://github.com/JuliaInterop/CxxWrap.jl): Wrap C++ packages for Julia (used by ROOT.jl and Geant4.jl)
* [PyCall.jl](https://github.com/JuliaPy/PyCall.jl) and [PythonCall.jl](https://github.com/JuliaPy/PythonCall.jl): Call Python from Julia

* [RCall.jl](https://github.com/JuliaInterop/RCall.jl): Call R from Julia

* [MathLink.jl](https://github.com/JuliaInterop/MathLink.jl): Mathematica/Wolfram Engine integration

* ..."""

# ╔═╡ 07056b96-74a1-4ac3-80ee-2cb99ec674ec
md"""
## Efficient memory layout

* [ArraysOfArrays.jl](https://github.com/oschulz/ArraysOfArrays.jl): Duality of flat and nested arrays

* [StructArrays.jl](https://github.com/JuliaArrays/StructArrays.jl), [TypedTables.jl](https://github.com/JuliaData/TypedTables.jl): AoS and SoA duality

* [ValueShapes.jl](https://github.com/oschulz/ValueShapes.jl): Duality of flat and nested structures

* ..."""

# ╔═╡ 944441ed-90b1-43c6-9217-913a75e6c9ef
md"""
## GPU Programming

* [AMDGPU.jl](https://github.com/JuliaGPU/AMDGPU.jl): Julia on AMD GPUs (WIP)

* [CUDA.jl](https://github.com/JuliaGPU/CUDA.jl): Julia on NVIDIA GPUs

* [Metal.jl](https://github.com/JuliaGPU/Metal.jl): Julia on Apple M-series GPUs

* [oneAPI.jl](https://github.com/JuliaGPU/oneAPI.jl): Julia on Intel oneAPI

* Experimental work on other accelerator platforms (e.g. Graphcore IPUs)
"""

# ╔═╡ c862d3e8-ff7e-441f-a13f-f1489204abcb
md"""
## IDEs

* [julia-vscode](https://www.julia-vscode.org/): Excellent Julia support in Visual Studio Code

* Plugins for many other code editors
"""

# ╔═╡ eaca8f4e-1e10-420a-abfb-f53f8f786e96
md"""
## Summary

* Julia is productive, fast and fun - give it a chance!

* Multiple dispatch opens up powerful ways of combining code

* Upcoming event [CHEP 2024](https://indico.cern.ch/event/1338689/) with a Julia plenary talk an several other Julia-related talks
"""

# ╔═╡ Cell order:
# ╟─6af6b562-e920-4975-b253-c169ab58456e
# ╟─c3850185-e3be-401a-a3e0-5036ab88c071
# ╟─be8c934c-9f4a-4b37-bdb2-2bf3be1698b6
# ╟─2c3033a3-f9a6-445e-9b85-c013734fa299
# ╟─3d67632f-2e27-4d74-86ac-6851079cb5fd
# ╟─e92bdc7e-92bf-4534-baf3-bda98136689a
# ╟─7f016f40-1f3f-44d4-8e74-cd596c8acbd8
# ╟─ea08384d-79a6-48e1-a893-0bb0f8134c9c
# ╟─efb5333b-f5e4-4ca3-8664-11c277d4f24b
# ╟─84196e50-44c8-4f77-9f23-b87234efce4d
# ╟─b8113ef0-4126-49ba-b57c-ada2da42696a
# ╟─45c86bad-8692-4d5b-9cea-d2a0a12a0fc1
# ╟─efecd9a4-94af-494d-b63d-91a4ccf3357d
# ╟─9633ccf3-ec6f-4cb2-aaa1-0aab71c3c160
# ╟─c0bbf02e-2315-46be-953f-095c2fcaeca4
# ╟─1b7696a4-124f-4bee-b967-b2ecfcee35a4
# ╟─613a920a-1fcc-4b09-b6f8-7181d43c572d
# ╟─cd8d42d6-fd19-4478-b038-a66ccd2131d2
# ╟─553560a1-9874-4d27-9fcc-305ecd433a5d
# ╟─00191462-4c08-471b-a817-d534cad5012b
# ╠═06fa27f2-2f7a-4495-a479-8ae98d6ea215
# ╠═e02b4c51-e14e-4ad0-bdf4-0d344966e827
# ╟─c9482218-33d0-410d-bdbe-446d2c16491e
# ╟─f4b7a78c-56cb-42f8-91ea-ca07c64fe1ba
# ╟─c0e5d5bf-1c08-43e6-9e50-1d088b2df7d3
# ╟─145683b3-456d-4eb5-b90b-96ce5387d5be
# ╟─5e6a2ab3-cca0-4d56-9568-3cacd180a245
# ╟─3dfe1b03-6c33-4072-9054-c737e8b8cf47
# ╟─72a72497-dac1-4c4f-ae12-b67dee6cf8f3
# ╟─88ddcb51-fdde-48ce-b9f3-b8635a358ded
# ╟─728d524f-c794-4c04-8ab8-92ec495447de
# ╟─75337c92-df8a-4d2b-a570-fff2523bb86a
# ╟─c8c6806e-0333-4498-afdb-4f0e2c492698
# ╟─abf717dd-32a5-45c6-889f-0ce17c5710b1
# ╟─30745fee-1c83-4842-9e35-5d18c7fb08b2
# ╟─73ea6c0e-5b72-446a-a869-6faee5fae48b
# ╟─a85133da-593c-4c3f-9aaf-df00a8265656
# ╠═047b9bac-d692-4520-bff0-7b2a7e294ba5
# ╟─f6f65bc9-f4b2-4565-bf87-2cf1c68c2142
# ╠═6839328b-8e1c-4874-b966-5400cb17b327
# ╠═d27c43a3-cf78-4b1f-bda7-e761f63e2b08
# ╟─3c2858f4-97bd-42ef-a1ff-45d8e3101d96
# ╠═05837a64-d61a-40f1-b4c9-0fcc8592a732
# ╟─0272e720-03d4-45b0-b615-aaef019bec7f
# ╟─93da2a4e-0bb5-4ff8-b237-fd514c1a3c21
# ╠═bc4af845-12ce-47f6-9320-a7372a5c5892
# ╠═79af3ef2-a18e-41c5-bffb-c1a452592204
# ╟─bc7710c5-8638-4039-99ef-a411964a12c5
# ╠═3a95425b-f714-49c4-b11f-8b087806b57b
# ╠═ea5769cf-41ba-42cd-baa0-6e6843b50d00
# ╠═146caca6-0abe-4b7c-9338-55ae46d1555e
# ╠═181e6357-88dd-4311-98fd-b677d4c23498
# ╠═1827c0ed-32c3-4a8a-a75c-ac32bda032c1
# ╟─c7df5aab-44bf-47fc-822b-2c1dbcce5910
# ╠═c06d9035-8e32-4f6a-ac13-8efa2998e682
# ╠═b9f0135a-94d0-4f70-869f-17a8965bf198
# ╠═7dc8c7d3-829a-4d54-9c2e-bd8f53279e28
# ╟─7f9bdbd6-437d-47b4-ba3e-ce7a005388b0
# ╠═f762d6c0-a6f9-4956-92d6-45727b18bd87
# ╟─91713101-f555-47d7-ab88-a33b77259552
# ╠═7b8e97f9-0515-4b4d-ae29-c10c161c8f0f
# ╟─e6a551bd-8288-4bf1-b7dc-0015506a7d98
# ╠═6d75221c-7ed1-4b3d-8caf-80f54b48955f
# ╠═f965b60e-b0d4-4908-b2a8-c956fcb85157
# ╟─703dc474-d4ab-45cb-a1b0-a1cde30d311d
# ╠═05d3b4b6-e0aa-4db0-bc5b-6e7f710a3551
# ╟─eb1c9614-daf3-4a86-b056-52581bd0b07c
# ╠═1d256fff-72c5-4057-928d-9cb0bbef572d
# ╟─558799cf-c133-4558-ba3e-7ecafd9ce62e
# ╠═2f673b0f-69c4-4954-a2d5-4166ad01c9f1
# ╟─e117e215-63b2-4a4a-a80d-76c00453b04e
# ╟─65d1344c-75be-4f96-959c-542c601c53da
# ╟─a81d2d19-5789-4c63-bfde-59399dcf57ab
# ╟─b699c7a6-5bbf-42fe-91b6-764ee8134389
# ╟─ca78ed7d-7b04-435e-8d0b-44dd69fccb49
# ╠═d4e3f14f-dffb-45d6-b079-5aecd37cbfe6
# ╠═0e6af487-0bb3-4e6f-aa9c-8fe5aff98219
# ╠═43e5fe19-63d1-4b62-b654-85b62bdf66c7
# ╟─2c38ce67-c44c-4dfa-b5e8-157be5593d9a
# ╟─f962af6e-6f6a-4edf-b4d4-d59b95db7315
# ╟─9afcf0ae-951a-44d7-b8e6-dbe58062b8cf
# ╟─e5a1dcd9-cc13-4c0d-953c-a87245dbf975
# ╟─0f13def9-9f6b-41ed-bfd5-c72066e2e651
# ╟─55567c61-1d16-4415-87c4-20778e05533e
# ╠═1174e4de-7433-49ec-bf8e-8b4dbed1728c
# ╠═0d0353b1-bed3-496e-8f7a-a3c52bb418ea
# ╠═8f8349d7-a150-41cc-8e51-7a0853824443
# ╟─076d772e-1220-4e2e-8696-7c512e8c8928
# ╟─5f661f5c-8072-43d7-8202-f0214058041a
# ╠═68e607e6-ec96-4c99-ba40-930bc24fc3a2
# ╟─ad607724-a401-445b-ab8c-e87f1c3f4d05
# ╠═19deea61-306c-43cd-bae7-0dd49647cb08
# ╠═c464df43-d8fd-4909-a22f-3d00038eb96c
# ╠═66003d1e-57f8-4517-9827-32fc7eb7425e
# ╠═0c4410e1-1a78-4015-a372-5ac1b072cf02
# ╠═a959204e-cf65-419d-91ed-628271367aa6
# ╟─f041e729-818e-4d90-9499-06f4c66d5a66
# ╠═bcd308e3-5595-452e-864c-75876ebb2d7e
# ╟─356f23fd-d347-4b9e-9f53-609c03ba73b4
# ╠═da5dc5e5-c733-4b05-9e7d-2c27863742a0
# ╠═948e4086-363f-45a3-b365-8895f8bda2d9
# ╠═3345ae31-ca00-4fe2-99bb-7782afac08f7
# ╟─1b53cb2c-5e99-4048-804b-a6476992f4be
# ╠═cdfa9259-c085-42a4-8dae-00e523018d34
# ╠═9f5b2e51-0ce8-45af-9aa6-ca8eb2265be1
# ╠═3d78a62c-dc97-4fbc-ba79-73bd183473a2
# ╟─f5928c6a-e50c-4909-9d04-47f1b5337061
# ╟─f869f8f9-586f-4f0e-8e46-e3c42796445e
# ╠═d4b37b8e-3b58-42e0-90e0-e7827d325355
# ╠═ee20ed92-3101-492d-8a9e-4b6ffe548919
# ╟─52e08586-7943-4964-b317-a2de065287dd
# ╠═e21be748-ccca-486d-a262-9c23cb5da89e
# ╟─d52e66ab-fe4b-46fb-8a8c-42e4e6a431c2
# ╠═dc328c02-1ec0-4b95-ab42-e4d3d1352f7b
# ╟─9f31536e-9d94-4e46-ad1f-b96a0e04524e
# ╠═aa2547fa-86a1-4777-9106-f19c58ac4fac
# ╟─d11fd6d2-7b71-45d2-8856-2e8315417376
# ╟─b1e6c795-0749-4f9c-865e-a43fca0992b1
# ╟─40394f1c-2c7d-4309-b9d4-3c2b4f55db99
# ╟─8d8fbb75-ad99-4a78-9476-e1f388217fef
# ╠═d5191740-521c-4913-94bb-ca3d55f01d12
# ╟─4aba92af-a16b-4623-8a74-7ecc489e9634
# ╟─437bdbfd-6e29-461f-885a-d47428c3b6cf
# ╟─74603261-3b3b-4128-8ddc-a79511c1ca16
# ╟─ec31832a-36d7-484d-8a1d-fc3c3abe4990
# ╟─7adee901-a5db-4526-8131-660a637ae0f5
# ╟─41a32c0e-6a37-4c30-900e-265ba5755320
# ╟─736fd82a-4da0-4b9e-842b-135ca38b6053
# ╟─d6e54613-9d12-479d-a7d2-920b1f8dcdac
# ╟─11b7bbf5-2a31-495d-8d53-da531aed0868
# ╟─0e06b851-820e-4ab6-bea5-f069e55bf12e
# ╟─07056b96-74a1-4ac3-80ee-2cb99ec674ec
# ╟─944441ed-90b1-43c6-9217-913a75e6c9ef
# ╟─c862d3e8-ff7e-441f-a13f-f1489204abcb
# ╠═eaca8f4e-1e10-420a-abfb-f53f8f786e96
