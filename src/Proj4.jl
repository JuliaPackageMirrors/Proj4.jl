VERSION >= v"0.4.0-dev+6521" && __precompile__(true)
# The above causes the warning: eval from module __anon__ to Proj4

module Proj4
using Compat
import Compat.String

const _projdeps = joinpath(dirname(@__FILE__),"..","deps","deps.jl")
if isfile(_projdeps)
    include(_projdeps)
else
    error("Proj4 is not properly installed. Please run Pkg.build(\"Proj4\")")
end

export Projection, # proj_types.jl
       transform, transform!,  # proj_functions.jl
       is_latlong, is_geocent, compare_datums, spheroid_params,
       xy2lonlat, xy2lonlat!, lonlat2xy, lonlat2xy!

include("projection_codes.jl") # ESRI and EPSG projection strings
include("proj_capi.jl") # low-level C-facing functions (corresponding to src/proj_api.h)

function _version()
    m = match(r"(\d+).(\d+).(\d+),.+", _get_release())
    VersionNumber(parse(Int, m[1]), parse(Int, m[2]), parse(Int, m[3]))
end

"Parsed version number for the underlying version of libproj"
const version = _version()

# Detect underlying libproj support for geodesic calculations
const has_geodesic_support = version >= v"4.9.0"

if has_geodesic_support
    export geod_direct, geod_inverse, geod_destination, geod_distance
    include("proj_geodesic.jl") # low-level C-facing functions (corresponding to src/geodesic.h)
end

include("proj_types.jl") # type definitions for proj objects
include("proj_functions.jl") # user-facing proj functions

"Get a global error string in human readable form"
error_message() = _strerrno()

end # module
