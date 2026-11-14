# Lean proof of the D4 spectral bound

The theorem `AnaxiaResearch.d4_spectral_lower_bound` proves, for rational inputs $a,b,c,d\in[-1,1]$,

$$4(a+b+c+d)^2+16abcd-8\ge -9.$$

The theorem `AnaxiaResearch.d4_spectral_sharp` verifies equality at $(1/2,1/2,1/2,-1)$. The proof checks a polynomial form of AM–GM, the cubic factorization for the nontrivial sign case, and the complete sign split.

Run `lean lean/D4Spectral.lean` from the repository root using its pinned Lean toolchain. The module imports `Std` and prints the axiom dependencies of the two public results. Those dependencies are the standard `propext`, `Classical.choice`, and `Quot.sound`.

The statement checked by Lean is over `Rat`. Polynomial continuity and the density of the rationals extend it to the real cube in the written argument. The graph Fourier calculation, finite graph independence bound, and limit over packing windows also appear in the written proof. Together they address the fixed-grid intermediate interval. [Anaxia’s proof of the sharp packing density on the fixed D4 grid](https://github.com/anaxia-research/anaxia/blob/main/docs/D4-INTERMEDIATE-GRID.md)
