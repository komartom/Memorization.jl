module Memorization

export Network


@enum TieBreak negative positive

include("./Table.jl")
include("./Network.jl")


function numberofneurons(net::Network)

    [sum([ isassigned(layer, tt) for tt in 1:length(layer) ])  for layer in net.layers]

end


end # module
