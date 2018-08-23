immutable Network

    layers::Vector{Vector{Table}}
    ties::TieBreak

    function Network(inputrange::Int, layersizes::Vector{Int}, inputs::Vector{Int}, ties::TieBreak=negative)

        @assert length(layersizes) >= 1
        @assert layersizes[end] == 1
        @assert all(inputs .<= 16)
        @assert length(layersizes) == length(inputs)
        layerranges = (length(layersizes) == 1) ? [inputrange] : vcat([inputrange], layersizes[1:end-1])
        @assert all([range >= k for (range, k) in zip(layerranges, inputs)])

        layers = Vector{Vector{Table}}(length(layersizes))

        positions = [Set{Int}() for ll in 1:length(layersizes)+1]
        map(n -> push!(positions[end], n), layersizes[end])

        for ll in reverse(1:length(layers))
            layers[ll] = Vector{Table}(layersizes[ll])
            for tt in 1:length(layers[ll])
                if tt in positions[ll+1]
                    randinputs = shuffle(1:layerranges[ll])[1:inputs[ll]]
                    layers[ll][tt] = Table(randinputs, zeros(Int, 2^inputs[ll]), zeros(Int, 2^inputs[ll]))
                    map(n -> push!(positions[ll], n), randinputs)
                end
            end
        end

        new(layers, ties)

    end

end


function (net::Network)(x::Vector{Bool})

    prev = x
    next = Vector{Bool}

    for layer in net.layers
        next = Vector{Bool}(length(layer))
        for tt in 1:length(layer)
            if isassigned(layer, tt)
                next[tt] = layer[tt](prev, net.ties)
            end
        end
        prev = next
    end

    next[end]

end


function (net::Network)(X::Matrix{Bool})

    [net(X[:,ss]) for ss in 1:size(X, 2)]

end


function (net::Network)(X::Matrix{Bool}, y::AbstractArray{Bool})

    @assert size(X, 2) == length(y)

    for layer in net.layers

        for tt in 1:length(layer)
            if isassigned(layer, tt)
                for ss in 1:size(X, 2)
                    layer[tt](X[:,ss], y[ss])
                end
            end
        end

        R = Matrix{Bool}(length(layer), size(X, 2))

        for ss in 1:size(X, 2)
            for tt in 1:length(layer)
                if isassigned(layer, tt)
                    R[tt,ss] = layer[tt](X[:,ss], net.ties)
                end
            end
        end

        X = R

    end

    X[:]

end
