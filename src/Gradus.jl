module Gradus

import Base: in
using Base.Threads: @threads
using LinearAlgebra: ×, ⋅, norm, det

using DocStringExtensions
using Parameters

using SciMLBase
using OrdinaryDiffEq
using DiffEqCallbacks
using StaticArrays
using Optim
using Interpolations
using VoronoiCells
using FiniteDifferences
using Roots
using ProgressMeter

using Accessors: @set
using Tullio: @tullio

import ThreadsX
import ForwardDiff
import GeometryBasics
import Surrogates

include("GradusBase/GradusBase.jl")
import .GradusBase:
    E,
    Lz,
    AbstractMetricParams,
    metric_params,
    metric,
    getgeodesicpoint,
    GeodesicPoint,
    AbstractGeodesicPoint,
    vector_to_local_sky,
    AbstractMetricParams,
    geodesic_eq,
    geodesic_eq!,
    constrain,
    inner_radius,
    metric_type,
    metric_components,
    inverse_metric_components,
    unpack_solution

export AbstractMetricParams,
    getgeodesicpoint,
    GeodesicPoint,
    AbstractGeodesicPoint,
    AbstractMetricParams,
    constrain,
    inner_radius,
    metric_components,
    inverse_metric_components

"""
    abstract type AbstractPointFunction

Abstract super type for point functions. Must have `f::Function` field.
"""
abstract type AbstractPointFunction end

abstract type AbstractCacheStrategy end
abstract type AbstractRenderCache{M,T} end

abstract type AbstractSkyDomain end
abstract type AbstractGenerator end

"""
    abstract type AbstractAccretionGeometry{T}

Supertype of all accretion geometry. Concrete sub-types must minimally implement
- [`in_nearby_region`](@ref)
- [`has_intersect`](@ref)

Alternativey, for more control, either [`intersects_geometry`](@ref) or [`build_collision_callback`](@ref)
may be implemented for a given geometry type.

Geometry intersection calculations are performed by strapping discrete callbacks to the integration
procedure.
"""
abstract type AbstractAccretionGeometry{T} end

"""
    abstract type AbstractAccretionDisc{T} <: AbstractAccretionGeometry{T}

Supertype for accretion spherically symmetric geometry, where certain optimizing assumptions
may be made.
"""
abstract type AbstractAccretionDisc{T} <: AbstractAccretionGeometry{T} end

"""
    AbstractDiscProfile

Abstract type for binning structures over discs (e.g., radial bins, voronoi).
"""
abstract type AbstractDiscProfile end

abstract type AbstractCoronaModel{T} end

abstract type AbstractDirectionSampler{SkyDomain,Generator} end

include("tracing/tracing.jl")
include("tracing/constraints.jl")
include("tracing/callbacks.jl")
include("tracing/utility.jl")

include("tracing/method-implementations/auto-diff.jl")

include("rendering/cache.jl")
include("rendering/rendering.jl")
include("rendering/utility.jl")

include("tracing/method-implementations/first-order.jl")

include("point-functions.jl")

include("orbits/circular-orbits.jl")
include("orbits/orbit-discovery.jl")
include("orbits/orbit-interpolations.jl")

include("accretion-geometry/geometry.jl")
include("accretion-geometry/intersections.jl")
include("accretion-geometry/discs.jl")
include("accretion-geometry/meshes.jl")
include("accretion-geometry/bootstrap.jl")

include("orbits/emission-radii.jl")

include("corona-to-disc/sky-geometry.jl")
include("corona-to-disc/corona-models.jl")
include("corona-to-disc/disc-profiles.jl")
include("corona-to-disc/transfer-functions.jl")

include("metrics/boyer-lindquist-ad.jl")
include("metrics/boyer-lindquist-fo.jl")
include("metrics/johannsen-ad.jl")
include("metrics/johannsen-psaltis-ad.jl")
include("metrics/morris-thorne-ad.jl")
include("metrics/kerr-refractive-ad.jl")
include("metrics/dilaton-axion-ad.jl")

include("special-radii.jl")
include("redshift.jl")
include("const-point-functions.jl")

export AbstractPointFunction,
    AbstractCacheStrategy,
    AbstractRenderCache,
    AbstractSkyDomain,
    AbstractGenerator,
    AbstractAccretionGeometry,
    AbstractAccretionDisc,
    AbstractDiscProfile,
    AbstractDirectionSampler

# precompilation help
precompile(
    tracegeodesics,
    (
        BoyerLindquistAD{Float64},
        SVector{4,Float64},
        SVector{4,Float64},
        Tuple{Float64,Float64},
    ),
)
precompile(
    rendergeodesics,
    (BoyerLindquistAD{Float64}, SVector{4,Float64}, GeometricThinDisc{Float64}, Float64),
)

end # module
