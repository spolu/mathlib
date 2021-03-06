/-
Copyright (c) 2020 Adam Topaz. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Author: Scott Morrison, Adam Topaz.
-/

import ring_theory.algebra
import linear_algebra
import data.monoid_algebra

/-!
# Free Algebras

Given a commutative semiring `R`, and a type `X`, we construct the free `R`-algebra on `X`.

## Notation

1. `free_algebra R X` is the free algebra itself. It is endowed with an `R`-algebra structure.
2. `free_algebra.ι R X` is the function `X → free_algebra R X`.
3. Given a function `f : X → A` to an R-algebra `A`, `lift R X f` is the lift of `f` to an
  `R`-algebra morphism `free_algebra R X → A`.

## Theorems

1. `ι_comp_lift` states that the composition `(lift R X f) ∘ (ι R X)` is identical to `f`.
2. `lift_unique` states that whenever an R-algebra morphism `g : free_algebra R X → A` is
  given whose composition with `ι R X` is `f`, then one has `g = lift R X f`.
3. `hom_ext` is a variant of `lift_unique` in the form of an extensionality theorem.
4. `lift_comp_ι` is a combination of `ι_comp_lift` and `lift_unique`. It states that the lift
  of the composition of an algebra morphism with `ι` is the algebra morphism itself.
5. `equiv_monoid_algebra_free_monoid : free_algebra R X ≃ₐ[R] monoid_algebra R (free_monoid X)`

## Implementation details

We construct the free algebra on `X` as a quotient of an inductive type `free_algebra.pre` by an inductively defined relation `free_algebra.rel`.
Explicitly, the construction involves three steps:
1. We construct an inductive type `free_algebra.pre R X`, the terms of which should be thought
  of as representatives for the elements of `free_algebra R X`.
  It is the free type with maps from `R` and `X`, and with two binary operations `add` and `mul`.
2. We construct an inductive relation `free_algebra.rel R X` on `free_algebra.pre R X`.
  This is the smallest relation for which the quotient is an `R`-algebra where addition resp.
  multiplication are induced by `add` resp. `mul` from 1., and for which the map from `R` is the
  structure map for the algebra.
3. The free algebra `free_algebra R X` is the quotient of `free_algebra.pre R X` by
  the relation `free_algebra.rel R X`.
-/

variables (R : Type*) [comm_semiring R]
variables (X : Type*)

namespace free_algebra

/--
This inductive type is used to express representatives of the free algebra.
-/
inductive pre
| of : X → pre
| of_scalar : R → pre
| add : pre → pre → pre
| mul : pre → pre → pre

namespace pre

instance : inhabited (pre R X) := ⟨of_scalar 0⟩

-- Note: These instances are only used to simplify the notation.
/-- Coercion from `X` to `pre R X`. Note: Used for notation only. -/
def has_coe_generator : has_coe X (pre R X) := ⟨of⟩
/-- Coercion from `R` to `pre R X`. Note: Used for notation only. -/
def has_coe_semiring : has_coe R (pre R X) := ⟨of_scalar⟩
/-- Multiplication in `pre R X` defined as `pre.mul`. Note: Used for notation only. -/
def has_mul : has_mul (pre R X) := ⟨mul⟩
/-- Addition in `pre R X` defined as `pre.add`. Note: Used for notation only. -/
def has_add : has_add (pre R X) := ⟨add⟩
/-- Zero in `pre R X` defined as the image of `0` from `R`. Note: Used for notation only. -/
def has_zero : has_zero (pre R X) := ⟨of_scalar 0⟩
/-- One in `pre R X` defined as the image of `1` from `R`. Note: Used for notation only. -/
def has_one : has_one (pre R X) := ⟨of_scalar 1⟩
/--
Scalar multiplication defined as multiplication by the image of elements from `R`.
Note: Used for notation only.
-/
def has_scalar : has_scalar R (pre R X) := ⟨λ r m, mul (of_scalar r) m⟩

end pre

local attribute [instance]
  pre.has_coe_generator pre.has_coe_semiring pre.has_mul pre.has_add pre.has_zero
  pre.has_one pre.has_scalar

/--
Given a function from `X` to an `R`-algebra `A`, `lift_fun` provides a lift of `f` to a function
from `pre R X` to `A`. This is mainly used in the construction of `free_algebra.lift`.
-/
def lift_fun {A : Type*} [semiring A] [algebra R A] (f : X → A) : pre R X → A :=
  λ t, pre.rec_on t f (algebra_map _ _) (λ _ _, (+)) (λ _ _, (*))

