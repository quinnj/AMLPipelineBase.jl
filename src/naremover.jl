module NARemovers

using Random
using DataFrames

using ..AbsTypes
using ..BaseFilters
using ..Utils

import ..AbsTypes: fit!, transform!
export fit!, transform!
export NARemover


"""
    NARemover(
      Dict(
        :name => "nadetect",
        :acceptance => 0.10 # tolerable NAs percentage
      )
    )

Removes columns with NAs greater than acceptance rate.
This assumes that it processes columns of features. 
The output column should not be part of input to avoid
it being excluded if it fails the acceptance critera.

Implements `fit!` and `transform!`.
"""
mutable struct NARemover <: Transformer
   name::String
   model::Dict{Symbol,Any}

   function NARemover(args::Dict = Dict())
      default_args = Dict{Symbol,Any}(
         :name => "nadetect",
         :acceptance => 0.10
      )
      cargs=nested_dict_merge(default_args,args)
      cargs[:name] = cargs[:name]*"_"*randstring(3)
      new(cargs[:name],cargs)
   end
end

"""
NARemover(acceptance::Float64)

Helper function for NARemover.
"""
NARemover(acceptance::Float64) = NARemover(Dict(:acceptance => acceptance))


"""
    fit!(nad::NARemover,features::DataFrame,labels::Vector=[])

Checks and exit of df is empty

# Arguments
- `nad::NARemover`: custom type
- `features::DataFrame`: input
- `labels::Vector=[]`: 
"""
function fit!(nad::NARemover, features::DataFrame, labels::Vector=[])
   (features == DataFrame()) && throw(ArgumentError("empty dataframe"))
end


"""
    transform!(nad::NARemover,nfeatures::DataFrame)

Removes columns with NAs greater than acceptance rate.

# Arguments
- `nad::NARemover`: custom type
- `nfeatures::DataFrame`: input
"""
function transform!(nad::NARemover, nfeatures::DataFrame)
   features = deepcopy(nfeatures) 
   (features == DataFrame()) && throw(ArgumentError("empty dataframe"))
   sz = nrow(features)
   tol = nad.model[:acceptance]
   colnames = []
   for (colname,dat) in collect(pairs(eachcol(features)))
      if sum(ismissing.(dat)) < tol*sz
         push!(colnames,colname)
      end
   end
   xtr =  features[:,colnames]
   return xtr
end

end

