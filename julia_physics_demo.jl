### A Pluto.jl notebook ###
# v0.20.21

#> [frontmatter]
#> title = "Julia for Physics (and Physicists)"
#> 
#>     [[frontmatter.author]]
#>     name = "Oliver Schulz"
#>     affiliation = "Max Planck Institute for Physics"

using Markdown
using InteractiveUtils

# ╔═╡ 6af6b562-e920-4975-b253-c169ab58456e
begin
	import Logging
	Logging.disable_logging(Logging.Info)

	import Pkg; Pkg.activate(".")

	using PlutoUI, HypertextLiteral# PlutoStyles

	julia_logo = PlutoUI.LocalResource("images/logos/julia-logo.svg")
	mpg_logo = PlutoUI.LocalResource("images/logos/mpg-logo.svg")
	mpp_logo = PlutoUI.LocalResource("images/logos/mpp-logo.svg")

	still_compiling = PlutoUI.LocalResource("images/figures/xkcd-303-compiling.png")
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

# ╔═╡ 12dc0875-42a7-4682-8932-64e156ff9a43
using LinearAlgebra

# ╔═╡ 6793cec8-a46d-49b0-aaca-d143ee089f3f
using ForwardDiff: gradient

# ╔═╡ ac18c16f-5088-448e-8318-17b2b6cd4f23
using StaticArrays

# ╔═╡ d716c0e0-10e8-435e-92ef-1bb170cbf618
using StatsBase, Makie, WGLMakie

# ╔═╡ d17031ec-6292-482f-8972-be57a50cb172
using BenchmarkTools

# ╔═╡ d79f2aa8-c46e-43c0-8ba0-f110a5e32a06
using Symbolics, Latexify

# ╔═╡ 330e7511-92bd-43b8-bebb-2f9678f30c3f
using OrdinaryDiffEq

# ╔═╡ 8b0c2d24-3a23-4854-bf29-d9400620fa6c
using Distributions, BAT

# ╔═╡ 96dd2d0c-cd89-4945-953a-e89cfea501c1
using DensityInterface, MeasureBase

# ╔═╡ 0d20c929-3fd6-4f36-943d-e217fdd21229
using InverseFunctions

# ╔═╡ 8603319f-e644-4665-bfe8-bee467dfcfbc
using Optim

# ╔═╡ d47af10e-fabe-454e-9de6-abd95c23de98
Logging.disable_logging(Logging.Debug);

# ╔═╡ c3850185-e3be-401a-a3e0-5036ab88c071
@htl """
<h2 style="text-align: center;">
    <span style="display: block; text-align: center;">
        <img alt="(Julia)" src="$(julia_logo.src)" style="height: 1.5em; display: inline-block; margin: 0em;"/> <br>
		A Physics Use Case
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
	<em>February 2026</em>
</p>"""

# ╔═╡ c683015b-d99e-4447-8bfe-2346c685c926
md"""
# Use case: electric multipoles
"""

# ╔═╡ e47f3072-ff1a-405b-9856-140163037ca7
md"""
## Constants and vectors

We'll need some packages and definitions ...
"""

# ╔═╡ 336b524e-dfff-4a90-880d-e26f7ce92ed7
begin
	const ε₀ = 8.8541878188e-12  # Vacuum permittivity in F/m
	const kₑ = 1 / (4π * ε₀)     # Coulomb's constant in N·m²/C²
	const e = 1.602176634e-19    # Elementary charge in C
	const p_H₂O = 6.17e-30       # Dipole moment of H₂O in C·m
	const e_mass = 9.1093837e-31 # Electron mass in kg
end;

# ╔═╡ b0a1abb9-77a3-432c-a6b9-5d87684cb404
const NumVector{T<:Real} = AbstractVector{T}

# ╔═╡ a7e73711-10d1-445f-840a-c764c7b1fec6
md"""
## Multipole types and a potential function
"""

# ╔═╡ 64bab154-2ea3-4791-8389-258fde40445d
abstract type Multipole end

# ╔═╡ be25fac4-fde3-4ad1-b2f1-a6c9be79a7c6
"""
    epot(a::Multipole, b::Multipole, r::NumVector)

Compute the electrostatic potential energy between two multipoles.

`r` points from `a` to `b`.
"""
function epot end;

