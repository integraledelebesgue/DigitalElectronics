push!(LOAD_PATH, @__DIR__)

using Visualization
using Counters
using MealyMachines


f(x, y, z) = (x && y) ? nothing : (y && z)

summation(f, 3) |> display

println()

[0, 2, 4, 6, 1, 3, 5, 7] |>
    Counters.expressions |> 
    Counters.to_strings .|>
    display

println()

[1, 1, 0, 1] |>
    BitVector |>
    MealyMachines.expressions |>
    MealyMachines.to_strings .|>
    display
