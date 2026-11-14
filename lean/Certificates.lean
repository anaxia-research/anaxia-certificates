import Std

/-
  Reproducible, elementary certificates for the Anaxia methods report.
  These are known examples, not closures of named research conjectures.
  Only Lean core/Std are imported; no extra assumptions are declared.
-/

namespace AnaxiaResearch

structure Vec4 where
  x : Int
  y : Int
  z : Int
  w : Int
  deriving DecidableEq, Repr

def normSquared (v : Vec4) : Int :=
  v.x * v.x + v.y * v.y + v.z * v.z + v.w * v.w

def distanceSquared (u v : Vec4) : Int :=
  (u.x - v.x) * (u.x - v.x) +
  (u.y - v.y) * (u.y - v.y) +
  (u.z - v.z) * (u.z - v.z) +
  (u.w - v.w) * (u.w - v.w)

/-- The 24 vectors with two nonzero coordinates, each equal to +1 or -1. -/
def d4Roots : List Vec4 := [
  ⟨1, 1, 0, 0⟩, ⟨1, -1, 0, 0⟩, ⟨-1, 1, 0, 0⟩, ⟨-1, -1, 0, 0⟩,
  ⟨1, 0, 1, 0⟩, ⟨1, 0, -1, 0⟩, ⟨-1, 0, 1, 0⟩, ⟨-1, 0, -1, 0⟩,
  ⟨1, 0, 0, 1⟩, ⟨1, 0, 0, -1⟩, ⟨-1, 0, 0, 1⟩, ⟨-1, 0, 0, -1⟩,
  ⟨0, 1, 1, 0⟩, ⟨0, 1, -1, 0⟩, ⟨0, -1, 1, 0⟩, ⟨0, -1, -1, 0⟩,
  ⟨0, 1, 0, 1⟩, ⟨0, 1, 0, -1⟩, ⟨0, -1, 0, 1⟩, ⟨0, -1, 0, -1⟩,
  ⟨0, 0, 1, 1⟩, ⟨0, 0, 1, -1⟩, ⟨0, 0, -1, 1⟩, ⟨0, 0, -1, -1⟩]

theorem d4_count : d4Roots.length = 24 := by decide

theorem d4_distinct : d4Roots.Nodup := by decide

theorem d4_norms : ∀ v ∈ d4Roots, normSquared v = 2 := by decide

theorem d4_pair_separation :
    d4Roots.Pairwise (fun u v => 2 ≤ distanceSquared u v) := by decide

theorem d4_distance_two_witness :
    distanceSquared ⟨1, 1, 0, 0⟩ ⟨1, 0, 1, 0⟩ = 2 := by decide

/-- Every integer square is zero or one modulo four. -/
theorem square_mod_four (n : Int) : (n * n) % 4 = 0 ∨ (n * n) % 4 = 1 := by
  have h : n % 4 = 0 ∨ n % 4 = 1 ∨ n % 4 = 2 ∨ n % 4 = 3 := by omega
  rcases h with h | h | h | h <;> simp [Int.mul_emod, h]

/-- A universal elementary impossibility, not merely a bounded search. -/
theorem no_integer_sum_squares_three (x y : Int) : x * x + y * y ≠ 3 := by
  have hx := square_mod_four x
  have hy := square_mod_four y
  omega

/-- The related equation with right side two does have an integer solution. -/
theorem sum_squares_two_witness : (1 : Int) * 1 + 1 * 1 = 2 := by decide

#print axioms d4_count
#print axioms d4_distinct
#print axioms d4_norms
#print axioms d4_pair_separation
#print axioms d4_distance_two_witness
#print axioms square_mod_four
#print axioms no_integer_sum_squares_three
#print axioms sum_squares_two_witness

end AnaxiaResearch