# ╔═╡ 20529b9c-aa29-4f58-b43c-79a2fa372133
struct Monopole{T<:Real} <: Multipole
    q::T
end

# ╔═╡ a7c2630f-4e7f-4fdd-becd-23d40d693b71
md"""
## Preserving numerical precision
"""

# ╔═╡ 0c24d0b0-e5e4-4938-991d-87dba8b3229d
epot_not_great(a::Monopole, b::Monopole, r::NumVector) = kₑ * (a.q * b.q) / norm(r);

# ╔═╡ 616cdf55-a19b-456b-b239-eab4c64e8bca
typeof(1.0f0)

# ╔═╡ 3722a2a6-a49a-4f67-8651-09e7504d4496
typeof( epot_not_great(Monopole(1), Monopole(1), [1.0f0, 0.0f0, 0.0f0]) )

# ╔═╡ 63019cd9-1ceb-4c47-a236-9daf5f21491c
⋄(k::Real, x::T) where {T<:Real} = float(T)(k) * x

# ╔═╡ 918cbb32-da1d-4e66-8b69-f2966e9a3d78
epot(a::Monopole, b::Monopole, r::NumVector) = kₑ ⋄ ((a.q * b.q) / norm(r));

# ╔═╡ f7b5e8ab-f544-4646-9bfa-eace52f29dba
md"""
## Let's have dipoles too
"""

# ╔═╡ a9363a5e-e172-473d-84be-0a49523b928d
struct Dipole{T<:Real, V<:NumVector{T}} <: Multipole
    p::V
end

# ╔═╡ 9702c79c-d787-489a-aaf5-56a33ee8f855
epot(a::Monopole, b::Dipole, r::NumVector) = -kₑ ⋄ (a.q * dot(b.p, r) / norm(r)^3);

# ╔═╡ 4f91f30c-fc7e-4dde-a87a-839ba1ca839d
epot(a::Dipole, b::Monopole, r::NumVector) = epot(b, a, -r);

# ╔═╡ 08480f14-a223-4513-970f-887a11ed3397
function epot(a::Dipole, b::Dipole, r::NumVector)
    rn = norm(r)
    
    p_dot_p = dot(a.p, b.p)
    p_r_coupling = dot(a.p, r) * dot(b.p, r)
    
    return kₑ ⋄ (p_dot_p / rn^3 - 3 * p_r_coupling / rn^5)
end

# ╔═╡ 127934a0-3674-4890-b464-d01e8db26606
typeof( epot(Monopole(1), Monopole(1), [1.0f0, 0.0f0, 0.0f0]) )

# ╔═╡ 5be314a6-30e5-4f8b-8b48-706391df0751
md"""
## To get the force, use the force ...

... of dual numbers (forward-mode automatic differentiation):
"""

# ╔═╡ 3bbbdeb4-97d5-4c4e-bf4f-9d4745b34d97
eforce(src::Multipole, trg::Multipole, r::NumVector) =
	- gradient(r -> epot(src, trg, r), r);

# ╔═╡ 4f914448-652a-4fe0-9c61-4ff83d21674c
eforce(Monopole(e), Monopole(e), [1e-10, 0, 0])

# ╔═╡ d1bc9057-596a-4d71-8830-f4d8e45b1bf5
eforce(Monopole(e), Dipole([0, p_H₂O, 0]), [1e-10, 0, 0])

# ╔═╡ fbeb7896-6211-4c24-ae55-b05f67a630d2
eforce(Dipole([0, p_H₂O, 0]), Dipole([0, p_H₂O, 0]), [1e-10, 0, 0])

# ╔═╡ 70d563ee-41e7-48d4-a2ee-959a94cee2f7
md"""
## StaticArrays

Standard Julia arrays are mutable and heap-allocated:
"""

# ╔═╡ 3df4b10d-0c50-41cd-a98d-48f1aabc8978
isbits(Dipole([0, 1, 0]))

# ╔═╡ a4a0ce3d-7f04-4d03-8341-d1016fd2684c
md"""
StaticArrays provides stack-allocated immutable arrays (and more):
"""

# ╔═╡ 697b0309-dc7c-4645-8a85-f0c6f0ce84e7
const Vec3{T<:Real} = SVector{3,T}

# ╔═╡ eabdbcdc-5ea0-4673-854c-bc62609711d6
isbits(Dipole(Vec3(0, 1, 0)))