/--
An inductively defined relation on `pre R X` used to force the initial algebra structure on
the associated quotient.
-/
inductive rel : (pre R X) → (pre R X) → Prop
-- force `of_scalar` to be a central semiring morphism
| add_scalar {r s : R} : rel ↑(r + s) (↑r + ↑s)
| mul_scalar {r s : R} : rel ↑(r * s) (↑r * ↑s)
| central_scalar {r : R} {a : pre R X} : rel (r * a) (a * r)
-- commutative additive semigroup
| add_assoc {a b c : pre R X} : rel (a + b + c) (a + (b + c))
| add_comm {a b : pre R X} : rel (a + b) (b + a)
| zero_add {a : pre R X} : rel (0 + a) a
-- multiplicative monoid
| mul_assoc {a b c : pre R X} : rel (a * b * c) (a * (b * c))
| one_mul {a : pre R X} : rel (1 * a) a
| mul_one {a : pre R X} : rel (a * 1) a
-- distributivity
| left_distrib {a b c : pre R X} : rel (a * (b + c)) (a * b + a * c)
| right_distrib {a b c : pre R X} : rel ((a + b) * c) (a * c + b * c)
-- other relations needed for semiring
| zero_mul {a : pre R X} : rel (0 * a) 0
| mul_zero {a : pre R X} : rel (a * 0) 0
-- compatibility
| add_compat_left {a b c : pre R X} : rel a b → rel (a + c) (b + c)
| add_compat_right {a b c : pre R X} : rel a b → rel (c + a) (c + b)
| mul_compat_left {a b c : pre R X} : rel a b → rel (a * c) (b * c)
| mul_compat_right {a b c : pre R X} : rel a b → rel (c * a) (c * b)

end free_algebra

/--
The free algebra for the type `X` over the commutative semiring `R`.
-/
def free_algebra := quot (free_algebra.rel R X)

namespace free_algebra

local attribute [instance]
  pre.has_coe_generator pre.has_coe_semiring pre.has_mul pre.has_add pre.has_zero
  pre.has_one pre.has_scalar

instance : semiring (free_algebra R X) :=
{ add := quot.map₂ (+) (λ _ _ _, rel.add_compat_right) (λ _ _ _, rel.add_compat_left),
  add_assoc := by { rintros ⟨⟩ ⟨⟩ ⟨⟩, exact quot.sound rel.add_assoc },
  zero := quot.mk _ 0,
  zero_add := by { rintro ⟨⟩, exact quot.sound rel.zero_add },
  add_zero := begin
    rintros ⟨⟩,
    change quot.mk _ _ = _,
    rw [quot.sound rel.add_comm, quot.sound rel.zero_add],
  end,
  add_comm := by { rintros ⟨⟩ ⟨⟩, exact quot.sound rel.add_comm },
  mul := quot.map₂ (*) (λ _ _ _, rel.mul_compat_right) (λ _ _ _, rel.mul_compat_left),
  mul_assoc := by { rintros ⟨⟩ ⟨⟩ ⟨⟩, exact quot.sound rel.mul_assoc },
  one := quot.mk _ 1,
  one_mul := by { rintros ⟨⟩, exact quot.sound rel.one_mul },
  mul_one := by { rintros ⟨⟩, exact quot.sound rel.mul_one },
  left_distrib := by { rintros ⟨⟩ ⟨⟩ ⟨⟩, exact quot.sound rel.left_distrib },
  right_distrib := by { rintros ⟨⟩ ⟨⟩ ⟨⟩, exact quot.sound rel.right_distrib },
  zero_mul := by { rintros ⟨⟩, exact quot.sound rel.zero_mul },
  mul_zero := by { rintros ⟨⟩, exact quot.sound rel.mul_zero } }

instance : inhabited (free_algebra R X) := ⟨0⟩

instance : has_scalar R (free_algebra R X) :=
{ smul := λ r a, quot.lift_on a (λ x, quot.mk _ $ ↑r * x) $
  λ a b h, quot.sound (rel.mul_compat_right h) }

