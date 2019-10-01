require import AllCore Finite.

pragma -oldip.
pragma +implicits.

(** A type for Z-modules over some type 'a **)
type 'a zmodule =
  [ PreZMod of ('a -> bool)     (* support *)
             & 'a               (* zero *)
             & ('a -> 'a)       (* inverse *)
             & ('a -> 'a -> 'a) (* operation *)
  ].

(** Notations **)
op mem (m : 'a zmodule): 'a -> bool =
  with m = PreZMod m _ _ _ => m.

abbrev (\in) (x : 'a) (m : 'a zmodule) = mem m x.

op e (m : 'a zmodule): 'a =
  with m = PreZMod _ e _ _ => e.

op n (m : 'a zmodule): 'a -> 'a =
  with m = PreZMod _ _ n _ => n.

op o (m : 'a zmodule): 'a -> 'a -> 'a =
  with m = PreZMod _ _ _ o => o.

(** Some of those are not Z-modules **)
(** PROBLEM: We now have plenty of distinct representations of the same group. **)
inductive iszmodule (m : 'a zmodule) =
  | IsZMod of (e m \in m)
            & (forall x y, x \in m => y \in m => (o m) x y \in m)
            & (forall x, x \in m => (n m) x \in m)

            & (forall x y z, x \in m => y \in m => z \in m =>
                             (o m) x ((o m) y z) = (o m) ((o m) x y) z)
            & (forall x y, x \in m => y \in m => (o m) x y = (o m) y x)

            & (forall x, x \in m => (o m) (e m) x = x)
            & (forall x, x \in m => (o m) ((n m) x) x = e m).

(** But those that are enjoy great properties **)
lemma erM (m : 'a zmodule) :
  iszmodule m =>
  e m \in m.
proof. by case=> ->. qed.

lemma addrM (m : 'a zmodule) (x y : 'a) :
  iszmodule m =>
  x \in m => y \in m =>
  (o m) x y \in m.
proof. by case=> _ + _ _ _ _ _ x_in_m y_in_m - ->. qed.

lemma opprM (m : 'a zmodule) (x : 'a) :
  iszmodule m =>
  x \in m =>
  (n m) x \in m.
proof. by case=> _ _ h _ _ _ _ /h. qed.

lemma addrA (m : 'a zmodule) (x y z : 'a) :
  iszmodule m =>
  x \in m => y \in m => z \in m =>
  (o m) x ((o m) y z) = (o m) ((o m) x y) z.
proof. by case=> _ _ _ + _ _ _ x_in_m y_in_m z_in_m - ->. qed.

lemma addrC (m : 'a zmodule) (x y : 'a) :
  iszmodule m =>
  x \in m => y \in m =>
  (o m) x y = (o m) y x.
proof. by case=> _ _ _ _ + _ _ x_in_m y_in_m - ->. qed.

lemma add0r (m : 'a zmodule) (x : 'a) :
  iszmodule m =>
  x \in m =>
  (o m) (e m) x = x.
proof. by case=> _ _ _ _ _ + _ x_in_m - ->. qed.

lemma addNr (m : 'a zmodule) (x : 'a) :
  iszmodule m =>
  x \in m =>
  (o m) ((n m) x) x = e m.
proof. by case=> _ _ _ _ _ _ + x_in_m - ->. qed.

hint exact: erM addrM opprM addrA addrC add0r addNr.

(** And all derived properties **)
lemma addr0 (m : 'a zmodule) (x : 'a) :
  iszmodule m =>
  x \in m =>
  (o m) x (e m) = x.
proof. by move=> m_zmod x_in_m; rewrite addrC // add0r. qed.

lemma addrN (m : 'a zmodule) (x : 'a) :
  iszmodule m =>
  x \in m =>
  (o m) x ((n m) x) = e m.
proof. by move=> m_zmod x_in_m; rewrite addrC // addNr. qed.

lemma addrCA (m : 'a zmodule) (x y z : 'a) :
  iszmodule m =>
  x \in m => y \in m => z \in m =>
  (o m) x ((o m) y z) = (o m) y ((o m) x z).
proof.
move=> m_zmod x_in_m y_in_m z_in_m.
by rewrite !addrA // (@addrC _ x y).
qed.

lemma addrAC (m : 'a zmodule) (x y z : 'a) :
  iszmodule m =>
  x \in m => y \in m => z \in m =>
  (o m) ((o m) x y) z = (o m) ((o m) x z) y.
proof.
move=> m_zmod x_in_m y_in_m z_in_m.
by rewrite -!addrA // (@addrC _ y z).
qed.

lemma addrACA (m : 'a zmodule) (x y z t : 'a) :
  iszmodule m =>
  x \in m => y \in m => z \in m => t \in m =>
  (o m) ((o m) x y) ((o m) z t) = (o m) ((o m) x z) ((o m) y t).
proof.
move=> m_zmod x_in_m y_in_m z_in_m t_in_m.
by rewrite -!addrA // (@addrCA _ y z).
qed.

lemma addKr (m : 'a zmodule) (x y : 'a) :
  iszmodule m =>
  x \in m => y \in m =>
  (o m) ((n m) x) ((o m) x y) = y.
proof.
move=> m_zmod x_in_m y_in_m.
by rewrite addrA // addNr // add0r.
qed.

lemma addNKr (m : 'a zmodule) (x y : 'a) :
  iszmodule m =>
  x \in m => y \in m =>
  (o m) x ((o m) ((n m) x) y) = y.
proof.
move=> m_zmod x_in_m y_in_m.
by rewrite addrA // addrN // add0r.
qed.

lemma addrK (m : 'a zmodule) (x y : 'a) :
  iszmodule m =>
  x \in m => y \in m =>
  (o m) ((o m) x y) ((n m) y) = x.
proof.
move=> m_zmod x_in_m y_in_m.
by rewrite -addrA // addrN // addr0.
qed.

lemma addrNK (m : 'a zmodule) (y x : 'a) :
  iszmodule m =>
  x \in m => y \in m =>
  (o m) ((o m) x ((n m) y)) y = x.
proof.
move=> m_zmod x_in_m y_in_m.
by rewrite -addrA // addNr // addr0.
qed.

lemma addrI (m : 'a zmodule) (x y y' : 'a) :
  iszmodule m =>
  x \in m => y \in m => y' \in m =>
  (o m) x y = (o m) x y' => y = y'.
proof.
move=> m_zmod x_in_m y_in_m z_in_m h.
by rewrite -(@addKr m x y') // -h addKr.
qed.

lemma addIr (m : 'a zmodule) (y x x' : 'a) :
  iszmodule m =>
  x \in m => x' \in m => y \in m =>
  (o m) x y = (o m) x' y => x = x'.
proof.
move=> m_zmod x_in_m x'_in_m y_in_m h.
by rewrite -(@addrK m x' y) // -h addrK.
qed.

lemma opprK (m : 'a zmodule) (x : 'a) :
  iszmodule m =>
  x \in m =>
  (n m) ((n m) x) = x.
proof.
move=> m_zmod x_in_m; apply (@addIr m (n m x))=> //.
+ exact/opprM.
by rewrite addNr // addrN.
qed.

lemma oppr_inj (m : 'a zmodule) (x x' : 'a) :
  iszmodule m =>
  x \in m => x' \in m =>
  (n m) x = (n m) x' => x = x'.
proof.
move=> m_zmod x_in_m x'_in_m h.
by apply/(addIr m (n m x))=> //; rewrite addrN // h addrN.
qed.

lemma oppr0 (m : 'a zmodule) :
  iszmodule m =>
  (n m) (e m) = e m.
proof.
move=> m_zmod.
by rewrite -(@addr0 m ((n m) (e m))) ?addNr ?opprM ?erM.
qed.

lemma oppr_eq0 (m : 'a zmodule) (x : 'a) :
  iszmodule m =>
  x \in m =>
  (n m) x = e m <=> x = e m.
proof.
move=> m_zmod x_in_m.
split=> [|->>]; last by exact/oppr0.
by move/(congr1 (n m)); rewrite opprK // oppr0.
qed.

lemma opprD (m : 'a zmodule) (x y : 'a) :
  iszmodule m =>
  x \in m => y \in m =>
  (n m) ((o m) x y) = (o m) ((n m) x) ((n m) y).
proof.
move=> m_zmod x_in_m y_in_m.
apply/(@addrI m ((o m) x y))=> //.
+ by rewrite opprM.
+ by rewrite addrM.
by rewrite addrA // addrN // addrAC // addrK // addrN.
qed.

lemma opprB (m : 'a zmodule) (x y : 'a) :
  iszmodule m =>
  x \in m => y \in m =>
  (n m) ((o m) x ((n m) y)) = (o m) y ((n m) x).
proof.
move=> m_zmod x_in_m y_in_m.
by rewrite opprD // opprK // addrC.
qed.

lemma addrKA (m : 'a zmodule) (z x y : 'a) :
  iszmodule m =>
  z \in m => x \in m => y \in m =>
  (o m) ((o m) x z) ((n m) ((o m) z y)) = (o m) x ((n m) y).
proof.
move=> m_zmod z_in_m x_in_m y_in_m.
by rewrite opprD //  addrA // addrK.
qed.

lemma addr_eq0 (m : 'a zmodule) (x y : 'a) :
  iszmodule m =>
  x \in m => y \in m =>
  (o m) x y = e m <=> x = (n m) y.
proof.
move=> m_zmod x_in_m y_in_m.
split.
+ by rewrite addrC // -(@addr0 m ((n m) y))=> // <-; rewrite addKr.
by move=> ->; exact/addNr.
qed.

lemma eqr_opp (m : 'a zmodule) (x y : 'a) :
  iszmodule m =>
  x \in m => y \in m =>
  ((n m) x = (n m) y) <=> (x = y).
proof.
move=> m_zmod x_in_m y_in_m; split=> [|-> //].
exact/oppr_inj.
qed.

lemma eqr_oppLR (m : 'a zmodule) (x y : 'a) :
  iszmodule m =>
  x \in m => y \in m =>
  ((n m) x = y) <=> (x = (n m) y).
proof.
move=> m_zmod x_in_m y_in_m.
rewrite -{1}(@opprK m y) //; split=> [|-> //].
exact/oppr_inj.
qed.

(** And some derived operations **)
op intmul (m : 'a zmodule) (x : 'a) (c : int) =
  if   c < 0
  then (n m) (iterop (-c) (o m) x (e m))
  else       (iterop   c  (o m) x (e m)).

lemma iterM (c : int) (m : 'a zmodule) (x : 'a) :
  iszmodule m =>
  x \in m =>
  0 <= c =>
  iter c (o m x) x \in m.
proof.
move=> m_zmod x_in_m; elim: c=> [|c ge0_c ih].
+ by rewrite iter0.
by rewrite iterS.
qed.

lemma iteropM (c : int) (m : 'a zmodule) (x z : 'a) :
  0 <= c =>
  iszmodule m =>
  x \in m => z \in m =>
  iterop c (o m) x z \in m.
proof.
move=> + m_zmod x_in_m z_in_m; case: c=> [|c ge0_c ih].
+ by rewrite iterop0.
by rewrite iteropS // iterM.
qed.

hint exact: iteropM.

lemma intmulpE (m : 'a zmodule) (x : 'a) (c : int) :
  0 <= c =>
  intmul m x c = iterop c (o m) x (e m).
proof. by rewrite /intmul lezNgt=> ->. qed.

lemma mulr0z (m : 'a zmodule) (x : 'a) :
  intmul m x 0 = e m.
proof. by rewrite /intmul /= iterop0. qed.

lemma mulrNz (m : 'a zmodule) (x : 'a) (c : int) :
  iszmodule m =>
  x \in m =>
  intmul m x (-c) = (n m) (intmul m x c).
proof.
move=> m_zmod x_in_m.
case: (c = 0)=> [->|nz_c]; first by rewrite oppz0 mulr0z oppr0.
rewrite /intmul oppz_lt0 oppzK ltz_def nz_c lezNgt /=.
case: (c < 0)=> // lt0_c.
rewrite ?opprK //; apply/iteropM=> //.
by rewrite oppz_ge0; exact/ltzW.
qed.

(** Order of a group **)
op order ['a] (m : 'a zmodule): int.

axiom orderP (m : 'a zmodule) :
  iszmodule m =>
  order m =
    if   is_finite (mem m)
    then pcard (mem m)
    else 0.

inductive (\subgroup) (H : 'a -> bool) (G : 'a zmodule) =
  | IsSubgroup of (forall x, H x => x \in G)
                & (exists h, H h)
                & (forall x y, H x => H y =>
                     H ((o G) x ((n G) y))).

lemma subgroup0 (H : 'a -> bool) (G : 'a zmodule) :
  iszmodule G =>
  H \subgroup G =>
  H (e G).
proof.
move=> G_zmod [] H_subset_G H_neq_pred0 H_sub_closed.
move: H_neq_pred0=> [] h ^ /H_subset_G /(addrN _ _ G_zmod) <- h_in_H.
exact/H_sub_closed.
qed.

lemma subgroupN (H : 'a -> bool) (G : 'a zmodule) x :
  iszmodule G =>
  H \subgroup G =>
  H x =>
  H (n G x).
proof.
move=> G_zmod H_sub_G x_in_H.
move: (subgroup0 H G _ _)=> //= e_in_H.
case: H_sub_G=> H_sub_G _ /(_ _ _ e_in_H x_in_H).
by rewrite add0r // opprM //; exact/H_sub_G.
qed.

lemma subgroupA (H : 'a -> bool) (G : 'a zmodule) x y :
  iszmodule G =>
  H \subgroup G =>
  H x => H y =>
  H (o G x y).
proof.
move=> G_zmod H_sub_G x_in_H y_in_H.
move: (subgroupN H G y _ _ _)=> //= Ny_in_H.
case: H_sub_G=> H_sub_G _ /(_ x (n G y) _ _) //.
by rewrite opprK //; exact/H_sub_G.
qed.

lemma subgroup_isgroup (H : 'a -> bool) (G : 'a zmodule) :
  iszmodule G =>
  H \subgroup G =>
  iszmodule (PreZMod H (e G) (n G) (o G)).
proof.
move=> G_zmod H_sub_G; split=> //=.
+ exact/subgroup0.
+ move=> x y; exact/(subgroupA G_zmod H_sub_G).
+ move=> x; exact/(subgroupN).
+ by case: H_sub_G=> H_sub_G _ _ x y z /H_sub_G + /H_sub_G + /H_sub_G.
+ by case: H_sub_G=> H_sub_G _ _ x y /H_sub_G + /H_sub_G.
+ by case: H_sub_G=> H_sub_G _ _ x /H_sub_G.
by case: H_sub_G=> H_sub_G _ _ x /H_sub_G.
qed.
