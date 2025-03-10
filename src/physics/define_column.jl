"""
Mutable struct that contains all prognostic (copies thereof) and diagnostic variables in a single column
needed to evaluate the physical parametrizations. For now the struct is mutable as we will reuse the struct
to iterate over horizontal grid points. Every column vector has `nlev` entries, from [1] at the top to
[end] at the lowermost model level at the planetary boundary layer.
$(TYPEDFIELDS)"""
Base.@kwdef mutable struct ColumnVariables{NF<:AbstractFloat} <: AbstractColumnVariables{NF}

    # DIMENSIONS
    const nlev::Int = 0                     # number of vertical levels
    const nband::Int = 0                    # number of radiation bands, needed for radiation
    const n_stratosphere_levels::Int = 0    # number of stratospheric levels, needed for radiation
    
    # COORDINATES
    ij::Int = 0                             # grid-point index
    jring::Int = 0                          # latitude ring the column is on
    lond::NF = 0                            # longitude
    latd::NF = 0                            # latitude, needed for shortwave radiation
    land_fraction::NF = 0                   # fraction of the column that is over land
    orography::NF = 0                       # orography height [m]

    # PROGNOSTIC VARIABLES
    const u::Vector{NF} = zeros(NF,nlev)            # zonal velocity [m/s]
    const v::Vector{NF} = zeros(NF,nlev)            # meridional velocity [m/s]
    const temp::Vector{NF} = zeros(NF,nlev)         # absolute temperature [K]
    const humid::Vector{NF} = zeros(NF,nlev)        # specific humidity [kg/kg]

    # (log) pressure per layer, surface is prognostic, last element here, but precompute other layers too
    const ln_pres::Vector{NF} = zeros(NF,nlev+1)    # logarithm of pressure [log(Pa)]
    const pres::Vector{NF} = zeros(NF,nlev+1)       # pressure [Pa]

    # TENDENCIES to accumulate the parametrizations into
    const u_tend::Vector{NF} = zeros(NF,nlev)                   # zonal velocity [m/s²]
    const v_tend::Vector{NF} = zeros(NF,nlev)                   # meridional velocity [m/s²]
    const temp_tend::Vector{NF} = zeros(NF,nlev)                # absolute temperature [K/s]
    const humid_tend::Vector{NF} = zeros(NF,nlev)               # specific humidity [kg/kg/s]

    # FLUXES, arrays to be used for various parameterizations, on half levels incl top and bottom
    const flux_u_upward::Vector{NF} = zeros(NF,nlev+1)
    const flux_u_downward::Vector{NF} = zeros(NF,nlev+1)

    const flux_v_upward::Vector{NF} = zeros(NF,nlev+1)
    const flux_v_downward::Vector{NF} = zeros(NF,nlev+1)

    const flux_temp_upward::Vector{NF} = zeros(NF,nlev+1)
    const flux_temp_downward::Vector{NF} = zeros(NF,nlev+1)
    
    const flux_humid_upward::Vector{NF} = zeros(NF,nlev+1)
    const flux_humid_downward::Vector{NF} = zeros(NF,nlev+1)

    # boundary layer
    boundary_layer_depth::Int = 0
    boundary_layer_drag::NF = 0
    surface_geopotential::NF = 0
    surface_u::NF = 0
    surface_v::NF = 0
    surface_temp::NF = 0
    surface_humid::NF = 0
    surface_wind_speed::NF = 0
    skin_temperature_sea::NF = 0
    skin_temperature_land::NF = 0
    soil_moisture_availability::NF = 0

    # THERMODYNAMICS
    surface_air_density::NF = 0
    const sat_humid::Vector{NF} = zeros(NF,nlev)                # Saturation specific humidity [kg/kg]
    const dry_static_energy::Vector{NF} = zeros(NF,nlev)        # Dry static energy [J/kg]
    const temp_virt::Vector{NF} = zeros(NF,nlev)                # virtual temperature [K]
    const bulk_richardson::Vector{NF} = zeros(NF,nlev)          # bulk richardson number [1]
    const geopot::Vector{NF} = zeros(NF,nlev)                   # gepotential height [m]

    # CONVECTION AND PRECIPITATION
    cloud_top::Int = nlev + 1               # layer index k of top-most layer with clouds
    precip_convection::NF = 0               # Precipitation due to convection [m]
    precip_large_scale::NF = 0              # precipitation due to large-scale condensation [m]
end