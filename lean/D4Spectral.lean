import Std

namespace AnaxiaResearch

/-- Arithmetic step of AM–GM after naming the smallest entry `a`. -/
private theorem triple_bound_min (a b c : Rat)
    (ha : 0 ≤ a) (hab : a ≤ b) (hac : a ≤ c) :
    27 * a * b * c ≤ (a+b+c)^3 := by
  have h1 : 0 ≤ b-a := by grind
  have h2 : 0 ≤ c-a := by grind
  have h3 := Rat.mul_nonneg h1 h2
  have hs : 0 ≤ ((b-a)-(c-a))*((b-a)-(c-a)) := by
    have h : 0 ≤ ((b-a)-(c-a))^2 := Lean.Grind.OrderedRing.sq_nonneg
    grind
  have ht : 0 ≤ (b-a)+(c-a) := by grind
  have hcub := Rat.mul_nonneg (Rat.mul_nonneg ht ht) ht
  have hexpand : (a+b+c)^3 - 27*a*b*c =
      9*a*(((b-a)-(c-a))*((b-a)-(c-a)) + (b-a)*(c-a)) +
      (((b-a)+(c-a))*((b-a)+(c-a)))*((b-a)+(c-a)) := by grind
  have hcoef : 0 ≤ 9*a := by exact Rat.mul_nonneg (by decide) ha
  have hpart := Rat.mul_nonneg hcoef (Rat.add_nonneg hs h3)
  grind

theorem d4_spectral_cubic (q : Rat) :
    27 * (1 + 4 * (q-1)^2) - 16*q^3 = (2*q-3)^2*(15-4*q) := by
  grind

theorem d4_triple_bound (x y z : Rat) (hx : 0 ≤ x) (hy : 0 ≤ y) (hz : 0 ≤ z) :
    27 * x * y * z ≤ (x+y+z)^3 := by
  by_cases hxy : x ≤ y
  · by_cases hxz : x ≤ z
    · exact triple_bound_min x y z hx hxy hxz
    · have h := triple_bound_min z x y hz (by grind) (by grind)
      grind
  · by_cases hyz : y ≤ z
    · have h := triple_bound_min y x z hy (by grind) hyz
      grind
    · have h := triple_bound_min z x y hz (by grind) (by grind)
      grind

/-- The negative-product case after permuting and, if needed, negating all four inputs. -/
theorem d4_spectral_one_negative (x y z w : Rat)
    (hx : 0 ≤ x) (hy : 0 ≤ y) (hz : 0 ≤ z) (_hw : 0 ≤ w)
    (hx1 : x ≤ 1) (hy1 : y ≤ 1) (hz1 : z ≤ 1) (hw1 : w ≤ 1) :
    -9 ≤ 4*(x+y+z-w)^2 - 16*x*y*z*w - 8 := by
  let q := x+y+z
  have hq0 : 0 ≤ q := by grind
  have hq3 : q ≤ 3 := by grind
  have hqprod := d4_triple_bound x y z hx hy hz
  have hxyz : 0 ≤ x*y*z := Rat.mul_nonneg (Rat.mul_nonneg hx hy) hz
  have hprod := Rat.mul_le_mul_of_nonneg_left hw1 hxyz
  have hsq : 0 ≤ (q-w)^2 := Lean.Grind.OrderedRing.sq_nonneg
  by_cases hq1 : q ≤ 1
  · have hp2 := Rat.mul_le_mul_of_nonneg_left hq1 hq0
    have hp3 := Rat.mul_le_mul_of_nonneg_left hq1 (Rat.mul_nonneg hq0 hq0)
    have hq3le : q^3 ≤ 1 := by grind
    grind
  · have hdiff0 : 0 ≤ q-1 := by grind
    have hdiff1 : q-1 ≤ q-w := by grind
    have hm1 := Rat.mul_le_mul_of_nonneg_left hdiff1 hdiff0
    have hm2 := Rat.mul_le_mul_of_nonneg_right hdiff1 (by grind : 0 ≤ q-w)
    have hcompare : (q-1)^2 ≤ (q-w)^2 := by grind
    have hfac := Rat.mul_nonneg (Lean.Grind.OrderedRing.sq_nonneg : 0 ≤ (2*q-3)^2) (by grind : 0 ≤ 15-4*q)
    have heq := d4_spectral_cubic q
    grind

private theorem nonnegative_product (a b c d : Rat) (hp : 0 ≤ a*b*c*d) :
    -9 ≤ 4*(a+b+c+d)^2 + 16*a*b*c*d - 8 := by
  have hs : 0 ≤ (a+b+c+d)^2 := Lean.Grind.OrderedRing.sq_nonneg
  grind

