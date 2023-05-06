module Visualization
export summation, formula

using LogicalFunctions: evaluate, natural_code, positive, dontcare, TruthTable
using Base.Iterators: flatten


to_string(bits::BitVector)::String = join(Int.(bits))
to_dec(bits::String)::Int = parse(Int, bits, base=2)
to_comma(nums::Vector{Int})::String = join(nums, ", ")

represent(table::TruthTable)::String = 
    table |>
    keys .|>
    to_string .|>
    to_dec |>
    sort |>
    to_comma


function summation(values::TruthTable; name::String = "f")::String
    ones = 
        values |> 
        positive |>
        represent

    dontcares =
        values |>
        dontcare |>
        represent

    "$name = Σ m($(ones)) + d($(dontcares))"
end


function summation(fun::Function, arity::Int; name::String = "f")::String
    summation(
        evaluate(fun, natural_code(arity)),
        name = name
    )
end


function formula(dnf::Vector{Vector{Int}}, name::String = "f", val_names::Union{Nothing, Dict{Int, String}} = nothing)::String
    if val_names === nothing
        val_names = 
            dnf |> 
            flatten |> 
            unique .|>
            abs |>
            sort .|>
            (i -> i => "x$i") |>
            Dict
    end

    signs(minterm::Vector{Int})::Vector{String} = 
        minterm .|>
        (num -> num < 0 ? "-" : "")

    to_conjunction(minterm::Vector{Int})::String = "($(
        join(
            join.(
                zip(
                    signs(minterm),
                    get.([val_names], abs.(minterm), "?")
                )
            ),
            " ∧ "
        )
    ))"

    to_disjunction(minterms::Vector{String})::String = join(minterms, " ∨ ")

    expr = 
        dnf .|>
        to_conjunction |>
        to_disjunction

    "$name = $expr"
end


end# module