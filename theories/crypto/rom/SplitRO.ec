require import AllCore PROM SmtMap Distr DProd.

(* TODO: should we move this in SmtMap ? *)
op o_union (_:'a) (x y : 'b option) = if x = None then y else x.

lemma o_union_none a : o_union <:'a,'b> a None None = None.
proof. done. qed.

op union_map (m1 m2: ('a, 'b)fmap) = merge o_union m1 m2.

lemma set_union_map_l (m1 m2: ('a, 'b)fmap) x y: 
  (union_map m1 m2).[x <- y] = union_map m1.[x <- y] m2.
proof. 
  have hn := o_union_none <:'a, 'b>.
  by apply fmap_eqP => z; rewrite mergeE // !get_setE mergeE // /#. 
qed. 

lemma set_union_map_r (m1 m2:('a, 'b)fmap) x y:
  x \notin m1 => 
  (union_map m1 m2).[x <- y] = union_map m1 m2.[x <- y].
proof. 
  have hn := o_union_none <:'a, 'b>.
  by move=> h; apply fmap_eqP => z; rewrite mergeE // !get_setE mergeE // /#. 
qed. 

lemma mem_union_map (m1 m2:('a, 'b)fmap) x: (x \in union_map m1 m2) = (x \in m1 || x \in m2).
proof. have hn := o_union_none <:'a, 'b>; rewrite /dom mergeE // /#. qed. 

