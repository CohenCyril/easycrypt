(* -------------------------------------------------------------------- *)
open EcUtils
open EcPath
open EcTypes
open EcFol

(* -------------------------------------------------------------------- *)
type ty_param  = EcIdent.t * EcPath.Sp.t
type ty_params = ty_param list

type tydecl = {
  tyd_params : ty_params;
  tyd_type   : ty_body;
}

and ty_body = [
  | `Concrete of EcTypes.ty
  | `Abstract of Sp.t
  | `Datatype of (EcSymbols.symbol * EcTypes.ty option) list
]

(* -------------------------------------------------------------------- *)
type locals = EcIdent.t list 

type operator_kind = 
  | OB_oper of opbody option
  | OB_pred of EcFol.form option

and opbody =
  | OP_Plain of EcTypes.expr

type operator = {
  op_tparams : ty_params;
  op_ty      : EcTypes.ty;        
  op_kind    : operator_kind;
}

val op_ty   : operator -> ty
val is_pred : operator -> bool

val mk_op   : ty_params -> ty -> opbody option -> operator
val mk_pred : ty_params -> ty list -> form option -> operator

(* -------------------------------------------------------------------- *)
type axiom_kind = [`Axiom | `Lemma]

type axiom = {
  ax_tparams : ty_params;
  ax_spec    : EcFol.form option;
  ax_kind    : axiom_kind;
  ax_nosmt   : bool;
}

(* -------------------------------------------------------------------- *)
type typeclass = {
  tc_ops : (EcIdent.t * EcTypes.ty) list;
  tc_axs : form list;
}
