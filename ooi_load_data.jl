
# DG 2024-03-22: Load data from OOI Coastal Pioneer Upper Inshore Profiler Mooring
# 
# Note: to run this script:
# for python: erddapy, and netCDF4 must be installed, and PyCall must be setup to use the correct version of python
# for Julia: NCDatasets, HTTP, DataFrames, PyCall, Dates, Missings must be installed

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

#data_url = "http://erddap.dataexplorer.oceanobservatories.org/erddap/tabledap/ooi-cp02pmui-rii01-02-adcptg010.ncCFMA?time%2Cz%2Ceastward_sea_water_velocity%2Cvelprof_evl%2Cnorthward_sea_water_velocity%2Cupward_sea_water_velocity%2Cstation&time%3E=2013-11-23T23%3A30%3A00Z&time%3C=2022-11-19T09%3A30%3A00Z&z%3E=-69&z%3C=32"
datadir = "/Users/gong/oceansensing Dropbox/C2PO/Data/OOI/";

server = "http://erddap.dataexplorer.oceanobservatories.org/erddap";
e = ERDDAP(server=server, protocol="tabledap"); 

e.response = "ncCFMA"
e.dataset_id = "ooi-cp02pmui-rii01-02-adcptg010"

e.variables = [
    "time",
    "z",
    "eastward_sea_water_velocity",
    "velprof_evl",
    "northward_sea_water_velocity",
    "upward_sea_water_velocity",
    "station"
];

e.constraints = Dict(
    "time>=" => "2013-11-23T23:30:00Z",
    "time<=" => "2022-11-19T09:30:00Z",
    "z>=" => -69,
    "z<=" => 32
);

# download the data from ERDDAP server in netCDF format
dataurl = e.get_download_url();
datalocalpath = joinpath(datadir, e.dataset_id * ".ncCFMA"); 

HTTP.download(dataurl, datalocalpath, verbose=true);

#data = e.to_ncCF()
#df_py = e.to_pandas(index_col="time (UTC)", parse_dates=true, skiprows=(1,)).dropna()
#df = DataFrame(df_py);

# load the data from the netCDF file using NCDatasets library
ds = NCDatasets.NCDataset(datalocalpath);

time = ds["time"][:];
lon = ds["longitude"][:];
lat = ds["latitude"][:];
station = ds["station"][:];
z = missing2nan(ds["z"][:,:]);
u = missing2nan(ds["eastward_sea_water_velocity"][:,:]);
v = missing2nan(ds["northward_sea_water_velocity"][:,:]);
w = missing2nan(ds["upward_sea_water_velocity"][:,:]);
uverr = missing2nan(ds["velprof_evl"][:,:]);