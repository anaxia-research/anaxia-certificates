# Independent exact replications for the Anaxia methods report.
# Uses only Julia standard libraries; performs no network requests.

using Test
using TOML

const Q = Rational{BigInt}
const Monomial = NTuple{2,Int}
const Polynomial = Dict{Monomial,Q}

function d4_roots()
    roots = NTuple{4,BigInt}[]
    for i in 1:3, j in (i + 1):4, s in (-1, 1), t in (-1, 1)
        push!(roots, ntuple(k -> k == i ? BigInt(s) : k == j ? BigInt(t) : big(0), 4))
    end
    roots
end

norm_squared(v) = sum(x * x for x in v)
distance_squared(u, v) = sum((x - y)^2 for (x, y) in zip(u, v))

function add_term!(p::Polynomial, powers::Monomial, coefficient::Q)
    p[powers] = get(p, powers, Q(0)) + coefficient
    iszero(p[powers]) && delete!(p, powers)
    p
end

function weighted_square(p::Polynomial, weight::Q)
    result = Polynomial()
    for (a, x) in p, (b, y) in p
        add_term!(result, (a[1] + b[1], a[2] + b[2]), weight * x * y)
    end
    result
end

function add_polynomials(a::Polynomial, b::Polynomial)
    result = copy(a)
    for (powers, coefficient) in b
        add_term!(result, powers, coefficient)
    end
    result
end

function run_checks()
    roots = d4_roots()
    distances = [distance_squared(roots[i], roots[j]) for i in 1:23 for j in (i + 1):24]
    histogram = Dict(string(d) => count(==(d), distances) for d in sort(unique(distances)))

    @testset "D4 exact finite construction" begin
        @test length(roots) == 24
        @test length(unique(roots)) == 24
        @test all(v -> norm_squared(v) == 2, roots)
        @test length(distances) == 276
        @test minimum(distances) == 2
        @test all(d -> d >= 2, distances)
        @test histogram == Dict("2" => 96, "4" => 72, "6" => 96, "8" => 12)
    end

    polynomial = Polynomial((2, 0) => big(4)//big(3), (1, 1) => Q(-2),
                            (0, 2) => Q(1), (1, 0) => big(2)//big(3), (0, 0) => big(1)//big(3))
    first_factor = Polynomial((1, 0) => Q(1), (0, 1) => Q(-1))
    second_factor = Polynomial((1, 0) => Q(1), (0, 0) => Q(1))
    reconstructed = add_polynomials(weighted_square(first_factor, Q(1)),
                                    weighted_square(second_factor, big(1)//big(3)))
    bad_polynomial = copy(polynomial)
    add_term!(bad_polynomial, (0, 0), Q(1))

    @testset "Exact coefficient evidence and negative control" begin
        @test reconstructed == polynomial
        @test reconstructed != bad_polynomial
        @test all(denominator(c) > 0 for c in values(reconstructed))
        x = big(1)//big(2)
        @test x * (x - 1) == -(big(1)//big(4))
        @test x * (x - 1) < 0
        # Checking integers alone would miss the real-domain counterexample.
        @test all(n -> n * (n - 1) >= 0, -20:20)
    end

    square_residues = Set(mod(n * n, big(4)) for n in big(0):big(3))
    sum_residues = Set(mod(x * x + y * y, big(4)) for x in big(0):big(3) for y in big(0):big(3))
    @testset "Modular obstruction table" begin
        @test square_residues == Set([big(0), big(1)])
        @test sum_residues == Set([big(0), big(1), big(2)])
        @test !(big(3) in sum_residues)
        @test big(1)^2 + big(1)^2 == 2
    end

    Dict("schema_version" => 1, "runtime" => string(VERSION), "arithmetic" => "BigInt and Rational{BigInt}",
         "test_assertions" => 17, "all_assertions_passed" => true,
         "d4" => Dict("roots" => length(roots), "unordered_pairs" => length(distances),
                      "norm_squared" => 2, "minimum_distance_squared" => Int(minimum(distances)),
                      "distance_squared_histogram" => histogram,
                      "scope" => "Known 24-vector construction only; no universal upper bound or uniqueness proof."),
         "polynomial" => Dict("exact_identity_verified" => true, "tampered_identity_rejected" => true,
                              "counterexample" => "x=1/2 gives x(x-1)=-1/4",
                              "scope" => "Coefficient identity and explicit rational counterexample only."),
         "modular" => Dict("modulus" => 4, "sum_of_two_squares_residues" => [0, 1, 2],
                           "scope" => "Finite residue table; universal integer theorem is independently proved in Lean."),
         "global_new_conjecture_closures" => 0)
end

function main(args)
    output = if isempty(args)
        joinpath(@__DIR__, "..", "reports", "julia-verification.toml")
    elseif length(args) == 2 && args[1] == "--output"
        args[2]
    else
        error("Usage: julia --startup-file=no julia/verify.jl [--output REPORT.toml]")
    end
    result = run_checks()
    mkpath(dirname(abspath(output)))
    open(output, "w") do io
        TOML.print(io, result; sorted=true)
    end
    println("Saved exact replication report to ", output)
end

main(ARGS)
