module Minimization
export minimize

using LogicalFunctions
using Base.Iterators: filter as lazy_filter


function group(table::Set{<:PartialBitVector})::Tuple{Set{Tuple{PartialBitVector, PartialBitVector}}, Set{PartialBitVector}}
    matched = Set()
    processed = Dict(table .=> false)

    for vec in lazy_filter(v -> v in table, collect(table))
        for neighbour in lazy_filter(neigh -> neigh in table, neighbours(vec))
            if (neighbour, vec) ∉ matched
                push!(matched, (vec, neighbour))
                processed[vec] = true
                processed[neighbour] = true
            end
        end
    end

    non_matched = filter(entry -> !entry.second, processed) |> 
        keys |> 
        Set

    return matched, non_matched
end


function combine((vec1, vec2)::Tuple{<:PartialBitVector, <:PartialBitVector})::PartialBitVector
    ret = Vector{Union{Bool, Missing}}(copy(vec1))

    diff = (vec1 .!== vec2) |> 
        skipmissing |> 
        argmax

    ret[diff] = missing

    ret
end


function reduce_terms(table::Set{<:PartialBitVector})::Set{PartialBitVector}
    prime = Set()

    matched = [1]
    
    while length(matched) > 0
        matched, non_matched = group(table)
        union!(prime, non_matched)
        table = Set(combine.(matched))
    end

    prime
end


function to_dnf(minterms::Set{PartialBitVector})::Vector{Vector{Int}}
    skipmissing_values(vec::Vector{<:Union{Tuple{Int, Bool}, Tuple{Int, Missing}}})::Vector{Tuple{Int, Any}} = 
        filter(
            (idx, val)::Tuple -> !ismissing(val),
            vec
        )

    literal((idx, val)::Tuple{Int, Bool})::Int = val ? idx : -idx
    
    clean_minterms = 
        minterms .|> 
        enumerate .|> 
        collect .|> 
        skipmissing_values

    map.(
        literal,
        clean_minterms
    )
end


function minimize(table::TruthTable)::Vector{Vector{Int}}
    table |> 
    positive |>
    keys |>
    Set |>
    reduce_terms |>
    to_dnf
end

end# module
