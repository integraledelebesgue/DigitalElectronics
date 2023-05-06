module Counters
export expressions, to_strings

using LogicalFunctions
using Minimization
using Visualization: formula

TransitionTable = Vector{Tuple{BitVector, BitVector}}

function to_bits(sequence::Vector{Int})::Vector{BitVector}
    n_bits = 1 + (
        sequence |>
        maximum |>
        log2 |>
        floor |>
        Int
    )

    BitVector.(digits.(sequence, base=2, pad=n_bits))
end


function transition_table(sequence::Vector{BitVector})::TransitionTable
    zip(
        sequence[1:end],
        [sequence[2:end]; [sequence[1]]]
    ) |> collect
end


function split_columns(table::TransitionTable)::Dict{Int, TruthTable}
    n_bits = length(table[1][1])
    Dict([
        bit => Dict(map(
            (input, values)::Tuple -> input => values[bit],
            table
        )) for bit in 1:n_bits
    ])
end


function expressions(sequence::Vector{Int})::Dict{Int, DNF}
    cols = sequence |> 
        to_bits |> 
        transition_table |> 
        split_columns

    Dict([
        digit_fun.first => minimize(digit_fun.second)
        for digit_fun in cols
    ])
end


function to_strings(exprs::Dict{Int, DNF})::Vector{String}
    sort_by_first!(exprs::Vector{Pair{Int, DNF}})::Vector{Pair{Int, DNF}} = 
        sort!(exprs, by = element -> element.first)

    exprs |>
    collect |>
    sort_by_first! .|>
    (expr -> formula(expr.second, "x$(expr.first)"))
end

end# module
