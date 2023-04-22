push!(LOAD_PATH, @__DIR__)

using LogicalFunctions
using Base.Iterators: filter as lfilter


function group(table::Set{<:PartialBitVector})::Tuple{Set{Tuple{PartialBitVector, PartialBitVector}}, Set{PartialBitVector}}
    matched = Set()
    processed = Dict(table .=> false)

    for vec in lfilter(v -> v in table, collect(table))
        for neighbour in lfilter(neigh -> neigh in table, neighbours(vec))
            if (neighbour, vec) ∉ matched
                push!(matched, (vec, neighbour))
                processed[vec] = true
                processed[neighbour] = true
            end
        end
    end

    return matched, filter(entry -> !entry.second, processed) |> keys |> Set
end


function combine((vec1, vec2)::Tuple{<:PartialBitVector, <:PartialBitVector})::PartialBitVector
    let ret = Vector{Union{Bool, Missing}}(copy(vec1))
        diff = (vec1 .!== vec2) |> 
            skipmissing |> 
            argmax

        ret[diff] = missing
        ret
    end
end


function reduce_terms(table::Set{<:PartialBitVector})::Set{PartialBitVector}
    prime = Set()

    matched = [1]
    
    while length(matched) > 0
        matched, non_matched = group(table)
        union!(prime, non_matched)
        table = Set(combine.(matched))
    end

    return prime
end


function to_summation(minterms::Set{PartialBitVector})::Vector{Vector{Int}}
    skipmissing_values(vec::Vector{Tuple{Int, <:Union{Bool, Missing}}})::Vector{Tuple{Int, Any}} = 
        filter(
            (idx, val)::Tuple -> !ismissing(val),
            vec
        )

    literal((idx, val)::Tuple{Int, Bool})::Int = val ? idx : -idx
    
    map.(
        literal,
        minterms .|> enumerate .|> collect .|> skipmissing_values
    )
end


function main()
    f(a, b, c, d, e) = !((a || b) ⊻ (c && !d && a) ⊻ (e || d))

    evaluate(f, exhaust(5)) |>
        positive |>
        keys |>
        Set |> 
        reduce_terms |>
        to_summation |>
        display
end


main()
