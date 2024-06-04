include("ooi_load_glider_data.jl");
include("ooi_load_mooring_data.jl");

cp13nopm = ooi_load_mooring_data("ooi-cp13nopm-wfp01-03-ctdpfk000", "/Users/gong/oceansensing Dropbox/C2PO/Data/OOI/"; st0 = "2024-04-01T00:00:00Z", stN = "2024-07-01T04:00:00Z");

cp379 = ooi_load_glider_data("cp_379-20240404T2244-delayed", "/Users/gong/oceansensing Dropbox/C2PO/Data/OOI/");
cp387 = ooi_load_glider_data("cp_387-20240405T1751", "/Users/gong/oceansensing Dropbox/C2PO/Data/OOI/");
