# anaxia certificates

Lean proofs and independent Julia checks for reproducible mathematical research.

| Artifact | Verified scope |
| --- | --- |
| [Certificates.lean](lean/Certificates.lean) | Eight statements about 24 explicit D4 roots, their exact norms and distances, and an elementary obstruction to writing 3 as a sum of two integer squares. |
| [D4Spectral.lean](lean/D4Spectral.lean) | The sharp lower bound of −9 for the weighted D4 polynomial on the rational cube, with an equality point. |
| [Julia replication](julia/verify.jl) | Exact integer and rational checks of the roots, a polynomial identity, a changed-coefficient rejection, and a rational counterexample. |
| [D4 grid replay](julia/verify_d4_intermediate_grid.jl) | An independent exact calculation on all 648 period-six characters and all 2,556 pairs in the attaining packing. |

The D4 root construction and the modular example are established facts. The spectral theorem concerns the specified rational polynomial. The [written packing argument](https://github.com/anaxia-research/anaxia/blob/main/docs/D4-INTERMEDIATE-GRID.md) explains continuity, graph bounds, and the limit over windows. [Proof scope](PROOF-SCOPE.md)

## Run the checks

Use Lean 4.34.1, Julia 1.10+, and Python 3.11+.

```sh
lean lean/Certificates.lean
lean lean/D4Spectral.lean
julia --startup-file=no julia/verify.jl --output reports/julia-verification.toml
julia --startup-file=no julia/verify_d4_intermediate_grid.jl --output reports/d4-intermediate-grid.toml
python scripts/validate.py --lean PATH_TO_LEAN --julia PATH_TO_JULIA --require-julia
```

The [verification record](reports/validation.json) includes source hashes and actual execution status. The [source record](SOURCE-ORIGIN.json) identifies the companion revision used for this extraction. The software retains its MIT attribution.

## Related projects

[Core workbench](https://github.com/anaxia-research/anaxia) · [Documentation](https://github.com/anaxia-research/anaxia-docs) · [Celestial proofs](https://github.com/anaxia-research/celestial-infrared-stability)

Contact [egspl@proton.me](mailto:egspl@proton.me).
