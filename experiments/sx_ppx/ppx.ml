open struct
  module Expansion_context = Ppxlib.Expansion_context
  module Extension = Ppxlib.Extension
  module Ast_builder = Ppxlib.Ast_builder
  module Ast_pattern = Ppxlib.Ast_pattern
  module Ast_helper = Ppxlib.Ast_helper
  module Driver = Ppxlib.Driver
  module B = Ast_builder.Default
  module T = Ppxlib.Parsetree
  module Loc = Ppxlib.Loc
  module Id = Ppxlib.Longident
end

module Def = struct
  let utility_lid = Id.Lident "Sx"
end

let state = ref []
let noloc = Ppxlib.Location.none
let mkloc = Ppxlib.Loc.make
let mknoloc x = Ppxlib.Loc.make ~loc:noloc x
let focus_exp = Ppxlib.Merlin_helpers.focus_expression

let log =
  let out = open_out_gen [ Open_append; Open_wronly ] 0o777 "/tmp/x" in
  fun x -> output_string out (x ^ "\n")

let expand ~ctxt model =
  let loc = Expansion_context.Extension.extension_point_loc ctxt in
  let open_decl =
    Ast_builder.Default.open_infos ~loc
      ~expr:
        (Ast_builder.Default.pmod_ident ~loc
           (Ppxlib.Loc.make ~loc Def.utility_lid))
      ~override:Ppxlib.Asttypes.Fresh
  in
  let output_class_name = B.estring ~loc "TODO" in
  let ignored =
    B.pexp_apply ~loc
      (B.pexp_ident ~loc:noloc (mknoloc (Id.Lident "ignore")))
      [ (Nolabel, B.elist ~loc model) ]
  in
  let output = B.pexp_sequence ~loc ignored output_class_name in
  (* let output = B.pexp_tuple ~loc [ output_class_name; focus_exp output_css ] in *)
  (* let output =
       {
         output_exp with
         pexp_attributes =
           [
             B.attribute ~loc ~name:(mknoloc "merlin.focus")
               ~payload:(PStr [ input_pstr_eval ]);
           ];
       }
     in *)
  (* let output = B.elist ~loc input in *)
  (* let replacement = B.ebool ~loc true in *)
  Ast_builder.Default.pexp_open ~loc open_decl output

let extension =
  Extension.V3.declare "css" Ppxlib.Extension.Context.expression
    Ast_pattern.(single_expr_payload (esequence __))
    expand

let () =
  Ppxlib.Driver.V2.register_transformation "css" ~extensions:[ extension ]
    ~impl:(fun _ctxt items ->
      let cache = B.pstr_eval ~loc:noloc (B.elist ~loc:noloc !state) [] in
      let cache_item =
        B.pstr_attribute ~loc:noloc
          (B.attribute ~loc:noloc
             ~name:(Loc.make ~loc:noloc "css")
             ~payload:(PStr [ cache ]))
      in
      cache_item :: items)
