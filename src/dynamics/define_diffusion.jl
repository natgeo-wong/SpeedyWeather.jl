Base.@kwdef struct HyperDiffusion <: DiffusionParameters
    # hyperdiffusion for temp, vor, div everywhere
    power::Int = 4                              # Power n of Laplacian in horizontal diffusion ∇²ⁿ
    time_scale::Float64 = 2.5                   # Diffusion time scale [hrs] for temp, vor, div
    
    # additional diffusion in stratosphere
    power_stratosphere::Int = 1                 # additional ∇² for stratosphere
    time_scale_stratosphere::Float64 = 12       # associated time scale

    # reduce time scale of diffusion linearly with increasing model resolution?
    scale_with_resolution::Bool = true      # e.g. T31 = 2.5hrs diffusion time scale, T63 = 1.25 hrs
end

""" 
    HD = HorizontalDiffusion(...)

Horizontal Diffusion struct containing all the preallocated arrays for the calculation
of horizontal diffusion."""
struct HorizontalDiffusion{NF<:AbstractFloat}   # Number format NF
    
    # Explicit part of the (hyper) diffusion, precalculated for each spherical harm degree
    ∇²ⁿ::Vector{NF}                             # everywhere
    ∇²ⁿ_stratosphere::Vector{NF}                # +extra diffusion in the stratosphere
    
    # Implicit part
    ∇²ⁿ_implicit::Vector{NF}
    ∇²ⁿ_implicit_stratosphere::Vector{NF}
end

"""
    HD = HorizontalDiffusion(::Parameters,::GeoSpectral,::Boundaries)

Generator function for a HorizontalDiffusion struct `HD`. Precalculates damping matrices for
horizontal hyperdiffusion for temperature, vorticity and divergence, with an implicit term
and an explicit term. Also precalculates correction terms (horizontal and vertical) for
temperature and humidity.
"""
function HorizontalDiffusion(   scheme::HyperDiffusion,
                                P::Parameters,
                                C::DynamicsConstants,
                                S::SpectralTransform{NF}) where NF
    @unpack lmax,mmax = S
    @unpack radius = P.planet
    @unpack power, power_stratosphere = scheme
    @unpack Δt = C

    # reuce diffusion time scale (=increase diffusion) with resolution?
    if scheme.scale_with_resolution
        # use values in scheme for T31 (=32 here) and decrease linearly with lmax+1
        time_scale = scheme.time_scale * (32/(lmax+1))
        time_scale_stratosphere = scheme.time_scale_stratosphere * (32/(lmax+1))
    else
        @unpack time_scale, time_scale_stratosphere = scheme
    end

    # Diffusion is applied by multiplication of the eigenvalues of the Laplacian -l*(l+1)
    # normalise by the largest eigenvalue -lmax*(lmax+1) such that the highest wavenumber lmax
    # is dampened to 0 at the given time scale raise to a power of the Laplacian for hyperdiffusion
    # (=more scale-selective for smaller wavenumbers)
    largest_eigenvalue = -lmax*(lmax+1)

    # PREALLOCATE as vector as only dependend on degree l
    # Damping coefficients for explicit part of the diffusion (=ν∇²ⁿ)
    ∇²ⁿ = zeros(NF,lmax+2)                  # for temperature and vorticity (explicit)
    ∇²ⁿ_stratosphere = zeros(NF,lmax+2)     # for divergence (explicit)

    # Implicit part (= 1/(1-2Δtν∇²ⁿ))
    ∇²ⁿ_implicit = zeros(NF,lmax+2)
    ∇²ⁿ_implicit_stratosphere = zeros(NF,lmax+2)

    # PRECALCULATE for every degree l
    for l in 0:lmax+1
        eigenvalue_norm = -l*(l+1)/largest_eigenvalue       # normal diffusion ∇², power=1

        # Explicit part (=-ν∇²ⁿ), time scales to damping frequencies [1/s] times norm. eigenvalue
        # time scale [hrs] *3600-> [s]
        ∇²ⁿ[l+1] = -eigenvalue_norm^power/(3600*time_scale)*radius
        ∇²ⁿ_implicit[l+1] = 1/(1-2Δt*∇²ⁿ[l+1])              # and implicit part of the diffusion (= 1/(1-2Δtν∇²ⁿ))

        # add additional diffusion for stratosphere
        ∇²ⁿ_stratosphere[l+1] = ∇²ⁿ[l+1] - 
            norm_eigenvalue^power_stratosphere/(3600*time_scale_stratosphere)*radius
        ∇²ⁿ_implicit_stratosphere[l+1] = 1/(1-2Δt*∇²ⁿ_stratosphere[l+1])
    end

    return HorizontalDiffusion(∇²ⁿ,∇²ⁿ_stratosphere,∇²ⁿ_implicit,∇²ⁿ_implicit_stratosphere)
end