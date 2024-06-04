module ooi_types

using Dates
export Glider

mutable struct Glider
    trajectory::String
    wmo_id::String
    profile_id::Vector{Union{Missing, Int32}}
    time::Array{DateTime}
    lat::Array{Float64}
    lon::Array{Float64}
    pres::Array{Float64}
    z::Array{Float64}
    backscatter::Array{Float64}
    CDOM::Array{Float64}
    chlorophyll::Array{Float64}
    PAR::Array{Float64}
    dO::Array{Float64}
    dOsatn::Array{Float64}
    temp::Array{Float64}
    cond::Array{Float64}
    salt::Array{Float64}
    rho::Array{Float64}
    source_file::Array{String}
end

mutable struct MooringCTD
    station::String
    time::Array{DateTime}
    lat::Array{Float64}
    lon::Array{Float64}
    z::Array{Float64}
    temp::Array{Float64}
    salt::Array{Float64}
    rho::Array{Float64}
end

end