# ╔═╡ 5986bb3b-a397-4dca-897e-21cc47e22368
md"""
## Let's calculate many times
"""

# ╔═╡ 7640dbdd-fb4a-48ee-8fb1-4a489c90e5d4
mdpot(r) = epot(
	Monopole(Float32(e)),
	Dipole(Vec3(Float32(p_H₂O), 0, 0)),
	r
);

# ╔═╡ f7ca8107-212c-4a11-9226-4374224779a0
mdforce(r) = eforce(Monopole(Float32(e)), Dipole(Vec3(Float32(p_H₂O), 0, 0)), r);

# ╔═╡ af5154b4-11c1-4ac6-a5d7-590857706c38
R = Vec3.(randn(Float32, 10^6), randn(Float32, 10^6), randn(Float32, 10^6))

# ╔═╡ 30f3fae6-a901-4dc7-9eed-694ebbee3357
mdpot.(R)

# ╔═╡ 32355e1d-41f6-4195-9eb5-1323f9984b83
mdforce.(R)

# ╔═╡ 656ef710-7cbf-43f8-9a46-a454b7afba82
md"""
## Let's plot the potential
"""

# ╔═╡ 5f19b41e-46ba-4ff1-a0c8-fe0901467319
let
	Rx = range(-7e-9, 7e-9, length = 10^4); Ry = range(-5e-9, 5e-9, length = 10^4)
	Exy = mdpot.(Vec3.(Rx, Ry', 0))
	Exy_cap = quantile(Exy[:, div(begin+end,2)], 0.95)
	fig = Figure(size = (300, 300))
	ax = Axis(fig[1, 1], title = "Potential", xlabel = "x", ylabel = "y", aspect = DataAspect())
	heatmap!(ax, extrema(Rx), extrema(Ry), Resampler(Exy), colorrange = (-Exy_cap, Exy_cap))
	fig
end

# ╔═╡ 035fc990-97df-4979-b91a-a96840a47394
md"""
## The need ...
"""

# ╔═╡ 3c242d93-9eaf-4e67-ad34-12275dfaeef0
@benchmark sum(mdforce.($R))

# ╔═╡ ef343392-a8d8-42aa-b9a5-4676c1897a26
md"""
## ... for speed
"""

# ╔═╡ 3b189692-d1aa-4e5b-87ad-4498ca11990d
GPUorCPUArray = try
	ENV["JULIA_CUDA_HARD_MEMORY_LIMIT"] = "40%"
	eval(:(import CUDA; CUDA.CuArray))
catch
	Array
end

# ╔═╡ f4cf1b57-dfee-46ae-951a-d8dc54a401a4
R_ondev = GPUorCPUArray(R);

# ╔═╡ faae1faa-c936-4c69-b3a8-004b3a4eeaf1
typeof(R_ondev)

# ╔═╡ 8e1dbbe3-484a-4139-913b-bccce87452fb
typeof(mdforce.(R_ondev))

# ╔═╡ 8f15157c-1fb5-4ef0-988c-f3a7d162b5eb
@benchmark sum(mdforce.($R_ondev))

# ╔═╡ 0f515432-fce3-4719-bfe2-97b2bfd325c6
md"""
## Can I get the math for that?
"""

# ╔═╡ 24326b97-3720-448c-b6ec-b521410920e8
@variables r_sym[1:3]

# ╔═╡ 40437242-ec7f-408a-b164-3c4bbf0908d1
epot(Dipole([1,0,0]), Dipole([1,0,0]), r_sym)

# ╔═╡ 1c55a8d6-a3e7-4037-a8f4-981a625ea4a4
md"""
# Differential equations
"""

# ╔═╡ c49929f6-28c5-4789-9f8a-ea3936d8984c
md"""
## ODE definition

Define the differential equation (as a first-order ODE):
"""

# ╔═╡ ec1e6f60-ad02-4d37-9b6d-17262729668d
function motion_eq(u, p, t)
	x, y, z, v_x, v_y, v_z = u
	r = Vec3(x, y, z)
	dr_dt = Vec3(v_x, v_y, v_z)
	dv_dt = mdforce(r) / p.mass
	du_dt = SVector(dr_dt..., dv_dt...)
	return du_dt
end;

# ╔═╡ e147a98f-aef0-4a90-b8fb-4cc073e590ed
md"""
In Julia [DifferentialEquations](https://docs.sciml.ai/DiffEqDocs/), a differential equation takes a state vector `u`, a (more or less) arbitrary parameter object `p` and the time `t` as arguments an returns the derivative of `u` with respect to `t` (the function can be written to mutate a given `du_dt`).

Note: Can also use [ModelingToolkit](https://docs.sciml.ai/ModelingToolkit/) to specify differential equations symbolically, solvers can then also symbolic math tricks in addition to numerical math.
"""

# ╔═╡ b32a1c8a-eb60-424c-bd09-67268b859868
md"""
## ODE initial conditions and parameters
"""

# ╔═╡ e4ab4f50-d147-4821-923c-7fdf2e837f95
begin
	r0 = Vec3(-1e-9, 1e-9, 0)
	v0 = Vec3(1e5, 0, 0)
	u0 = SVector(r0..., v0...)
end;

# ╔═╡ 00f5cf2c-8c37-4d49-b66a-5ac12f58479c
p = (mass = e_mass,)

# ╔═╡ 7fc6f6f7-423c-48bd-bbdc-a2983b53f5fa
t_span = (0.0, 2e-14)

# ╔═╡ 562bd45d-2cdf-487f-bbeb-a88fcb57ec3b
motion_eq(u0, p, 0)

# ╔═╡ 02c1c4fc-c816-4ae2-97fc-851fa888fcee
md"""
## Solving the ODE
"""

# ╔═╡ 78ac4c5b-183a-4aa1-93b6-11a146f0d6c0
prob = ODEProblem(motion_eq, u0, t_span, p);

# ╔═╡ f6c856eb-2f0e-4da6-a80f-bbd93086d8f6
t_obs = range(t_span..., length = 100);

# ╔═╡ 8c2bf087-2d91-4e54-a6dc-e08daf14f8aa
sol = solve(prob, saveat = t_obs);

# ╔═╡ b5668c14-9cef-47ce-98cd-aa61611b687d
sol.t

# ╔═╡ a4f29719-ee53-4a4d-8d96-47500b9ed9f7
sol.u

# ╔═╡ 422726f0-d3a5-4016-a9e4-5ac232f80f82
function plot_field!(fig, ax, x_span, y_span; lengthscale = 1)
	Rx = range(x_span..., length = 10)
	Ry = range(y_span..., length = 10)
	R = filter(r -> norm(r) > 1e-9, vec(Vec3.(Rx, Ry', 0)))
	Fxy = mdforce.(R)
	arrows2d!(ax, R, Fxy, lengthscale = lengthscale, shaftwidth = 0.1, tipwidth = 5)
	scatter!(ax, [0], [0], markersize = 25)
	fig
end;

# ╔═╡ 5995dac0-c2e8-4945-86b7-c7cbc49d5f9b
md"""
## Plotting the ODE solution
"""

# ╔═╡ 990416d7-cf04-4f9b-bb72-db7f876a7bd4
let T = sol.t, X = sol[1, :], Y = sol[2, :]
	fig = Figure()
	ax = Axis(fig[1, 1], aspect = DataAspect())
	lines!(ax, X, Y, color = T)
	plot_field!(fig, ax, extrema(X), extrema(Y), lengthscale = 0.3e2)
	scatter!(ax, [0], [0], markersize = 25)
	fig
end

# ╔═╡ d9190779-79fb-4b19-b384-40b428d36d40
md"""
## Ensemble-solve in parallel

We want to solve the ODE for many initial conditions in one go:
"""

# ╔═╡ a8932535-88b7-48a4-a5cf-ec0e58cfadd2
U0 = SVector.(
	r0[1], range(0.0 * r0[2], 1.3 * r0[2], length = 20), r0[3],
	v0...
);

# ╔═╡ efa84a4f-f52d-44d8-b0e6-dd1217bc40b4
prob_func = let U0 = U0
	(prob, i, repeat) -> remake(prob, u0 = U0[i])
end;

# ╔═╡ dd5afe21-146b-49f1-8b40-6382291d975d
ensemble_prob = EnsembleProblem(prob, prob_func = prob_func)

# ╔═╡ 9ffb62d5-a97b-4193-b17c-1c8731a6dd6f
sim = solve(ensemble_prob, Tsit5(), EnsembleThreads(), trajectories = length(U0), saveat = range(t_span..., length = 10000))

# ╔═╡ b835f142-999d-4abf-9efc-db53a3035e57
md"""
## The ensemble solution
"""

# ╔═╡ d0a8a9c6-bc15-4242-8e3e-6e7444ef9770
let
	fig = Figure(); ax = Axis(fig[1, 1], aspect = DataAspect())
	plot_field!(fig, ax, (-3e-9, 2e-9), (0e-9, 3e-9), lengthscale = 1e2)
	for sol in sim.u
		lines!(ax, sol[1, :], sol[2, :], color = sol.t)
	end
	fig
end

# ╔═╡ c9f91628-6eb2-4d65-a6f3-a6c207cd45c3

md"""
## Fitting measured data
"""

# ╔═╡ 1e825778-072e-4687-ad44-478ead7310b2
md"""
A statistical forward model:
"""

# ╔═╡ 98fb1da3-dc75-4bd6-a038-8aa636bbd4c1
fwd_model = let t_span = t_span, prob = prob, t_obs = t_obs
	function (pars::NamedTuple)
		u0 = SVector(-1e-9, pars.y0, 0, 1e5, 0, 0)
		p = (mass = pars.mass,)
		sol = solve(remake(prob, u0 = u0, p = p), saveat = t_obs)
		x_expected, y_expected = sol[1, :], sol[2, :]
		@assert length(x_expected) == length(t_obs)
		σ_noise = 0.05e-9
		return BAT.distprod(
			X = MvNormal(x_expected, σ_noise),
			Y = MvNormal(y_expected, σ_noise)
		)
	end
end;

# ╔═╡ 92eadfc1-10d8-411f-9662-5e51d09f4c89
md"""
## Toy data generation
"""

# ╔═╡ 4c89b6b2-7300-4651-a0f6-422c7eaf5b53
pars_truth = (y0 = 0.7e-9, mass = e_mass);

# ╔═╡ bec84a4e-9883-4fc4-9ec9-23f079d826ca
fwd_model(pars_truth)

# ╔═╡ 6a569659-b410-4688-b1ae-3d59656eac60
obs = rand(fwd_model(pars_truth))

# ╔═╡ 32f1dcb7-4a3d-42c1-b3ea-ab42bbab1af6
md"""
## Synthetic observed data
"""

# ╔═╡ bc9516a5-b468-4d75-be44-9b3799f0fa7a
let
    fig, ax = scatter(obs.X, obs.Y, axis = (aspect = DataAspect(),))
	scatter!(ax, [0], [0], markersize = 25)
	fig
end

# ╔═╡ 1de01956-f6fd-4c5a-b52a-63ef9a6bd807
md"""
## Likelihood definition
"""

# ╔═╡ a31fade0-434b-43ad-aad5-9e06742e8a7e
ℒ = Likelihood(fwd_model, obs);

# ╔═╡ 299d034f-8455-4e55-a198-25121d8fe4f3
log(ℒ(pars_truth))

# ╔═╡ beb58af4-99ae-4465-a231-c405788d03e6
md"""
This is equivalent to
"""

# ╔═╡ 71a56ed2-6a0d-4aa9-8126-f7ad1684bd61
logdensityof(fwd_model(pars_truth), obs)

# ╔═╡ 24725e2b-c9e6-43d9-88e2-f88010d392f3
md"""
## Bayesian MAP fit
"""

# ╔═╡ de80b2c7-21d1-4761-a176-c3db9334f8c2
prior = distprod(y0 = Uniform(0e-9, 3e-9), mass = Uniform(0.5*e_mass, 1.5*e_mass))

# ╔═╡ d22b4dec-e725-4263-86e1-293b1e05dc26
posterior = PosteriorMeasure(ℒ, prior)

# ╔═╡ 2f8db157-8ced-4b29-8b8e-275f43795392
logdensityof(posterior, mean(prior))

# ╔═╡ 0c8a3cf2-2ae7-4670-b30c-8a4837f1eac1
pars_map = bat_findmode(posterior, BATContext()).result

# ╔═╡ eb379399-09b5-4a80-8315-399c7867655f
pars_truth

# ╔═╡ 10dd4cc2-43d0-42da-9351-d314be777c15
md"""
## Maximum Likelihood fit
"""

# ╔═╡ ae1818c3-9674-4953-9c33-ef76d6da0806
md"""
We want to maximize
"""

# ╔═╡ c157eb92-8514-4267-8248-a00ad0b17c31
md"""
But ODE solution will be unstable over unrestricted parameters space, so generate parameter space transformation, use prior as fit range:
"""

# ╔═╡ d0d7ad92-fecc-4f54-8b75-259c0c2b1050
_, f_tr = bat_transform(PriorToNormal(), prior, BATContext());

# ╔═╡ 21d45cb0-5389-43da-9fae-fb0793915ec2
md"""
## Let's run an optimizer
"""

# ╔═╡ 2ff860e6-acd6-4a13-adef-dad8a828cf50
md"""
## Maximum-Likelihood fit result
"""

# ╔═╡ 7af24c6d-f2c5-4e6a-9024-28c4fc905ae9
pars_init = (y0 = 0.1e-9, mass = 0.55*e_mass);

# ╔═╡ 84301379-1328-4688-b06d-d58dac883882
(log ∘ ℒ)(pars_init)

# ╔═╡ 3788d5c6-dac3-47de-9e3b-6afab6418a98
pars_init

# ╔═╡ 731f88c8-dd8d-41ae-bb32-baeb9fc1a088
f_tr(pars_init)

# ╔═╡ ae2bcd91-bb2b-49e7-bb1c-5aa2cde0923a
(log ∘ ℒ ∘ InverseFunctions.inverse(f_tr))(f_tr(pars_init))

# ╔═╡ 3734e7ca-d81c-43e5-8b61-f62e6ce7e45d
opt_result = Optim.maximize(log ∘ ℒ ∘ InverseFunctions.inverse(f_tr), f_tr(pars_init));

# ╔═╡ c039595f-7a93-458b-8e47-e044d652987c
opt_result.res

# ╔═╡ 1a4971df-e8c2-41e0-8391-95d2ab027f2e
pars_mll = InverseFunctions.inverse(f_tr)(Optim.maximizer(opt_result))

# ╔═╡ 6f4cbf37-30d7-4de7-ae5f-b42a2422a1d5
pars_truth

# ╔═╡ ea9d8d29-0342-4d0c-a85f-200286065745
md"""
## Fit result visualization
"""

# ╔═╡ 9de46360-8ce9-4f43-a812-98711f5eadbb
let
	fig, ax = scatter(obs.X, obs.Y, label = "obs", axis = (aspect = DataAspect(),), color = :grey)
	map_obs_ex = mean(fwd_model(pars_map))
	lines!(ax, map_obs_ex.X, map_obs_ex.Y, label = "MAP", color = :green, linewidth = 4)
	mll_obs_ex = mean(fwd_model(pars_mll))
	lines!(ax, mll_obs_ex.X, mll_obs_ex.Y, label = "max-ℒ", color = :blue)
	axislegend(ax)
	scatter!(ax, [0], [0], markersize = 25)
	fig
end

# ╔═╡ Cell order:
# ╟─6af6b562-e920-4975-b253-c169ab58456e
# ╟─d47af10e-fabe-454e-9de6-abd95c23de98
# ╟─c3850185-e3be-401a-a3e0-5036ab88c071
# ╟─c683015b-d99e-4447-8bfe-2346c685c926
# ╟─e47f3072-ff1a-405b-9856-140163037ca7
# ╠═12dc0875-42a7-4682-8932-64e156ff9a43
# ╠═336b524e-dfff-4a90-880d-e26f7ce92ed7
# ╠═b0a1abb9-77a3-432c-a6b9-5d87684cb404
# ╟─a7e73711-10d1-445f-840a-c764c7b1fec6
# ╠═64bab154-2ea3-4791-8389-258fde40445d
# ╠═be25fac4-fde3-4ad1-b2f1-a6c9be79a7c6
# ╠═20529b9c-aa29-4f58-b43c-79a2fa372133
# ╟─a7c2630f-4e7f-4fdd-becd-23d40d693b71
# ╠═0c24d0b0-e5e4-4938-991d-87dba8b3229d
# ╠═616cdf55-a19b-456b-b239-eab4c64e8bca
# ╠═3722a2a6-a49a-4f67-8651-09e7504d4496
# ╠═63019cd9-1ceb-4c47-a236-9daf5f21491c
# ╠═918cbb32-da1d-4e66-8b69-f2966e9a3d78
# ╠═127934a0-3674-4890-b464-d01e8db26606
# ╟─f7b5e8ab-f544-4646-9bfa-eace52f29dba
# ╠═a9363a5e-e172-473d-84be-0a49523b928d
# ╠═9702c79c-d787-489a-aaf5-56a33ee8f855
# ╠═4f91f30c-fc7e-4dde-a87a-839ba1ca839d
# ╠═08480f14-a223-4513-970f-887a11ed3397
# ╟─5be314a6-30e5-4f8b-8b48-706391df0751
# ╠═6793cec8-a46d-49b0-aaca-d143ee089f3f
# ╠═3bbbdeb4-97d5-4c4e-bf4f-9d4745b34d97
# ╠═4f914448-652a-4fe0-9c61-4ff83d21674c
# ╠═d1bc9057-596a-4d71-8830-f4d8e45b1bf5
# ╠═fbeb7896-6211-4c24-ae55-b05f67a630d2
# ╟─70d563ee-41e7-48d4-a2ee-959a94cee2f7
# ╠═3df4b10d-0c50-41cd-a98d-48f1aabc8978
# ╟─a4a0ce3d-7f04-4d03-8341-d1016fd2684c
# ╠═ac18c16f-5088-448e-8318-17b2b6cd4f23
# ╠═697b0309-dc7c-4645-8a85-f0c6f0ce84e7
# ╠═eabdbcdc-5ea0-4673-854c-bc62609711d6
# ╟─5986bb3b-a397-4dca-897e-21cc47e22368
# ╠═7640dbdd-fb4a-48ee-8fb1-4a489c90e5d4
# ╠═f7ca8107-212c-4a11-9226-4374224779a0
# ╠═af5154b4-11c1-4ac6-a5d7-590857706c38
# ╠═30f3fae6-a901-4dc7-9eed-694ebbee3357
# ╠═32355e1d-41f6-4195-9eb5-1323f9984b83
# ╟─656ef710-7cbf-43f8-9a46-a454b7afba82
# ╠═d716c0e0-10e8-435e-92ef-1bb170cbf618
# ╠═5f19b41e-46ba-4ff1-a0c8-fe0901467319
# ╟─035fc990-97df-4979-b91a-a96840a47394
# ╠═d17031ec-6292-482f-8972-be57a50cb172
# ╠═3c242d93-9eaf-4e67-ad34-12275dfaeef0
# ╟─ef343392-a8d8-42aa-b9a5-4676c1897a26
# ╟─3b189692-d1aa-4e5b-87ad-4498ca11990d
# ╠═f4cf1b57-dfee-46ae-951a-d8dc54a401a4
# ╠═faae1faa-c936-4c69-b3a8-004b3a4eeaf1
# ╠═8e1dbbe3-484a-4139-913b-bccce87452fb
# ╠═8f15157c-1fb5-4ef0-988c-f3a7d162b5eb
# ╟─0f515432-fce3-4719-bfe2-97b2bfd325c6
# ╠═d79f2aa8-c46e-43c0-8ba0-f110a5e32a06
# ╠═24326b97-3720-448c-b6ec-b521410920e8
# ╠═40437242-ec7f-408a-b164-3c4bbf0908d1
# ╟─1c55a8d6-a3e7-4037-a8f4-981a625ea4a4
# ╟─c49929f6-28c5-4789-9f8a-ea3936d8984c
# ╠═ec1e6f60-ad02-4d37-9b6d-17262729668d
# ╟─e147a98f-aef0-4a90-b8fb-4cc073e590ed
# ╟─b32a1c8a-eb60-424c-bd09-67268b859868
# ╠═e4ab4f50-d147-4821-923c-7fdf2e837f95
# ╠═00f5cf2c-8c37-4d49-b66a-5ac12f58479c
# ╠═7fc6f6f7-423c-48bd-bbdc-a2983b53f5fa
# ╠═562bd45d-2cdf-487f-bbeb-a88fcb57ec3b
# ╟─02c1c4fc-c816-4ae2-97fc-851fa888fcee
# ╠═330e7511-92bd-43b8-bebb-2f9678f30c3f
# ╠═78ac4c5b-183a-4aa1-93b6-11a146f0d6c0
# ╠═f6c856eb-2f0e-4da6-a80f-bbd93086d8f6
# ╠═8c2bf087-2d91-4e54-a6dc-e08daf14f8aa
# ╠═b5668c14-9cef-47ce-98cd-aa61611b687d
# ╠═a4f29719-ee53-4a4d-8d96-47500b9ed9f7
# ╟─422726f0-d3a5-4016-a9e4-5ac232f80f82
# ╟─5995dac0-c2e8-4945-86b7-c7cbc49d5f9b
# ╠═990416d7-cf04-4f9b-bb72-db7f876a7bd4
# ╟─d9190779-79fb-4b19-b384-40b428d36d40
# ╠═a8932535-88b7-48a4-a5cf-ec0e58cfadd2
# ╠═efa84a4f-f52d-44d8-b0e6-dd1217bc40b4
# ╠═dd5afe21-146b-49f1-8b40-6382291d975d
# ╠═9ffb62d5-a97b-4193-b17c-1c8731a6dd6f
# ╟─b835f142-999d-4abf-9efc-db53a3035e57
# ╠═d0a8a9c6-bc15-4242-8e3e-6e7444ef9770
# ╟─c9f91628-6eb2-4d65-a6f3-a6c207cd45c3
# ╟─1e825778-072e-4687-ad44-478ead7310b2
# ╠═8b0c2d24-3a23-4854-bf29-d9400620fa6c
# ╠═98fb1da3-dc75-4bd6-a038-8aa636bbd4c1
# ╟─92eadfc1-10d8-411f-9662-5e51d09f4c89
# ╠═4c89b6b2-7300-4651-a0f6-422c7eaf5b53
# ╠═bec84a4e-9883-4fc4-9ec9-23f079d826ca
# ╠═6a569659-b410-4688-b1ae-3d59656eac60
# ╟─32f1dcb7-4a3d-42c1-b3ea-ab42bbab1af6
# ╠═bc9516a5-b468-4d75-be44-9b3799f0fa7a
# ╟─1de01956-f6fd-4c5a-b52a-63ef9a6bd807
# ╠═96dd2d0c-cd89-4945-953a-e89cfea501c1
# ╠═a31fade0-434b-43ad-aad5-9e06742e8a7e
# ╠═299d034f-8455-4e55-a198-25121d8fe4f3
# ╟─beb58af4-99ae-4465-a231-c405788d03e6
# ╠═71a56ed2-6a0d-4aa9-8126-f7ad1684bd61
# ╟─24725e2b-c9e6-43d9-88e2-f88010d392f3
# ╠═de80b2c7-21d1-4761-a176-c3db9334f8c2
# ╠═d22b4dec-e725-4263-86e1-293b1e05dc26
# ╠═2f8db157-8ced-4b29-8b8e-275f43795392
# ╠═0c8a3cf2-2ae7-4670-b30c-8a4837f1eac1
# ╠═eb379399-09b5-4a80-8315-399c7867655f
# ╟─10dd4cc2-43d0-42da-9351-d314be777c15
# ╟─ae1818c3-9674-4953-9c33-ef76d6da0806
# ╠═84301379-1328-4688-b06d-d58dac883882
# ╟─c157eb92-8514-4267-8248-a00ad0b17c31
# ╠═3788d5c6-dac3-47de-9e3b-6afab6418a98
# ╠═0d20c929-3fd6-4f36-943d-e217fdd21229
# ╠═d0d7ad92-fecc-4f54-8b75-259c0c2b1050
# ╠═731f88c8-dd8d-41ae-bb32-baeb9fc1a088
# ╠═ae2bcd91-bb2b-49e7-bb1c-5aa2cde0923a
# ╟─21d45cb0-5389-43da-9fae-fb0793915ec2
# ╠═8603319f-e644-4665-bfe8-bee467dfcfbc
# ╠═3734e7ca-d81c-43e5-8b61-f62e6ce7e45d
# ╠═c039595f-7a93-458b-8e47-e044d652987c
# ╟─2ff860e6-acd6-4a13-adef-dad8a828cf50
# ╠═7af24c6d-f2c5-4e6a-9024-28c4fc905ae9
# ╠═1a4971df-e8c2-41e0-8391-95d2ab027f2e
# ╠═6f4cbf37-30d7-4de7-ae5f-b42a2422a1d5
# ╟─ea9d8d29-0342-4d0c-a85f-200286065745
# ╠═9de46360-8ce9-4f43-a812-98711f5eadbb
