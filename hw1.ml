open List;;

(* Returns true iff a is a subset of b *)
let rec subset a b =
  match a with
    [] -> true
  | h::t 
    -> let is_head element = element == h in
    List.exists is_head b && subset t b;;

(* Returns true iff the represented sets are equal *)
let equal_sets a b = subset a b && subset b a;;

(* Returns a list represented by a union b *)
let set_union a b =
  let combo = a@b in List.sort_uniq compare combo;;

let rec _set_intersection a b = 
  match a with
    [] -> []
  | h::t -> if subset [h] b then [h]@(_set_intersection t b) else _set_intersection t b ;;

(* Returns a list represented by a intersection b *)
let set_intersection a b = 
  let a_no_duplicates = List.sort_uniq compare a in
  _set_intersection a_no_duplicates b;;

let rec _set_diff a b = 
  match a with
    [] -> []
  | h::t
    -> if subset [h] b then _set_diff t b else [h]@(_set_diff t b);;

(* Returns a list representing a - b *)  
let set_diff a b = 
  _set_diff (List.sort_uniq compare a) b;;

(* Returns computed fixed point for f with respect to x *)
let rec computed_fixed_point eq f x = 
  let result = f x in
  if eq result x then x else computed_fixed_point eq f result;;

let rec _first_p_points f p x = 
  if p == 0 then [] else let head = f x in [head]@(_first_p_points f (p - 1) head);;
  
let rec _computed_periodic_point last_p eq f p x =
  let result = f x in
  match last_p with
   [] -> x
  | h::t -> if eq h result then h else _computed_periodic_point (t@[result]) eq f p result;;

(* Returns computed periodic point for f with period p with respect to x *)
let computed_periodic_point eq f p x =
  if p == 0 then x else
  let first_p = _first_p_points f p x in
  let last = List.nth first_p (p - 1) in
  _computed_periodic_point first_p eq f p last;;

(* Returns the longest list [x; s x; s (s x); ...] such that p e is true for every element e in the list*)
let rec while_away s p x = 
  let e = s x in if p e then [e]@(while_away s p e) else [];;

let rec multiply value times =
  if times == 0 then [] else [value]@(multiply value (times - 1));;

let rec rle_decode lp =
  match lp with
    [] -> []
  | h::t
    -> let times, value = h in
    (multiply value times)@(rle_decode t);;

type ('nonterminal, 'terminal) symbol =
  | N of 'nonterminal
  | T of 'terminal



let filter_blind_alleys g =
  let start, rules = g in
  
  let rec _remove_terminals _rules finished =
    let is_terminal element =
      let _, dependencies = element in
      List.for_all (fun symbol -> match symbol with T x -> true | N y -> subset [y] finished) dependencies
    in

    match _rules with
      [] -> []
    | h::t 
      -> if is_terminal h then _remove_terminals t finished else [h]@(_remove_terminals t finished)
  in

  let remove_terminals rules_and_finished =
    
    let _rules, finished = rules_and_finished in
    let no_terminals = _remove_terminals _rules finished in
    let now_finished, _ = List.split (set_diff _rules no_terminals) in
    no_terminals, (set_union finished now_finished)
    
  in
    

  let blind_alleys, _ = computed_fixed_point (fun pair1 pair2 -> let x, _ = pair1 in let y, _ = pair2 in List.length x == List.length y) remove_terminals (rules,[]) in
  let is_not_blind_alley element = List.for_all (fun alley -> alley != element) blind_alleys in
  let _rules = List.filter is_not_blind_alley rules in 
  start, _rules;;