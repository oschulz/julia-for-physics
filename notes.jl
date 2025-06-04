### A Pluto.jl notebook ###
# v0.20.6

using Markdown
using InteractiveUtils

# ╔═╡ 7cdcec20-418e-11f0-2f63-d790037ca168
md"""
## Functions and Types

- analogy of programming language and natural language:
  - functions are verbs - most important (Julia: verb-oriented)
  - objects are nouns

- other languages are noun-oriented (object-oriented):
  - functions live inside of objects -> verbs belong to nouns

- in Julia:
  - functions different implementations (methods)
  - methods based on number and types of arguments

- keep that in mind: **purpose of types is to extend functions with new methods**

"""

# ╔═╡ d6754e29-0c73-4e8a-b397-a77bcc9750a7
md"""
## Function syntax
- no indentations to define code blocks
- last line is by default the return

possible demos: 
  - hypotenuse
"""

# ╔═╡ 49de387f-55f8-4209-bc2d-f7041de1f046
begin
	function hypot(a, b)
		c = sqrt(a^2 + b^2)
	end

	hypot_short(a, b) = sqrt(a^2 + b^2)
	
	hypot(2, 2) == hypot_short(2,2)
end

# ╔═╡ 53076759-3290-4024-a709-9f14620c7378
md"""
## Types
making a hierarchy of types - like parent-child

- abstract types
  - multible subtypes
  - must be empty
	abstract type MySuperType <: SomeType end

- concrete types
  - has no subtypes
  - struct
  - can have fields
  - fields can have types
  - by default immutable (after instantiating a Type, arguments can't be changed) -> mutable as keyword

possible demos: 
- Animal
  - Dog
  - Cat 

- Vectors
  - Vector2D
  - Vector3D

"""

# ╔═╡ d7acdc6c-9744-40ad-832f-1891af5c79e8


# ╔═╡ 8b475534-add3-43fb-8e5a-7f30a8dd5bba
md"""
## Parametric types

- instead of setting concrete types as arguments -> setting Sets of types (abstract types)

- can also be written like {T} where {T<:Real}

"""

# ╔═╡ 68fc4ce6-5e95-41d5-8ab5-d05633fbcf10


# ╔═╡ a38feca7-df70-497e-8845-acca031c1099
begin
	abstract type Animal end
	
	struct Dog <: Animal
		name::String
		age::Int
	end
	
	struct Cat <:Animal
		name::String
		age::Int
	end
	
end

# ╔═╡ 2f9d34f1-ab52-4a30-9a46-03eb2eeadc37


# ╔═╡ 85d9e794-485d-4b69-aeeb-368a170c5fd0


# ╔═╡ 4d2429f5-e38d-49de-977d-6a12f70ddc3e


# ╔═╡ Cell order:
# ╟─7cdcec20-418e-11f0-2f63-d790037ca168
# ╟─d6754e29-0c73-4e8a-b397-a77bcc9750a7
# ╠═49de387f-55f8-4209-bc2d-f7041de1f046
# ╟─53076759-3290-4024-a709-9f14620c7378
# ╠═d7acdc6c-9744-40ad-832f-1891af5c79e8
# ╟─8b475534-add3-43fb-8e5a-7f30a8dd5bba
# ╠═68fc4ce6-5e95-41d5-8ab5-d05633fbcf10
# ╠═a38feca7-df70-497e-8845-acca031c1099
# ╠═2f9d34f1-ab52-4a30-9a46-03eb2eeadc37
# ╠═85d9e794-485d-4b69-aeeb-368a170c5fd0
# ╠═4d2429f5-e38d-49de-977d-6a12f70ddc3e