instance : algebra R (free_algebra R X) :=
{ to_fun := λ r, quot.mk _ r,
  map_one' := rfl,
  map_mul' := λ _ _, quot.sound rel.mul_scalar,
  map_zero' := rfl,
  map_add' := λ _ _, quot.sound rel.add_scalar,
  commutes' := λ _, by { rintros ⟨⟩, exact quot.sound rel.central_scalar },
  smul_def' := λ _ _, rfl }

/--
The canonical function `X → free_algebra R X`.
-/
def ι : X → free_algebra R X := λ m, quot.mk _ m

@[simp] lemma quot_mk_eq_ι (m : X) : quot.mk (free_algebra.rel R X) m = ι R X m := rfl

/--
Given a function `f : X → A` where `A` is an `R`-algebra, `lift R X f` is the unique lift
of `f` to a morphism of `R`-algebras `free_algebra R X → A`.
-/
def lift {A : Type*} [semiring A] [algebra R A] (f : X → A) : free_algebra R X →ₐ[R] A :=
{ to_fun := λ a, quot.lift_on a (lift_fun _ _ f) $ λ a b h,
  begin
    induction h,
    { exact (algebra_map R A).map_add h_r h_s, },
    { exact (algebra_map R A).map_mul h_r h_s },
    { apply algebra.commutes },
    { change _ + _ + _ = _ + (_ + _),
      rw add_assoc },
    { change _ + _ = _ + _,
      rw add_comm, },
    { change (algebra_map _ _ _) + lift_fun R X f _ = lift_fun R X f _,
      simp, },
    { change _ * _ * _ = _ * (_ * _),
      rw mul_assoc },
    { change (algebra_map _ _ _) * lift_fun R X f _ = lift_fun R X f _,
      simp, },
    { change lift_fun R X f _ * (algebra_map _ _ _) = lift_fun R X f _,
      simp, },
    { change _ * (_ + _) = _ * _ + _ * _,
      rw left_distrib, },
    { change (_ + _) * _ = _ * _ + _ * _,
      rw right_distrib, },
    { change (algebra_map _ _ _) * _ = algebra_map _ _ _,
      simp },
    { change _ * (algebra_map _ _ _) = algebra_map _ _ _,
      simp },
    repeat { change lift_fun R X f _ + lift_fun R X f _ = _,
      rw h_ih,
      refl, },
    repeat { change lift_fun R X f _ * lift_fun R X f _ = _,
      rw h_ih,
      refl, },
  end,
  map_one' := by { change algebra_map _ _ _ = _, simp },
  map_mul' := by { rintros ⟨⟩ ⟨⟩, refl },
  map_zero' := by { change algebra_map _ _ _ = _, simp },
  map_add' := by { rintros ⟨⟩ ⟨⟩, refl },
  commutes' := by tauto }

variables {R X}

@[simp]
theorem ι_comp_lift {A : Type*} [semiring A] [algebra R A] (f : X → A) :
  (lift R X f : free_algebra R X → A) ∘ (ι R X) = f := by {ext, refl}

@[simp]
theorem lift_ι_apply {A : Type*} [semiring A] [algebra R A] (f : X → A) (x) :
  lift R X f (ι R X x) = f x := rfl

@[simp]
theorem lift_unique {A : Type*} [semiring A] [algebra R A] (f : X → A)
  (g : free_algebra R X →ₐ[R] A) :
  (g : free_algebra R X → A) ∘ (ι R X) = f ↔ g = lift R X f :=
begin
  refine ⟨λ hyp, _, λ hyp, by rw [hyp, ι_comp_lift]⟩,
  ext,
  rcases x,
  induction x,
  { change ((g : free_algebra R X → A) ∘ (ι R X)) _ = _,
    rw hyp,
    refl },
  { exact alg_hom.commutes g x },
  { change g (quot.mk _ _ + quot.mk _ _) = _,
    rw [alg_hom.map_add, x_ih_a, x_ih_a_1],
    refl },
  { change g (quot.mk _ _ * quot.mk _ _) = _,
    rw [alg_hom.map_mul, x_ih_a, x_ih_a_1],
    refl },
end

/-!
At this stage we set the basic definitions as `@[irreducible]`, so from this point onwards one should only use the universal properties of the free algebra, and consider the actual implementation as a quotient of an inductive type as completely hidden.

Of course, one still has the option to locally make these definitions `semireducible` if so desired, and Lean is still willing in some circumstances to do unification based on the underlying definition.
-/
attribute [irreducible] free_algebra ι lift

@[simp]
theorem lift_comp_ι {A : Type*} [semiring A] [algebra R A] (g : free_algebra R X →ₐ[R] A) :
  lift R X ((g : free_algebra R X → A) ∘ (ι R X)) = g := by {symmetry, rw ←lift_unique}

@[ext]
theorem hom_ext {A : Type*} [semiring A] [algebra R A] {f g : free_algebra R X →ₐ[R] A}
  (w : ((f : free_algebra R X → A) ∘ (ι R X)) = ((g : free_algebra R X → A) ∘ (ι R X))) : f = g :=
begin
  have : g = lift R X ((g : free_algebra R X → A) ∘ (ι R X)), by rw ←lift_unique,
  rw [this, ←lift_unique, w],
end

/--
The free algebra on `X` is "just" the monoid algebra on the free monoid on `X`.

This would be useful when constructing linear maps out of a free algebra,
for example.
-/
noncomputable
def equiv_monoid_algebra_free_monoid : free_algebra R X ≃ₐ[R] monoid_algebra R (free_monoid X) :=
alg_equiv.of_alg_hom
  (lift R X (λ x, (monoid_algebra.of R (free_monoid X)) (free_monoid.of x)))
  ((monoid_algebra.lift R (free_monoid X) (free_algebra R X)) (free_monoid.lift (ι R X)))
begin
  apply monoid_algebra.alg_hom_ext, intro x,
  apply free_monoid.rec_on x,
  { simp, refl, },
  { intros x y ih, simp at ih, simp [ih], }
end
(by { ext, simp, })

end free_algebra
