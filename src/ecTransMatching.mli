(* --------------------------------------------------------------------
 * Copyright (c) - 2012--2016 - IMDEA Software Institute
 * Copyright (c) - 2012--2018 - Inria
 * Copyright (c) - 2012--2018 - Ecole Polytechnique
 *
 * Distributed under the terms of the CeCILL-C-V1 license
 * -------------------------------------------------------------------- *)

(* -------------------------------------------------------------------- *)
open EcParsetree
open EcPattern
open EcGenRegexp


(* -------------------------------------------------------------------- *)
val trans_stmt : pim_regexp -> EcIdent.t EcMaps.Mstr.t * pattern gen_regexp

val trans_block : pim_block -> EcIdent.t EcMaps.Mstr.t * pattern
