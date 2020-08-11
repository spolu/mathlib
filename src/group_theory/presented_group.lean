/-
Copyright (c) 2019 Michael Howes. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Michael Howes

Defining a group given by generators and relations
-/
import group_theory.free_group
import group_theory.quotient_group

variables {α : Type}

/-- Given a set of relations, rels, over a type α, presented_group constructs the group with
generators α and relations rels as a quotient of free_group α.-/
def presented_group (rels : set (free_group α)) : Type :=
quotient_group.quotient $ subgroup.normal_closure rels

namespace presented_group

instance (rels : set (free_group α)) : group (presented_group (rels)) :=
quotient_group.group _

/-- `of x` is the canonical map from α to a presented group with generators α. The term x is
mapped to the equivalence class of the image of x in free_group α. -/
def of {rels : set (free_group α)} (x : α) : presented_group rels :=
quotient_group.mk (free_group.of x)

section to_group

/-
Presented groups satisfy a universal property. If β is a group and f : α → β is a map such that the
images of f satisfy all the given relations, then f extends uniquely to a group homomorphism from
presented_group rels to β
-/

variables {β : Type} [group β] {f : α → β} {rels : set (free_group α)}

local notation `F` := free_group.to_group f

variable (h : ∀ r ∈ rels, F r = 1)

-- FIXME why is apply_instance needed here? surely this should be a [] argument in `subgroup.normal_closure_le_normal`
lemma closure_rels_subset_ker : subgroup.normal_closure rels ≤ monoid_hom.ker F :=
subgroup.normal_closure_le_normal (by apply_instance) (λ x w, monoid_hom.mem_ker.2 (h x w))

lemma to_group_eq_one_of_mem_closure : ∀ x ∈ subgroup.normal_closure rels, F x = 1 :=
λ x w, monoid_hom.mem_ker.1 $ closure_rels_subset_ker h w

/-- The extension of a map f : α → β that satisfies the given relations to a group homomorphism
from presented_group rels → β. -/
def to_group : presented_group rels →* β :=
quotient_group.lift (subgroup.normal_closure rels) (monoid_hom.of F) (to_group_eq_one_of_mem_closure h)

@[simp] lemma to_group.of {x : α} : to_group h (of x) = f x := free_group.to_group.of

-- FIXME remove the next three, they're now unnecessary

@[simp] lemma to_group.mul {x y} : to_group h (x * y) = to_group h x * to_group h y :=
is_mul_hom.map_mul _ _ _

@[simp] lemma to_group.one : to_group h 1 = 1 :=
is_group_hom.map_one _

@[simp] lemma to_group.inv {x}: to_group h x⁻¹ = (to_group h x)⁻¹ :=
is_group_hom.map_inv _ _

theorem to_group.unique (g : presented_group rels →* β)
  (hg : ∀ x : α, g (of x) = f x) : ∀ {x}, g x = to_group h x :=
λ x, quotient_group.induction_on x
    (λ _, free_group.to_group.unique (g.comp (quotient_group.mk' _)) hg)

end to_group
end presented_group
