# DG 2024-03-22: Load data from OOI Coastal Pioneer Upper Inshore Profiler Mooring
# DG 2024-06-04: refactored code to use function calls and data types
# 
# Note: The script gives an example of loading data from one of OOI's moorings. Please use OOI Data Explorer to find other datasets.
#
# for Julia: NCDatasets, HTTP, DataFrames, PyCall, Dates, Missings must be installed
# for python: erddapy, and netCDF4 must be installed, and PyCall must be setup to use the correct version of python

include("ooi_func.jl");
include("ooi_types.jl");

using NCDatasets, HTTP, DataFrames, PyCall, Dates, Missings
using .ooi_func: missing2nan, cat_col_string
import .ooi_types: MooringCTD

function ooi_load_mooring_data(dataset_id, datadir)
    # Load the ERDDAP python package to access the OOI data
    ERDDAP = pyimport("erddapy").ERDDAP

    #data_url = "http://erddap.dataexplorer.oceanobservatories.org/erddap/tabledap/ooi-cp13nopm-wfp01-03-ctdpfk000.ncCFMA?time%2Clatitude%2Clongitude%2Cz%2Csea_water_practical_salinity_profiler_depth_enabled%2Csea_water_practical_salinity_profiler_depth_enabled_qc_agg%2Csea_water_density_profiler_depth_enabled%2Csea_water_density_profiler_depth_enabled_qc_agg%2Csea_water_pressure_profiler_depth_enabled%2Csea_water_pressure_profiler_depth_enabled_qc_agg%2Csea_water_temperature_profiler_depth_enabled%2Csea_water_temperature_profiler_depth_enabled_qc_agg&time%3E=2024-05-10T21%3A27%3A00Z";
    #datadir = "/Users/gong/oceansensing Dropbox/C2PO/Data/OOI/";

    server = "http://erddap.dataexplorer.oceanobservatories.org/erddap";
    e = ERDDAP(server=server, protocol="tabledap"); 

    e.response = "ncCFMA"
    e.dataset_id = dataset_id;
    #e.dataset_id = "ooi-cp02pmui-rii01-02-adcptg010";
    #e.dataset_id = "ooi-cp13nopm-wfp01-03-ctdpfk000"; # Coastal Pioneer MAB: Northern Profiler Mooring: Wire-Following Profiler: CTD
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
        "time>=" => "2024-04-03T00:00:00Z",
        "time<=" => "2024-05-15T04:00:00Z",
        "z>=" => -100.0,
        "z<=" => 0.0
    );

    # download the data from ERDDAP server in netCDF format
    dataurl = e.get_download_url();
    datalocalpath = joinpath(datadir, e.dataset_id * ".ncCFMA"); 

    #HTTP.download(dataurl, datalocalpath, verbose=true);
    if isfile(datalocalpath) && redownloadflag == 0
        println("File already exists: ", datalocalpath);
    else
        HTTP.download(dataurl, datalocalpath, verbose=true);
        println("Downloaded data from ", dataurl, " to ", datalocalpath);
    end

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

    mooring = MooringCTD(station, time, lat, lon, z, temp, salt, rho);
    return mooring;
end