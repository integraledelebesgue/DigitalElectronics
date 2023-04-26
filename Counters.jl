module Counters

export expressions

using LogicalFunctions
using Minimization


function sequence_to_bits(sequence::Vector{Int})::Vector{BitVector}
    n_bits = 1 + (
        sequence |>
        maximum |>
        log2 |>
        floor |>
        Int
    )

    BitVector.(digits.(sequence, base=2, pad=n_bits))
end


function transition_table(sequence::Vector{BitVector})::Vector{Tuple{BitVector, BitVector}}
    zip(
        sequence[1:end],
        [sequence[2:end]; [sequence[1]]]
    ) |> collect
end


function split_columns(trans_table::Vector{Tuple{BitVector, BitVector}})::Dict{Int, TruthTable}
    n_bits = length(trans_table[1][1])
    Dict([
        bit => Dict(map(
            (input, values)::Tuple -> input => values[bit],
            trans_table
        )) for bit in 1:n_bits
    ])
end


function expressions(sequence::Vector{Int})::Dict{Int, Vector{Vector{Int}}}
    cols = sequence |> 
        sequence_to_bits |> 
        transition_table |> 
        split_columns

    Dict([
        digit_fun.first => minimize(digit_fun.second)
        for digit_fun in cols
    ])
end

end# module
