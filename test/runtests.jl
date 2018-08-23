using Memorization
@static if VERSION < v"0.7.0-DEV.2005"
    using Base.Test
else
    using Test
end

immutable Dataset
    X::Matrix{Bool}
    y::Vector{Bool}
    function Dataset(X::Matrix, y::Vector)
        @assert size(X, 2) == length(y)
        new(X, y)
    end
end


tie = Dataset([true true], [true, false])
net = Network(1, [1], [1], Memorization.positive)
@test all(net(tie.X, tie.y) .== trues(length(tie.y)))
net = Network(1, [1], [1], Memorization.negative)
@test all(net(tie.X, tie.y) .== falses(length(tie.y)))


net = Network(2, [1], [2], Memorization.negative)
net([true true]', [true])
@test net([true false]')[1] == false
net([true false]', [true])
@test net([true false]')[1] == true


test = Dataset(
    [true false; true true; false true; false false]',
    [true, false, true, false]
)
net = Network(2, [1], [2])
@test all(net(test.X, test.y) .== test.y)


test = Dataset(
    [true false; true true; false true; false false]',
    [true, true, false, false]
)
net = Network(2, [1], [2])
@test all(net(test.X, test.y) .== test.y)


random = Dataset(
    convert(Matrix{Bool}, rand(4, 20) .> .3),
    convert(Vector{Bool}, rand(20) .> .3)
)
net = Network(4, [2, 1], [2, 2])
@test all(net(random.X, random.y) .== net(random.X))


net = Network(4, [1024, 1], [2, 2])
@test all(Memorization.numberofneurons(net) .== [2, 1])
