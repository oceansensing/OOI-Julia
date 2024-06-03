include("ooi_func.jl");
include("ooi_types.jl");

using NCDatasets, HTTP, DataFrames, PyCall, Dates, Missings
using .ooi_func: missing2nan, cat_col_string
import .ooi_types: Glider

function ooi_load_glider_data(dataset_id, datadir)
    # DG 2024-03-22: Load data from OOI Coastal Pioneer Upper Inshore Profiler Mooring
    # 
    # Note: The script gives an example of loading data from one of OOI's moorings. Please use OOI Data Explorer to find other datasets.
    #
    # for Julia: NCDatasets, HTTP, DataFrames, PyCall, Dates, Missings must be installed
    # for python: erddapy, and netCDF4 must be installed, and PyCall must be setup to use the correct version of python

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
    source_file = cat_col_string(ds["source_file"][:,:]);
    #source_file_raw = [string(sf2d[:,i]...) for i in 1:size(sf2d,2)];
    #source_file = [replace(source_file_raw[i], r"[\0]" => "") for i in 1:length(source_file_raw)];

    glider = ooi_types.Glider(trajectory, wmo_id, profile_id, time, lat, lon, pres, z, backscatter, CDOM, chlorophyll, PAR, dOsat, temp, cond, salt, rho, source_file);
    return glider;
end
