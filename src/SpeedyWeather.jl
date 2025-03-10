module SpeedyWeather

# STRUCTURE
using DocStringExtensions

# NUMERICS
import Primes
import Random
import FastGaussQuadrature
import LinearAlgebra: LinearAlgebra, Diagonal

# GPU, PARALLEL
import Base.Threads: Threads, @threads
import FLoops: FLoops, @floop
import KernelAbstractions
import CUDA: CUDA, CUDAKernels
import Adapt: Adapt, adapt, adapt_structure

# INPUT OUTPUT
import TOML
import Dates: Dates, DateTime, Period, Millisecond, Second, Minute, Hour, Day
import Printf: Printf, @sprintf
import NCDatasets: NCDatasets, NCDataset, defDim, defVar
import JLD2: jldopen
import CodecZlib
import BitInformation: round, round!
import UnicodePlots
import ProgressMeter

# to avoid a `using Dates` to pass on DateTime arguments
export DateTime, Second, Minute, Hour, Day

# EXPORT MONOLITHIC INTERFACE TO SPEEDY
export  run_speedy,
        run_speedy!,
        initialize_speedy,
        initialize!,
        run!

export  NoVerticalCoordinates,
        SigmaCoordinates,
        SigmaPressureCoordinates

# EXPORT MODELS
export  Barotropic,             # abstract
        ShallowWater,
        PrimitiveEquation,
        PrimitiveDry,
        PrimitiveWet,
        ModelSetup

export  BarotropicModel,        # concrete
        ShallowWaterModel,
        PrimitiveDryModel,
        PrimitiveWetModel

export  Earth,
        EarthAtmosphere

# EXPORT GRIDS
export  SpectralGrid,
        Geometry

export  LowerTriangularMatrix,
        FullClenshawGrid,
        FullGaussianGrid,
        FullHEALPixGrid,
        FullOctaHEALPixGrid,
        OctahedralGaussianGrid,
        OctahedralClenshawGrid,
        HEALPixGrid,
        OctaHEALPixGrid,
        plot

export  Leapfrog

# EXPORT OROGRAPHIES
export  NoOrography,
        EarthOrography,
        ZonalRidge

# NUMERICS
export  HyperDiffusion,
        ImplicitShallowWater,
        ImplicitPrimitiveEq

# EXPORT INITIAL CONDITIONS
export  StartFromFile,
        StartFromRest,
        ZonalJet,
        ZonalWind,
        StartWithRandomVorticity

# EXPORT TEMPERATURE RELAXATION SCHEMES
export  NoTemperatureRelaxation,
        HeldSuarez,
        JablonowskiRelaxation

# EXPORT BOUNDARY LAYER SCHEMES
export  NoBoundaryLayerDrag,
        LinearDrag,
        QuadraticDrag

# EXPORT FORCING
export  forcing!,
        JetStreamForcing,
        AbstractForcing

# EXPORT DRAG
export  drag!,
        AbstractDrag

# EXPORT VERTICAL DIFFUSION
export  NoVerticalDiffusion,
        VerticalLaplacian

# PRECIPITATOIN
export  SpeedyCondensation,
        SpeedyConvection

# EXPORT STRUCTS
export  DynamicsConstants,
        SpectralTransform,
        Boundaries,
        PrognosticVariables,
        PrognosticVariablesLayer,
        DiagnosticVariables,
        DiagnosticVariablesLayer,
        ColumnVariables

# EXPORT SPECTRAL FUNCTIONS
export  SpectralTransform,
        spectral,
        gridded,
        spectral_truncation

export  OutputWriter, Feedback
        
include("utility_functions.jl")

# LowerTriangularMatrices for spherical harmonics
export LowerTriangularMatrices
include("LowerTriangularMatrices/LowerTriangularMatrices.jl")
using .LowerTriangularMatrices

# RingGrids
export RingGrids
include("RingGrids/RingGrids.jl")
using .RingGrids

# SpeedyTransforms
export SpeedyTransforms
include("SpeedyTransforms/SpeedyTransforms.jl")
using .SpeedyTransforms

# Utility for GPU / KernelAbstractions
include("gpu.jl")                               

# GEOMETRY CONSTANTS ETC
include("abstract_types.jl")
include("dynamics/vertical_coordinates.jl")
include("dynamics/spectral_grid.jl")
include("dynamics/vertical_interpolation.jl")
include("dynamics/planets.jl")
include("dynamics/atmospheres.jl")
include("dynamics/constants.jl")
include("dynamics/orography.jl")
include("physics/land_sea_mask.jl")

# VARIABLES
include("dynamics/prognostic_variables.jl")
include("physics/define_column.jl")
include("dynamics/diagnostic_variables.jl")

# MODEL COMPONENTS
include("dynamics/time_integration.jl")
include("dynamics/forcing.jl")
include("dynamics/drag.jl")
include("dynamics/geopotential.jl")
include("dynamics/initial_conditions.jl")
include("dynamics/horizontal_diffusion.jl")
include("dynamics/vertical_advection.jl")
include("dynamics/implicit.jl")
include("dynamics/scaling.jl")
include("dynamics/tendencies.jl")
include("dynamics/hole_filling.jl")

# PARAMETERIZATIONS
include("physics/tendencies.jl")
include("physics/column_variables.jl")
include("physics/thermodynamics.jl")
include("physics/boundary_layer.jl")
include("physics/temperature_relaxation.jl")
include("physics/vertical_diffusion.jl")
include("physics/large_scale_condensation.jl")
include("physics/surface_fluxes.jl")
include("physics/convection.jl")
include("physics/zenith.jl")
include("physics/shortwave_radiation.jl")
include("physics/longwave_radiation.jl")
include("physics/pretty_printing.jl")

# OCEAN AND LAND
include("physics/ocean.jl")
include("physics/land.jl")

# MODELS
include("dynamics/models.jl")

# OUTPUT
include("output/output.jl")                     # defines Output
include("output/feedback.jl")                   # defines Feedback
include("output/plot.jl")

# INTERFACE
include("run_speedy.jl")
end