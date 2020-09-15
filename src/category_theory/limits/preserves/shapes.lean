/-
Copyright (c) 2020 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison
-/
import category_theory.limits.preserves.basic
import category_theory.limits.shapes.products

universes v u₁ u₂

noncomputable theory

open category_theory category_theory.category category_theory.limits

variables {C : Type u₁} [category.{v} C]
variables {D : Type u₂} [category.{v} D]
variables (G : C ⥤ D)

section
variables {J : Type v} [small_category J]
variables (F : J ⥤ C) [has_limit F] [has_limit (F ⋙ G)] [preserves_limit F G]
/--
If `G` preserves limits, we have an isomorphism from the image of the limit of a functor `F`
to the limit of the functor `F ⋙ G`.
-/
def preserves_limit_iso : G.obj (limit F) ≅ limit (F ⋙ G) :=
(preserves_limit.preserves (limit.is_limit _)).cone_point_unique_up_to_iso (limit.is_limit _)

@[simp, reassoc]
lemma preserves_limits_iso_hom_π (j) :
  (preserves_limit_iso G F).hom ≫ limit.π _ j = G.map (limit.π F j) :=
is_limit.cone_point_unique_up_to_iso_hom_comp _ _ j

@[simp, reassoc]
lemma preserves_limits_iso_inv_π (j) :
  (preserves_limit_iso G F).inv ≫ G.map (limit.π F j) = limit.π _ j :=
is_limit.cone_point_unique_up_to_iso_inv_comp _ _ j

@[simp]
lemma preserves_lift_map_cone (c₁ c₂ : cone F) (t : is_limit c₁) :
  (preserves_limit.preserves t).lift (G.map_cone _) = G.map (t.lift c₂) :=
((preserves_limit.preserves t).uniq (G.map_cone _) _ (by simp [← G.map_comp])).symm

@[simp, reassoc]
lemma lift_comp_preserves_limits_iso_hom (t : cone F) :
  G.map (limit.lift _ t) ≫ (preserves_limit_iso G F).hom = limit.lift (F ⋙ G) (G.map_cone _) :=
by { ext, simp [← G.map_comp] }
end

section preserve_products

variables {J : Type v} (f : J → C)
variables [has_products_of_shape J C] [has_products_of_shape J D]
variables [preserves_limits_of_shape (discrete J) G]
/--
If `G` preserves limits, we have an isomorphism
from the image of a product to the product of the images.
-/
-- TODO perhaps weaken the assumptions here, to just require the relevant limits?
def preserves_products_iso :
  G.obj (∏ f) ≅ ∏ (λ j, G.obj (f j)) :=
preserves_limit_iso G (discrete.functor f) ≪≫
  has_limit.iso_of_nat_iso (discrete.nat_iso (λ j, iso.refl _))

@[simp, reassoc]
lemma preserves_products_iso_hom_π (j) :
  (preserves_products_iso G f).hom ≫ pi.π _ j = G.map (pi.π f j) :=
by simp [preserves_products_iso]

@[simp, reassoc]
lemma map_lift_comp_preserves_products_iso_hom (P : C) (g : Π j, P ⟶ f j) :
  G.map (pi.lift g) ≫ (preserves_products_iso G f).hom = pi.lift (λ j, G.map (g j)) :=
by { ext, simp [preserves_products_iso] }

end preserve_products
