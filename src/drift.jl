# constant and time-varying drifts

abstract type AbstractDrift end
getdt(drift::AbstractDrift) = drift.dt

struct ConstDrift <: AbstractDrift
    mu::Float64
    dt::Float64

    function ConstDrift(mu::Real, dt::Real)
        dt > zero(dt) || error("dt needs to be positive")
        new(float(mu), float(dt))
    end
end
getmu(d::ConstDrift, n::Int) = d.mu
getmu(d::ConstDrift) = d.mu
getm(d::ConstDrift, n::Int) = (n-1) * d.dt * d.mu
getmaxn(d::ConstDrift) = typemax(Int)

struct VarDrift <: AbstractDrift
    mu::Vector{Float64}
    m::Vector{Float64}
    dt::Float64

    function VarDrift{T <: Real}(mu::AbstractVector{T}, dt::Real)
        dt > zero(dt) || error("dt needs to be positive")
        length(mu) > 0 || error("mu needs to be of non-zero length")
        new(mu, [0.0; cumsum(mu[1:(end-1)]) * float(dt)], float(dt))
    end
    function VarDrift{T <: Real}(mu::AbstractVector{T}, dt::Real, maxt::Real)
        dt > zero(dt) || error("dt needs to be positive")
        maxt >= dt || error("maxt needs to be at least as large as dt")
        n = length(0:dt:maxt)
        nmu = length(mu)
        nmu < n ? VarDrift([mu; fill(mu[end], n - nmu)], dt) : VarDrift(mu[1:n], dt)
    end
end
getmu(d::VarDrift, n::Int) = d.mu[n]
getm(d::VarDrift, n::Int) = d.m[n]
getmaxn(d::VarDrift) = length(d.mu)