/-- Exact rational form of the lower bound on the D4 weighted Fourier symbol. -/
theorem d4_spectral_lower_bound (a b c d : Rat)
    (ha : -1 ≤ a) (ha1 : a ≤ 1) (hb : -1 ≤ b) (hb1 : b ≤ 1)
    (hc : -1 ≤ c) (hc1 : c ≤ 1) (hd : -1 ≤ d) (hd1 : d ≤ 1) :
    -9 ≤ 4*(a+b+c+d)^2 + 16*a*b*c*d - 8 := by
  rcases Rat.le_total (a := 0) (b := a) with sa | sa <;>
  rcases Rat.le_total (a := 0) (b := b) with sb | sb <;>
  rcases Rat.le_total (a := 0) (b := c) with sc | sc <;>
  rcases Rat.le_total (a := 0) (b := d) with sd | sd
  · exact nonnegative_product a b c d (Rat.mul_nonneg (Rat.mul_nonneg (Rat.mul_nonneg sa sb) sc) sd)
  · have h := d4_spectral_one_negative a b c (-d) sa sb sc (by grind) ha1 hb1 hc1 (by grind)
    grind
  · have h := d4_spectral_one_negative a b d (-c) sa sb sd (by grind) ha1 hb1 hd1 (by grind)
    grind
  · apply nonnegative_product
    rw [show a*b*c*d = (a*b)*((-c)*(-d)) by grind]
    exact Rat.mul_nonneg (Rat.mul_nonneg sa sb) (Rat.mul_nonneg (by grind) (by grind))
  · have h := d4_spectral_one_negative a c d (-b) sa sc sd (by grind) ha1 hc1 hd1 (by grind)
    grind
  · apply nonnegative_product
    rw [show a*b*c*d = (a*c)*((-b)*(-d)) by grind]
    exact Rat.mul_nonneg (Rat.mul_nonneg sa sc) (Rat.mul_nonneg (by grind) (by grind))
  · apply nonnegative_product
    rw [show a*b*c*d = (a*d)*((-b)*(-c)) by grind]
    exact Rat.mul_nonneg (Rat.mul_nonneg sa sd) (Rat.mul_nonneg (by grind) (by grind))
  · have h := d4_spectral_one_negative (-b) (-c) (-d) a (by grind) (by grind) (by grind) sa (by grind) (by grind) (by grind) ha1
    grind
  · have h := d4_spectral_one_negative b c d (-a) sb sc sd (by grind) hb1 hc1 hd1 (by grind)
    grind
  · apply nonnegative_product
    rw [show a*b*c*d = (b*c)*((-a)*(-d)) by grind]
    exact Rat.mul_nonneg (Rat.mul_nonneg sb sc) (Rat.mul_nonneg (by grind) (by grind))
  · apply nonnegative_product
    rw [show a*b*c*d = (b*d)*((-a)*(-c)) by grind]
    exact Rat.mul_nonneg (Rat.mul_nonneg sb sd) (Rat.mul_nonneg (by grind) (by grind))
  · have h := d4_spectral_one_negative (-a) (-c) (-d) b (by grind) (by grind) (by grind) sb (by grind) (by grind) (by grind) hb1
    grind
  · apply nonnegative_product
    rw [show a*b*c*d = (c*d)*((-a)*(-b)) by grind]
    exact Rat.mul_nonneg (Rat.mul_nonneg sc sd) (Rat.mul_nonneg (by grind) (by grind))
  · have h := d4_spectral_one_negative (-a) (-b) (-d) c (by grind) (by grind) (by grind) sc (by grind) (by grind) (by grind) hc1
    grind
  · have h := d4_spectral_one_negative (-a) (-b) (-c) d (by grind) (by grind) (by grind) sd (by grind) (by grind) (by grind) hd1
    grind
  · apply nonnegative_product
    rw [show a*b*c*d = ((-a)*(-b))*((-c)*(-d)) by grind]
    exact Rat.mul_nonneg (Rat.mul_nonneg (by grind) (by grind)) (Rat.mul_nonneg (by grind) (by grind))

theorem d4_spectral_sharp :
    4*((1/2 : Rat)+1/2+1/2-1)^2 + 16*(1/2 : Rat)*(1/2 : Rat)*(1/2 : Rat)*(-1) - 8 = -9 := by grind

#print axioms d4_spectral_lower_bound
#print axioms d4_spectral_sharp

end AnaxiaResearch
