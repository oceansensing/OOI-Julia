
# DG 2024-03-22: Load data from OOI Coastal Pioneer Upper Inshore Profiler Mooring
# 
# Note: The script gives an example of loading data from one of OOI's moorings. Please use OOI Data Explorer to find other datasets.
#
# for Julia: NCDatasets, HTTP, DataFrames, PyCall, Dates, Missings must be installed
# for python: erddapy, and netCDF4 must be installed, and PyCall must be setup to use the correct version of python

using NCDatasets, HTTP, DataFrames, PyCall, Dates, Missings

# Define a function to convert Missing to NaN in Julia
function missing2nan(varin)
    varin = collect(varin);
    if (typeof(varin) == Vector{Union{Missing, Int64}}) | (typeof(varin) == Matrix{Union{Missing, Int64}})
        varout = Array{Float64}(undef,size(collect(varin)));
        varintypes = typeof.(varin);
        notmissind = findall(varintypes .!= Missing);
        missind = findall(varintypes .== Missing); 
        if isempty(notmissind) != true  
            varout[notmissind] .= Float64.(varin[notmissind]);
        end
        if isempty(missind) != true
            varout[missind] .= NaN;
        end
    elseif (typeof(varin) == Vector{Union{Missing, Float64}}) | (typeof(varin) == Matrix{Union{Missing, Float64}})
        varout = Float64.(collect(Missings.replace(varin, NaN)));
    elseif (typeof(varin) == Vector{Missing}) | (typeof(varin) == Matrix{Missing})
        varout = Array{Float64}(undef,size(collect(varin)));
        varout .= NaN; 
    else
        varout = varin;
    end

    return varout
end

# Load the ERDDAP python package to access the OOI data
ERDDAP = pyimport("erddapy").ERDDAP

#server = "http://erddap.dataexplorer.oceanobservatories.org/erddap"; # mooring data server
server = "https://gliders.ioos.us/erddap" # glider data server
e = ERDDAP(server=server, protocol="tabledap"); 

e.response = "nc"
e.dataset_id = "cp_387-20240405T1751"; 

#data_url = "https://gliders.ioos.us/erddap/tabledap/cp_387-20240405T1751.nc?longitude,latitude,profile_id&time%3E=2024-05-10T00%3A00%3A00Z&time%3C=2024-05-17T00%3A00%3A00Z&.draw=markers&.marker=5%7C5&.color=0x000000&.colorBar=%7C%7C%7C%7C%7C&.bgColor=0xffccccff";
datadir = "/Users/gong/oceansensing Dropbox/C2PO/Data/OOI/";

variables_glider = [
    "trajectory",
    "wmo_id",
    "profile_id",
    "time",
    "latitude",
    "longitude",
    "precise_time",
    "precise_lon",
    "precise_lat",
    "pressure",
    "depth",    
    "backscatter",
    "CDOM",
    "chlorophyll",
    "PAR",
    "instrument_ctd",
    "instrument_oxygen",
    "instrument_flbbcd",
    "dissolved_oxygen",
    "oxygen_saturation",
    "temperature",
    "conductivity",
    "salinity",
    "density",
    "radiation_wavelength",
    "source_file"
]

e.variables = variables_glider;

e.constraints = Dict(
    "time>=" => "2024-04-01T00:00:00Z",
    "time<=" => "2024-06-03T04:00:00Z",
    "depth>=" => 0.0,
    "depth<=" => 2000.0,
);

# download the data from ERDDAP server in netCDF format
dataurl = e.get_download_url();
datalocalpath = joinpath(datadir, e.dataset_id * ".nc"); 
HTTP.download(dataurl, datalocalpath, verbose=true);

# load the data from the netCDF file using NCDatasets library
ds = NCDatasets.NCDataset(datalocalpath);

trajectory = string(ds["trajectory"][:,1]...);
wmo_id = string(ds["wmo_id"][:,1]...); 
profile_id = ds["profile_id"][:];
time = missing2nan(ds["precise_time"][:]);
lon = missing2nan(ds["precise_lon"][:]);
lat = missing2nan(ds["precise_lat"][:]);
pres = missing2nan(ds["pressure"][:]);
z = -missing2nan(ds["depth"][:]); 
temp = missing2nan(ds["temperature"][:]);
cond = missing2nan(ds["conductivity"][:]);
salt = missing2nan(ds["salinity"][:]);
rho = missing2nan(ds["density"][:]);
dO = missing2nan(ds["dissolved_oxygen"]); 
dOsat = missing2nan(ds["oxygen_saturation"]);
backscatter = missing2nan(ds["backscatter"]);
CDOM = missing2nan(ds["CDOM"]);
chlorophyll = missing2nan(ds["chlorophyll"]);
PAR = missing2nan(ds["PAR"]);


#station = ds["station"][:];
#z = missing2nan(ds["z"][:,:]);
#u = missing2nan(ds["eastward_sea_water_velocity"][:,:]);
#v = missing2nan(ds["northward_sea_water_velocity"][:,:]);
#w = missing2nan(ds["upward_sea_water_velocity"][:,:]);
#uverr = missing2nan(ds["velprof_evl"][:,:]);
