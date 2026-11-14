"""Exact finite checks for packings on the intermediate-scale D4 grid."""

using TOML

const PERIOD = 6
const SIMILARITY = ((1, -1, -1, 0), (1, 1, 0, 1), (1, 0, 1, -1), (0, -1, 1, 1))
const COSINE = (1//1, 1//2, -1//2, -1//1, -1//2, 1//2)
# Coefficients in the basis (1, ζ), with ζ = exp(πi/3) and ζ² = ζ - 1.
const ROOT_POWERS = ((1, 0), (0, 1), (-1, 1), (-1, 0), (0, -1), (1, -1))

dot(a, b) = sum(x*y for (x, y) in zip(a, b))
norm_squared(v) = dot(v, v)
residue(v) = ntuple(i -> mod(v[i], PERIOD), 4)
transform(v) = ntuple(i -> dot(SIMILARITY[i], v), 4)

function exact_eigenvalue(frequency, shells)
    real_coeff, root_coeff = 0, 0
    for (vector, weight) in shells
        term = ROOT_POWERS[mod(dot(vector, frequency), PERIOD) + 1]
        real_coeff += weight * term[1]
        root_coeff += weight * term[2]
    end
    @assert iszero(root_coeff)
    return real_coeff
end

function verify()
    columns = [ntuple(i -> SIMILARITY[i][j], 4) for j in 1:4]
    @assert all(isodd(sum(v)) for v in columns)
    @assert all(dot(columns[i], columns[j]) == (i == j ? 3 : 0)
                for i in 1:4 for j in 1:4)

    shell_vectors = [v for v in Iterators.product(ntuple(_ -> -2:2, 4)...)
                     if iseven(sum(v)) && norm_squared(v) in (2, 4)]
    @assert count(v -> norm_squared(v) == 2, shell_vectors) == 24
    @assert count(v -> norm_squared(v) == 4, shell_vectors) == 24
    shells = [(v, norm_squared(v) == 2 ? 2 : 1) for v in shell_vectors]
    degree = sum(last, shells)
    @assert degree == 72

    vertices = [v for v in Iterators.product(ntuple(_ -> 0:PERIOD-1, 4)...)
                if iseven(sum(v))]
    image = unique([residue(transform(v)) for v in vertices])
    forbidden = Set(residue(v) for v in shell_vectors)
    @assert length(vertices) == 648 && length(image) == 72
    checked_pairs = 0
    for (index, a) in enumerate(image), j in index+1:length(image)
        b = image[j]
        difference = ntuple(i -> a[i] - b[i], 4)
        @assert !(residue(difference) in forbidden)
        checked_pairs += 1
    end
    @assert checked_pairs == 2556

    # Characters differing by (3,3,3,3) agree on the even-sum subgroup.
    # Taking the first coordinate in 0:2 yields one representative per character.
    frequencies = Iterators.product(0:2, 0:5, 0:5, 0:5)
    spectrum_counts = Dict{Int, Int}()
    for frequency in frequencies
        eigenvalue = exact_eigenvalue(frequency, shells)
        t = map(k -> COSINE[k + 1], frequency)
        @assert eigenvalue == 4sum(t)^2 + 16prod(t) - 8
        spectrum_counts[eigenvalue] = get(spectrum_counts, eigenvalue, 0) + 1
    end
    @assert sum(values(spectrum_counts)) == length(vertices)
    minimum_eigenvalue = minimum(keys(spectrum_counts))
    @assert minimum_eigenvalue == -9 && exact_eigenvalue((1, 1, 1, 3), shells) == -9

    # (2q−3)²(15−4q) = 27(1 + 4(q−1)²) − 16q³, as coefficient vectors.
    factored = (9, -12, 4)
    linear = (15, -4)
    expanded = ntuple(k -> sum(factored[i] * linear[j]
                               for i in 1:3 for j in 1:2 if i+j-1 == k), 4)
    @assert expanded == (135, -216, 108, -16)

    attained_fraction = length(image) // length(vertices)
    @assert attained_fraction == -minimum_eigenvalue // (degree - minimum_eigenvalue)
    return Dict(
        "scope" => "Exact finite checks for the intermediate-scale fixed D4 grid argument.",
        "period" => PERIOD,
        "torus_vertices" => length(vertices),
        "attaining_vertices" => length(image),
        "attaining_pairs_checked" => checked_pairs,
        "characters_checked" => sum(values(spectrum_counts)),
        "weighted_degree" => degree,
        "minimum_eigenvalue" => minimum_eigenvalue,
        "attained_fraction" => string(attained_fraction),
        "cubic_coefficients" => collect(expanded),
        "spectrum_multiplicities" => Dict(string(k) => v for (k, v) in spectrum_counts),
    )
end

function main(args)
    report = verify()
    if isempty(args)
        TOML.print(stdout, report; sorted=true)
    elseif length(args) == 2 && args[1] == "--output"
        output = args[2]
        mkpath(dirname(abspath(output)))
        open(output, "w") do io
            TOML.print(io, report; sorted=true)
        end
    else
        error("Usage: julia --startup-file=no julia/verify_d4_intermediate_grid.jl [--output REPORT.toml]")
    end
    println("Checked 648 character eigenvalues and 2,556 pairs in the attaining construction.")
end

main(ARGS)
