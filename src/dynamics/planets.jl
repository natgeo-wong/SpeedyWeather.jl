"""
$(TYPEDSIGNATURES)
Create a struct `Earth<:AbstractPlanet`, with the following physical/orbital
characteristics. Note that `radius` is not part of it as this should be chosen
in `SpectralGrid`. Keyword arguments are
$(TYPEDFIELDS)
"""
Base.@kwdef struct Earth <: AbstractPlanet

    "angular frequency of Earth's rotation [rad/s]"
    rotation::Float64 = 7.29e-5
    
    "gravitational acceleration [m/s^2]"
    gravity::Float64 = 9.81                 
    
    "switch on/off daily cycle"
    daily_cycle::Bool = true
    
    "Seconds in a daily rotation"
    length_of_day::Second = Hour(24)             

    "switch on/off seasonal cycle"
    seasonal_cycle::Bool = true

    "Seconds in an orbit around the sun"
    length_of_year::Second = Day(365.25)
    
    "time of spring equinox (year irrelevant)"
    equinox::DateTime = DateTime(2000,3,20) 

    "angle [˚] rotation axis tilt wrt to orbit"
    axial_tilt::Float64 = 23.4

    "Total solar irradiance at the distance of 1 AU [W/m²]"
    solar_constant::Float64 = 1365
end

function Base.show(io::IO,planet::AbstractPlanet)
    println(io,"$(typeof(planet)) <: AbstractPlanet")
    keys = propertynames(planet)
    print_fields(io,planet,keys)
end