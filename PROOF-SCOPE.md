# Proof scope and trust boundaries

## Kernel-checked Lean statements

`lean/Certificates.lean` imports only Lean `Std` under toolchain 4.34.1. The following named theorems are checked:

| Theorem | Exact claim |
| --- | --- |
| `d4_count` | The explicit list has length 24. |
| `d4_distinct` | The list has no duplicate vectors. |
| `d4_norms` | Every listed integer vector has squared norm 2. |
| `d4_pair_separation` | Every unordered pair in list order has squared distance at least 2. |
| `d4_distance_two_witness` | The displayed pair has squared distance exactly 2. |
| `square_mod_four` | Every integer square is 0 or 1 modulo 4. |
| `no_integer_sum_squares_three` | No integers `x,y` satisfy `x*x + y*y = 3`. |
| `sum_squares_two_witness` | The related equation `x*x + y*y = 2` has the displayed integer witness. |

The geometric statements are finite integer assertions. The usual Euclidean scaling interpretation is explained in the manuscript. A universal upper bound over all sphere configurations and a uniqueness theorem are not proved by this list.

The modular impossibility is a universal integer theorem, proved through congruence reasoning in Lean rather than inferred from a finite integer search. It is an elementary existing fact, not a new research-conjecture closure.

`#print axioms` records the transitive axiom dependencies. Six listed theorems have none; `square_mod_four` and `no_integer_sum_squares_three` depend on the standard Lean principles `propext` and `Quot.sound`. The file declares no extra axioms and uses no proof placeholders or native-evaluation proof shortcuts.

[`D4Spectral.lean`](lean/D4Spectral.lean) checks the bound $-9$ for the weighted adjacency polynomial on the rational cube and verifies a rational equality point. The written fixed-grid proof extends the bound to the real cube by continuity and gives the Fourier, density, and attainability arguments. [Lean proof scope](lean/D4Spectral.md) · [Fixed-grid proof](https://github.com/anaxia-research/anaxia/blob/main/docs/D4-INTERMEDIATE-GRID.md)

## Independent Julia checks

The Julia script constructs the vectors from coordinate positions and signs, independently of Lean's explicit list. It uses arbitrary-precision integers and exact rational coefficients. A successful run checks all 276 unordered distances, reconstructs a polynomial SOS identity coefficient by coefficient, rejects a tampered identity, and evaluates a rational counterexample exactly.

The [D4 grid replay](julia/verify_d4_intermediate_grid.jl) computes the period-six spectrum directly in exact cyclotomic arithmetic, checks its agreement with the cosine polynomial on 648 characters, and checks all 2,556 pairs in the 72-site equality packing. [Recorded replay](reports/d4-intermediate-grid.toml)

Julia execution is computational replication, not a Lean theorem. A script's presence is not evidence that it ran. `reports/validation.json` and the retained logs distinguish executed checks from unavailable runtimes.

## Model-assisted research and named targets

The companion Anaxia workbench records model proposals as unverified until a supported exact checker accepts a certificate for the fixed original statement. Natural-language campaigns remain `unverified_proposal` with global status `not_closed`.

Finite Collatz, Goldbach, Legendre, and Erdős–Straus checks have only their recorded ranges. The `D4` root configuration concerns a lattice construction; the unrelated reflexive-polytope descent quantity also called `D4` requires a different statement, cover relation, classification coverage, and proof.

No global Hodge, Yang–Mills, Riemann-hypothesis, or reflexive-descent proof is supplied. No new error in an arXiv article is asserted. A correction or closure manuscript needs an exact source claim, faithful formalization, a complete result, and independent review.
