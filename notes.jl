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

# ╔═╡ 8b475534-add3-43fb-8e5a-7f30a8dd5bba
md"""
## Parametric types

- instead of setting concrete types as arguments -> setting Sets of types (abstract types)

- can also be written like {T} where {T<:Real}

"""

# ╔═╡ 02625656-1dfc-4fd0-9cc9-7425e56f52cb
md"""
## Loops
# for loop
- loop variable
- range
- do something

# while loop
- condition

"""

# ╔═╡ 4b578208-643d-4a14-8340-251d7da57aa6


# ╔═╡ 86f97597-8250-4fcd-91a5-4ef78c4293bb


# ╔═╡ 68fc4ce6-5e95-41d5-8ab5-d05633fbcf10
md"""
## Array comprehension and generators

- first: makes an actual array
- second: generates values on the fly only when you ask for them

syntax: 
- some function
- for loop 

"""

# ╔═╡ af0be913-e901-4b26-908b-00d318af9911
begin
	array = [x^2 for x in 1:2]
	generator = (x^2 for x in 1:2)
	collect(generator) # makes then an array
	sum(generator) # sums up elements
	
end

# ╔═╡ 965f0cbb-8f34-4d5c-8516-284615d258eb
md"""
## Multiple Dispatch

remember analogy of nouns and verbs

more methods can be written without owning the specific types/objects 

chooses methods depending on Types of all arguments and not just the first

"""

# ╔═╡ 59cecd6b-5669-473d-a8ed-c92e5d22054a
begin

	abstract type food end
	
	struct Meat <: food end
	struct Fish <: food end
	struct Veggies <: food end
	struct SideDish <: food end

	function cook(::Meat, ::SideDish)
	    println("carnivor")
	end
	
	function cook(::Fish, ::SideDish)
	    println("pescitarian")
	end
	
	function cook(::Veggies, ::SideDish)
	    println("vegan")
	end

	brokkoli = Veggies()
	steak = Meat()
	sprout = Fish()
	rise = SideDish()
	
	cook(brokkoli, rise)    # prints "vegan"
	cook(sprout, rise)    # prints "pescitarian"
	cook(steak, rise)    # prints "canivor"

end


# ╔═╡ 25899019-3f81-4616-ac50-ca65723752b4
md"""
You take a function (an action), and apply it to every item in a collection — like every number in a list — automatically and efficiently.
"""

# ╔═╡ a38feca7-df70-497e-8845-acca031c1099


# ╔═╡ 2f9d34f1-ab52-4a30-9a46-03eb2eeadc37


# ╔═╡ 85d9e794-485d-4b69-aeeb-368a170c5fd0


# ╔═╡ 4d2429f5-e38d-49de-977d-6a12f70ddc3e


# ╔═╡ 4568332b-a89d-4d2c-8592-b27b15007f62
begin
	numbers = 1:10
	new_numbers = []

	for i in numbers
		 push!(new_numbers, i + 10)
	end
	println(new_numbers)

	j = 1
	while j < 4
		println(j) 
		j += 1
	end

	while true
		#do something
	end
	
end

# ╔═╡ 7675aa80-252a-4892-94c2-ad0448701479
begin 
	new_numbers = numbers .+ 10   # The dot before + means "broadcast"
	println(new_numbers)          # [11, 12, 13, 14]
end

# ╔═╡ Cell order:
# ╟─7cdcec20-418e-11f0-2f63-d790037ca168
# ╟─d6754e29-0c73-4e8a-b397-a77bcc9750a7
# ╠═49de387f-55f8-4209-bc2d-f7041de1f046
# ╟─53076759-3290-4024-a709-9f14620c7378
# ╠═d7acdc6c-9744-40ad-832f-1891af5c79e8
# ╟─8b475534-add3-43fb-8e5a-7f30a8dd5bba
# ╠═02625656-1dfc-4fd0-9cc9-7425e56f52cb
# ╠═4b578208-643d-4a14-8340-251d7da57aa6
# ╠═4568332b-a89d-4d2c-8592-b27b15007f62
# ╠═86f97597-8250-4fcd-91a5-4ef78c4293bb
# ╟─68fc4ce6-5e95-41d5-8ab5-d05633fbcf10
# ╠═af0be913-e901-4b26-908b-00d318af9911
# ╠═965f0cbb-8f34-4d5c-8516-284615d258eb
# ╠═59cecd6b-5669-473d-a8ed-c92e5d22054a
# ╠═25899019-3f81-4616-ac50-ca65723752b4
# ╠═7675aa80-252a-4892-94c2-ad0448701479
# ╠═a38feca7-df70-497e-8845-acca031c1099
# ╠═2f9d34f1-ab52-4a30-9a46-03eb2eeadc37
# ╠═85d9e794-485d-4b69-aeeb-368a170c5fd0
# ╠═4d2429f5-e38d-49de-977d-6a12f70ddc3e
