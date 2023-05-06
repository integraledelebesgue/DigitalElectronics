module MealyMachines
export expressions, to_strings

using Base.Iterators: drop, cycle, partition, flatten
using LogicalFunctions, Minimization
using Visualization: formula

TransitionTable = Dict{Vector{Int}, Vector{Int}}


function automaton_transition(pattern::BitVector)::TransitionTable
    n = length(pattern)

    codes = 
        n |>
        log |>
        ceil |>
        Int |>
        gray_code

    encode(state::Int, bit::Bool)::BitVector = 
        vcat(codes[state], [bit])

    basic_transitions = [
        encode(state, bit) => encode(next_state, false) 
        for (state, bit, next_state) in zip(1:n-1, pattern, 2:n)
    ]

    push!(basic_transitions, encode(n, pattern[end]) => encode(1, true))

    max_prefix(patt::BitVector, i::Int)::Int = 
        maximum(
            length,
            [patt[1:j] for j in 1:i if patt[1:j] == patt[1:n-j-1]],
            init = 1
        )

    extended_patterns = [[pattern; true], [pattern; false]]

    prefix_transitions = [
        encode(i, ext[end]) => encode(max_prefix(ext, i), false)
        for ext in extended_patterns
        for i in 1:n
    ]

    return merge(
        Dict(prefix_transitions), 
        Dict(basic_transitions)
    )
end


function split_columns(table::TransitionTable)::Dict{Int, TruthTable}
    n_vars = 
        table |>
        keys |>
        first .|>
        length |>
        sum
    
    Dict([
        var => Dict([
            entry.first => entry.second[var] 
            for entry in table
        ]) 
        for var in 1:n_vars
    ])
end


function expressions(pattern::BitVector)::Dict{Int, DNF}
    cols = pattern |> 
        automaton_transition |> 
        split_columns

    Dict([
        bit.first => minimize(bit.second)
        for bit in cols
    ])
end


function to_strings(exprs::Dict{Int, DNF})::Vector{String}
    n_funs = exprs |>
        keys |>
        length

    n_vars = exprs |>
        values |>
        flatten .|>
        collect |>
        flatten |>
        collect .|>
        abs |>
        maximum

    state_names = Dict(i => "x$i" for i in 1:n_funs-1)
    
    fun_names = merge(
        state_names, 
        Dict(n_funs => "out")
    )

    var_names = merge(
        state_names,
        Dict(n_vars => "in")
    )

    formula.(
        get.([exprs], 1:n_funs, nothing), 
        get.([fun_names], 1:n_funs, "?"),
        [var_names]
    )
end


end# module
