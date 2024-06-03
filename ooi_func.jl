module ooi_func

using Missings

# Define a function to convert Missing to NaN in Julia
function missing2nan(varin)
    varin = collect(varin);
    if (typeof(varin) == Vector{Union{Missing, Int64}}) || (typeof(varin) == Matrix{Union{Missing, Int64}} || typeof(varin) == Vector{Union{Missing, Int32}}) || (typeof(varin) == Matrix{Union{Missing, Int32}})
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
    elseif (typeof(varin) == Vector{Union{Missing, Float64}}) || (typeof(varin) == Matrix{Union{Missing, Float64}} || typeof(varin) == Vector{Union{Missing, Float32}}) || (typeof(varin) == Matrix{Union{Missing, Float32}})
        varout = Float64.(collect(Missings.replace(varin, NaN)));
    elseif (typeof(varin) == Vector{Missing}) | (typeof(varin) == Matrix{Missing})
        varout = Array{Float64}(undef,size(collect(varin)));
        varout .= NaN; 
    else
        varout = varin;
    end

    return varout
end

function cat_col_string(arr::Array{Char, 2})
    var_raw = [string(arr[:,i]...) for i in 1:size(arr,2)];
    var = [replace(var_raw[i], r"[\0]" => "") for i in 1:length(var_raw)];
    return var;
end

end