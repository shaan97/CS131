open List;;

type ('nonterminal, 'terminal) symbol =
  | N of 'nonterminal
  | T of 'terminal

let is_empty = function | [] -> true | _::_ -> false;;

let convert_grammar (start, rules) = (start, fun key -> (List.map (fun (x,y) -> y) (List.filter (fun (x, y) -> key = x) rules)));;

let rec parse_prefix gram accept frag =
  let start, production = gram in
  let alternative_list = production start in
  let rec find_alternate = function 
    | [] -> None
    | alternate::alternatives ->
      let rec parse_tokens derivation _frag = function
        | [] -> accept derivation _frag
        | symbol::symbols ->
          match symbol with 
            | T x -> 
              if ((is_empty _frag) || not ((List.hd _frag) = x)) then None else parse_tokens derivation (List.tl _frag) symbols 
            | N nonterminal ->
              let check_rest d f = parse_tokens (derivation@d) f symbols in
              parse_prefix (nonterminal, production) check_rest _frag
      in
      let result = parse_tokens [(start, alternate)] frag alternate in
      match result with Some(d,s) -> result | _ -> find_alternate alternatives 
  in
  find_alternate alternative_list
