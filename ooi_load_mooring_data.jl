
# DG 2024-03-22: Load data from OOI Coastal Pioneer Upper Inshore Profiler Mooring
# 
# Note: The script gives an example of loading data from one of OOI's moorings. Please use OOI Data Explorer to find other datasets.
#
# for Julia: NCDatasets, HTTP, DataFrames, PyCall, Dates, Missings must be installed
# for python: erddapy, and netCDF4 must be installed, and PyCall must be setup to use the correct version of python

include("ooi_func.jl");

using NCDatasets, HTTP, DataFrames, PyCall, Dates, Missings
using .ooi_func: missing2nan

# Load the ERDDAP python package to access the OOI data
ERDDAP = pyimport("erddapy").ERDDAP

#data_url = "http://erddap.dataexplorer.oceanobservatories.org/erddap/tabledap/ooi-cp02pmui-rii01-02-adcptg010.ncCFMA?time%2Cz%2Ceastward_sea_water_velocity%2Cvelprof_evl%2Cnorthward_sea_water_velocity%2Cupward_sea_water_velocity%2Cstation&time%3E=2013-11-23T23%3A30%3A00Z&time%3C=2022-11-19T09%3A30%3A00Z&z%3E=-69&z%3C=32"
#data_url = "http://erddap.dataexplorer.oceanobservatories.org/erddap/tabledap/ooi-cp13nopm-wfp01-03-ctdpfk000.ncCFMA?time%2Clatitude%2Clongitude%2Cz%2Csea_water_practical_salinity_profiler_depth_enabled%2Csea_water_practical_salinity_profiler_depth_enabled_qc_agg%2Csea_water_density_profiler_depth_enabled%2Csea_water_density_profiler_depth_enabled_qc_agg%2Csea_water_pressure_profiler_depth_enabled%2Csea_water_pressure_profiler_depth_enabled_qc_agg%2Csea_water_temperature_profiler_depth_enabled%2Csea_water_temperature_profiler_depth_enabled_qc_agg&time%3E=2024-05-10T21%3A27%3A00Z";
datadir = "/Users/gong/oceansensing Dropbox/C2PO/Data/OOI/";

server = "http://erddap.dataexplorer.oceanobservatories.org/erddap";
e = ERDDAP(server=server, protocol="tabledap"); 

e.response = "ncCFMA"
#e.dataset_id = "ooi-cp02pmui-rii01-02-adcptg010";
e.dataset_id = "ooi-cp13nopm-wfp01-03-ctdpfk000"; # Coastal Pioneer MAB: Northern Profiler Mooring: Wire-Following Profiler: CTD
#e.dataset_id = "ooi-cp11nosm-mfd37-02-adcptf000"; # Coastal Pioneer MAB: Northern Surface Mooring: Seafloor Multi-Function Node (MFN): Velocity Profiler (150kHz)
#e.dataset_id = "cp_387-20240405T1751"; 

variables_ctd = [
    "time",
    "latitude",
    "longitude",
    "z",    
    "sea_water_pressure_profiler_depth_enabled",
    "sea_water_temperature_profiler_depth_enabled",
    "sea_water_practical_salinity_profiler_depth_enabled",
    "sea_water_density_profiler_depth_enabled",
    "station"
]

variables_adcp = [
    "time",
    "latitude",
    "longitude",
    "z",
    "eastward_sea_water_velocity",
    "velprof_evl",
    "northward_sea_water_velocity",
    "upward_sea_water_velocity",
    "station"
];

e.variables = variables_ctd;

e.constraints = Dict(
    "time>=" => "2024-04-06T00:03:00Z",
    "time<=" => "2024-05-15T04:00:00Z",
    "z>=" => -100.0,
    "z<=" => 0.0
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
station = ds["station"].attrib["short_name"];

z = missing2nan(ds["sea_water_pressure_profiler_depth_enabled"][:,:]);
temp = missing2nan(ds["sea_water_temperature_profiler_depth_enabled"][:,:]);
salt = missing2nan(ds["sea_water_practical_salinity_profiler_depth_enabled"][:,:]);
rho = missing2nan(ds["sea_water_density_profiler_depth_enabled"][:,:]);

#station = ds["station"][:];
#z = missing2nan(ds["z"][:,:]);
#u = missing2nan(ds["eastward_sea_water_velocity"][:,:]);
#v = missing2nan(ds["northward_sea_water_velocity"][:,:]);
#w = missing2nan(ds["upward_sea_water_velocity"][:,:]);
#uverr = missing2nan(ds["velprof_evl"][:,:]);
