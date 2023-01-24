function tracegeodesics(
    m::AbstractMetricParams,
    u,
    v,
    accretion_geometry::AbstractAccretionGeometry,
    time_domain::NTuple{2};
    callback = nothing,
    gtol = 1e-2,
    kwargs...,
)
    cbs = add_collision_callback(callback, accretion_geometry; gtol = gtol)
    tracegeodesics(m, u, v, time_domain; callback = cbs, kwargs...)
end

function rendergeodesics(
    m::AbstractMetricParams,
    u,
    accretion_geometry::AbstractAccretionGeometry,
    max_time::Number;
    callback = nothing,
    gtol = 1e-2,
    kwargs...,
)
    cbs = add_collision_callback(callback, accretion_geometry; gtol = gtol)
    rendergeodesics(m, u, max_time; callback = cbs, kwargs...)
end

function prerendergeodesics(
    m::AbstractMetricParams,
    init_pos,
    accretion_geometry::AbstractAccretionGeometry,
    max_time::Number;
    callback = nothing,
    gtol = 1e-2,
    kwargs...,
)
    cbs = add_collision_callback(callback, accretion_geometry; gtol = gtol)
    prerendergeodesics(m, init_pos, max_time; callback = cbs, kwargs...)
end

function add_collision_callback(callback::C, accretion_geometry; gtol) where {C}
    if C <: Nothing
        build_collision_callback(accretion_geometry; gtol = gtol)
    elseif C <: Tuple
        (callback..., build_collision_callback(accretion_geometry; gtol = gtol))
    elseif C <: SciMLBase.DECallback
        (callback, build_collision_callback(accretion_geometry; gtol = gtol))
    else
        error("Unknown callback type $C")
    end
end

"""
    build_collision_callback(m::AbstractAccretionGeometry{T})

Generates the callback used for the integration. Returns a `Function`, with the fingerprint
```julia
function callback(u, λ, integrator)::Bool
    # ...
end
```
"""
function build_collision_callback(g::AbstractAccretionGeometry; gtol)
    DiscreteCallback(
        (u, λ, integrator) ->
            intersects_geometry(g, line_element(u, integrator), integrator),
        terminate_with_status!(StatusCodes.IntersectedWithGeometry),
    )
end