op o_pair (_:'a) (x: 'b1 option) (y:'b2 option) = 
  if x = None /\ y = None then None
  else Some (oget x, oget y).

lemma o_pair_none a : o_pair <:'a,'b1, 'b2> a None None = None.
proof. done. qed.

op pair_map (m1:('a, 'b1)fmap) (m2:('a, 'b2)fmap) = merge o_pair m1 m2.

lemma set_pair_map (m1: ('a, 'b1)fmap) (m2: ('a, 'b2)fmap) x y: 
  (pair_map m1 m2).[x <- y] = pair_map m1.[x <- y.`1] m2.[x <- y.`2].
proof. 
  have hn := o_pair_none <:'a, 'b1, 'b2>.
  by apply fmap_eqP => z; rewrite mergeE // !get_setE mergeE // /#. 
qed. 

lemma mem_pair_map (m1: ('a, 'b1)fmap) (m2: ('a, 'b2)fmap) x: (x \in pair_map m1 m2) = (x \in m1 || x \in m2).
proof. have hn := o_pair_none <:'a, 'b1, 'b2>; rewrite /dom mergeE // /#. qed. 

abstract theory Split.

  type from, to, input, output.

  op sampleto : from -> to distr.

  clone import Ideal as IdealAll with 
    type from <- from,
    type to   <- to,
    type input <- input,
    type output <- output,
    op sampleto <- sampleto.

abstract theory SplitDom.

op test : from -> bool.

module RO_DOM(ROT : RO, ROF: RO) : RO = {
  proc init () = { ROT.init(); ROF.init(); }
 
  proc get(x : from) = {
    var r;
    if (test x) r <@ ROT.get(x);
    else r <@ ROF.get(x);
    return r;
  }

  proc set(x : from, y : to) = {
    if (test x) ROT.set(x, y);
    else ROF.set(x, y);
  }

  proc rem(x : from) = {
    if (test x) ROT.rem(x);
    else ROF.rem(x);
  }

  proc sample(x : from) = {
    if (test x) ROT.sample(x);
    else ROF.sample(x);
  }
}.

clone MkRO as ROT.
clone MkRO as ROF.

section PROOFS.
  declare module D: RO_Distinguisher { RO, ROT.RO, ROF.RO }.

  equiv RO_split: 
    MainD(D,RO).distinguish ~ MainD(D,RO_DOM(ROT.RO,ROF.RO)).distinguish : 
      ={glob D, x} ==> ={res, glob D} /\ RO.m{1} = union_map ROT.RO.m{2} ROF.RO.m{2} /\
                     (forall x, x \in ROT.RO.m{2} => test x) /\
                     (forall x, x \in ROF.RO.m{2} => !test x).
  proof.
    proc. 
    call (_: RO.m{1} = union_map ROT.RO.m{2} ROF.RO.m{2} /\
             (forall x, x \in ROT.RO.m{2} => test x) /\
             (forall x, x \in ROF.RO.m{2} => !test x)).
    + by proc; inline *; auto => /> &2 _ _; rewrite merge_empty /=; smt (mem_empty).
    + by proc; inline *;if{2}; auto; smt (get_setE mem_union_map set_union_map_l set_union_map_r mem_set mergeE).
    + by proc; inline *;if{2}; auto; smt (get_setE mem_union_map set_union_map_l set_union_map_r mem_set mergeE).
    + by proc; inline *; auto => />; smt (rem_id mem_rem rem_merge).
    + proc; inline *; if{2}; auto; smt (get_setE mem_union_map set_union_map_l set_union_map_r mem_set mergeE).
    by inline *; auto; smt(merge_empty mem_empty).
  qed.

  (* Remark: this is not the most general result *)
  lemma pr_RO_split (p: glob D -> output -> bool) &m x0: 
    Pr[ MainD(D,RO).distinguish(x0) @ &m : p (glob D) res] =
    Pr[ MainD(D,RO_DOM(ROT.RO,ROF.RO)).distinguish(x0) @ &m : p (glob D) res].
  proof. by byequiv RO_split. qed.

end section PROOFS.

end SplitDom.

abstract theory SplitCodom.

type to1, to2.

op topair : to -> to1 * to2.
op ofpair : to1 * to2 -> to.

axiom topairK: cancel topair ofpair.
axiom ofpairK: cancel ofpair topair.

op sampleto1 : from -> to1 distr.
op sampleto2 : from -> to2 distr.

axiom sample_spec (f:from) : sampleto f = dmap (sampleto1 f `*` sampleto2 f) ofpair.

clone Ideal as I1 with
  type from <- from,
  type to <- to1,
  type input <- input,
  type output <- output,
  op sampleto <- sampleto1.

clone Ideal as I2 with
  type from <- from,
  type to <- to2,
  type input <- input,
  type output <- output,
  op sampleto <- sampleto2.

module RO_Pair(RO1:I1.RO, RO2:I2.RO) : RO = {
  proc init () = { RO1.init(); RO2.init(); }
 
  proc get(x : from) = {
    var r1, r2;
    r1 <@ RO1.get(x);
    r2 <@ RO2.get(x);
    return ofpair(r1,r2);
  }

  proc set(x : from, y : to) = {
    RO1.set(x,(topair y).`1); RO2.set(x,(topair y).`2);
  }

  proc rem(x : from) = {
    RO1.rem(x); RO2.rem(x);
  }

  proc sample(x : from) = {
    RO1.sample(x); RO2.sample(x);
  }

}.

section PROOFS.

  declare module D : RO_Distinguisher { RO, I1.RO, I2.RO }.

  local clone import ProdSampling with
    type t1 <- to1,
    type t2 <- to2.

  equiv RO_get : RO.get ~ RO_Pair(I1.RO, I2.RO).get : 
     ={x} /\
      RO.m{1} = map (fun (_ : from) => ofpair) (pair_map I1.RO.m{2} I2.RO.m{2}) /\
      forall (x : from),  x \in RO.m{1} = x \in I1.RO.m{2} /\ x \in RO.m{1} = x \in I2.RO.m{2} 
     ==>
     ={res} /\
      RO.m{1} = map (fun (_ : from) => ofpair) (pair_map I1.RO.m{2} I2.RO.m{2}) /\
      forall (x : from), x \in RO.m{1} = x \in I1.RO.m{2} /\ x \in RO.m{1} = x \in I2.RO.m{2}.
  proof.
    proc; inline *.
    swap{2} 5 -3; swap{2} 6 -2; sp 0 2.
    seq 1 2 : (#pre /\ r{1} = ofpair (r{2}, r0{2})).
    + conseq />.
      transitivity*{2} { (r,r0) <@ S.sample2(sampleto1 x0, sampleto2 x1); } => //; 1: smt().
      + transitivity*{2} { (r,r0) <@ S.sample(sampleto1 x0, sampleto2 x1); } => //; 1: smt().
        + inline *; wp; rnd topair ofpair; auto => /> &2 ?; split.
          + by move=> ??; rewrite ofpairK. 
          move=> _; split.
          + move=> [t1 t2]?; rewrite sample_spec dmap1E; congr; apply fun_ext => p. 
            by rewrite /pred1 /(\o) (can_eq _ _ ofpairK).
          move=> _ t; rewrite sample_spec supp_dmap => -[[t1 t2] []] + ->>.
          by rewrite topairK ofpairK => ->.
        by call sample_sample2; auto.
      by inline *; auto => />.
    by auto; smt (get_setE map_set set_pair_map mem_map mem_pair_map mem_set mapE mergeE).
  qed.

  equiv RO_split: 
    MainD(D,RO).distinguish ~ MainD(D,RO_Pair(I1.RO,I2.RO)).distinguish : 
      ={glob D, x} ==> ={res, glob D} /\ RO.m{1} = map (fun _ => ofpair) (pair_map I1.RO.m{2} I2.RO.m{2}) /\
                       forall x, x \in RO.m{1} = x \in I1.RO.m{2} /\ x \in RO.m{1} = x \in I2.RO.m{2}.
  proof.
    proc.
    call (_: RO.m{1} = map (fun _ => ofpair) (pair_map I1.RO.m{2} I2.RO.m{2}) /\
             forall x, x \in RO.m{1} = x \in I1.RO.m{2} /\ x \in RO.m{1} = x \in I2.RO.m{2}).
    + proc; inline *;auto => /> &2 _. 
      have hn := o_pair_none <: from, to1, to2>. 
      by rewrite merge_empty // map_empty /= => ?; rewrite !mem_empty. 
    + by conseq RO_get.
    + by proc; inline *; auto => />;
       smt (get_setE map_set set_pair_map mem_map mem_pair_map mem_set mapE mergeE ofpairK topairK).
    + by proc; inline *; auto; smt (map_rem rem_merge mem_map mem_pair_map mem_rem).
    + proc *.
      alias{1} 1 y = witness <:to>; alias{2} 1 y = witness <:to>. 
      transitivity*{1} { y <@ RO.get(x); } => //;1: smt().
      + by inline *; sim.
      transitivity*{2} { y <@  RO_Pair(I1.RO, I2.RO).get(x); } => //; 1:smt().
      + by call RO_get.
      by inline *; sim.
    inline *; auto => />.
    have hn := o_pair_none <: from, to1, to2>. 
    by rewrite merge_empty // map_empty /= => ?; rewrite !mem_empty.
  qed.

  lemma pr_RO_split (p: glob D -> output -> bool) &m x0: 
    Pr[ MainD(D,RO).distinguish(x0) @ &m : p (glob D) res] =
    Pr[ MainD(D,RO_Pair(I1.RO,I2.RO)).distinguish(x0) @ &m : p (glob D) res].
  proof. by byequiv RO_split. qed.

end section PROOFS.

end SplitCodom.

end Split.
