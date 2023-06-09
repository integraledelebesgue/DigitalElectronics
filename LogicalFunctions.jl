module LogicalFunctions
export TruthTable, PartialBitVector, DNF, hstack, natural_code, gray_code, evaluate, neighbours, zero_to, find_missing, positive, dontcare

using LinearAlgebra

PartialBitVector = Union{BitVector, Vector{Union{Bool, Missing}}}
TruthTable = Dict{BitVector, Union{Bool, Nothing}}
MatrixOrAdj = Union{LinearAlgebra.Transpose{Bool, BitMatrix}, BitArray}
DNF = Vector{Vector{Int64}}

function natural_sort(arr::MatrixOrAdj)::BitArray
    sortslices(arr, dims=1)
end


function zero_to(stop::Int)::UnitRange{Int}
    0:stop
end


function hstack(vecs::Vector{BitVector})::BitArray
    reduce(
        hcat,
        vecs
    )
end


function natural_code(n::Int)::BitArray
    as_bits(num::Int)::BitVector = BitVector(digits(num, base=2, pad=n))

    base = 1 << n - 1

    0:base .|>
        as_bits |>
        hstack |>
        transpose |>
        natural_sort
end


function gray_code(n::Int)::Vector{BitVector}
    codes = [BitVector([false]), BitVector([true])]

    threshold = 1 << n
    base = 2

    while base < threshold
        codes = vcat(pushfirst!.(copy.(codes), 0), pushfirst!.(reverse(codes), 1))
        base <<= 1
    end

    codes
end


function evaluate(fun::Function, inputs::BitArray)::TruthTable
    inputs |>
        eachrow .|>
        (input -> collect(input) => fun(input...)) |>
        Dict
end


function neighbours(vals::PartialBitVector)::Vector{PartialBitVector}
    n_vals = length(vals)
    
    to_bits(num::Int)::BitVector = BitVector(digits(num, base=2, pad=n_vals))
    two_to_pow(x::Int)::Int = 1 << x
    new_only(output)::Vector{PartialBitVector} = 
        filter(vec -> !all(vec .=== vals), output)

    n_vals - 1 |>
        zero_to .|>
        two_to_pow .|> 
        to_bits .|>
        (vec -> vec .⊻ vals) |>
        new_only |>
        unique 
end


function find_missing(vec::PartialBitVector)::Vector{Int}
    filter(
        (i, val)::Tuple -> ismissing(val),
        vec |> enumerate |> collect
    ) .|> first
end


function positive(table::TruthTable)::TruthTable
    filter(
        entry -> entry.second === true,
        table
    )
end


function dontcare(table::TruthTable)::TruthTable
    filter(
        entry -> entry.second === nothing,
        table
    )
end

end#module
