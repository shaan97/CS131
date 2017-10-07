

let my_subset_test0 = subset [] [[]]
let my_subset_test1 = subset [[]] [[]]
let my_subset_test2 = not (subset [[]] [])
let my_subset_test3 = not (subset [3] [1;2;4;5;6;4;6;7;2])
let my_subset_test4 = subset [9;0;2;1;0] [0;9;2;1]
let my_subset_test5 = subset [1;2;3;4;5;2] [5;4;3;2;1;0;0;1;2;3;4;5]

let my_equal_sets_test0 = equal_sets [] []
let my_equal_sets_test1 = equal_sets [1;2;1;2;1;2;1] [2;1]
let my_equal_sets_test2 = not (equal_sets [0] [1;2;3;0])
let my_equal_sets_test3 = equal_sets [2;1;5;3;2] [1;2;3;5]

let my_set_union_test0 = set_union [] [] = []
let my_set_union_test1 = equal_sets (set_union [3;2;1] [1;2;3]) [1;2;3]
let my_set_union_test2 = equal_sets (set_union [1;2] [2;3]) [1;2;3]
let my_set_union_test3 = equal_sets (set_union [2;2;2] []) [2]

let my_set_intersection_test0 = set_intersection [] [] = []
let my_set_intersection_test1 = set_intersection [1;2;3;4] [] = []
let my_set_intersection_test2 = set_intersection [[]] [] = []
let my_set_intersection_test3 = equal_sets (set_intersection [1;2;3] [2]) [2]

let my_set_diff_test0 = equal_sets (set_diff [1;2;3] [2]) [1;3]
let my_set_diff_test1 = equal_sets (set_diff [1;2;3] [4;5;6]) [1;2;3]
let my_set_diff_test2 = equal_sets (set_diff [4;5;6] [1;2;3]) [4;5;6]
let my_set_diff_test3 = set_diff [] [] = []

let my_computed_fixed_point_test0 = (computed_fixed_point (=) (fun x -> x) 16) = 16
let my_computed_fixed_point_test1 = (computed_fixed_point (=) (fun y -> 1) 27) = 1
let my_computed_fixed_point_test3 = (computed_fixed_point (fun x y -> abs_float (x -. y) < 1.) (fun y -> y /. 2.) 10.) = 1.25

let my_computed_periodic_point_test0 = (computed_periodic_point (=) (fun x -> x) 50 50) = 50

let my_while_away_test0 = (while_away (fun x -> x * 2) (fun e -> e < 100) 1) = [2;4;8;16;32;64]
let my_while_away_test1 = (while_away (fun x -> 0) (fun e -> e != 0) 1) = []

let my_rle_decode_test0 = (rle_decode [1, "w"; 10, "a"; 5, "z"; 10, "a"; 10, "p"]) = ["w";"a";"a";"a";"a";"a";"a";"a";"a";"a";"a";"z";"z";"z";"z";"z";"a";"a";"a";"a";"a";"a";"a";"a";"a";"a";"p";"p";"p";"p";"p";"p";"p";"p";"p";"p"]
let my_rle_decode_test1 = (rle_decode [5, 0; 4, 1; 3, 0; 2, 1; 1, 0; 0, 1]) = [0;0;0;0;0;1;1;1;1;0;0;0;1;1;0]

type nonterminals = | Ya | Boi | H0lla | At | Me

let rules = 
  [Ya, [N Boi];
  Boi, [N H0lla];
  H0lla, [N At];
  At, [N Me];
  Me, [T"1"]]

let grammar = Ya, rules
let my_filter_blind_alleys_test0 = filter_blind_alleys grammar = grammar

let new_rules =
  [Ya, [T""; N Boi; T "yo"];
  Boi, [N Ya];
  Me, [T"yo"]]

let new_grammar = Ya, new_rules
let my_filter_blind_alleys_test1 = filter_blind_alleys new_grammar = (Ya, [Me, [T"yo"]])