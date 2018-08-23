
immutable Table

    inputs::Vector{Int}
    positives::Vector{Int}
    negatives::Vector{Int}

    function Table(inputs, positives, negatives)

        @assert length(positives) == length(negatives)
        @assert 2^length(inputs) == length(positives)

        new(inputs, positives, negatives)

    end

end


function indexing(vec::Vector{Bool})

    ind = pos = 1

    for bit in vec
        if bit
            ind += pos
        end
        pos <<= 1
    end

    ind

end


function (tab::Table)(x::Vector{Bool}, ties::TieBreak)

    ind = indexing(x[tab.inputs])

    if tab.positives[ind] < tab.negatives[ind]
        false
    elseif tab.positives[ind] > tab.negatives[ind]
        true
    else
        ties == positive
    end

end


function (tab::Table)(x::Vector{Bool}, label::Bool)

    ind = indexing(x[tab.inputs])

    if label
        tab.positives[ind] += 1
    else
        tab.negatives[ind] += 1
    end

end
