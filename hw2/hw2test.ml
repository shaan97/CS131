type proof =
  | Var | Equation | Expression | Binop | Next

let math =
  (Equation,
  function
    | Var ->
      [[T"a"];[T"b"];[T"c"];[T"d"];[T"e"];[T"f"];[T"g"];[T"h"];[T"i"];[T"j"];[T"k"];
      [T"l"];[T"m"];[T"n"];[T"o"];[T"p"];[T"q"];[T"r"];[T"s"];[T"t"];[T"u"];[T"v"];
      [T"w"];[T"x"];[T"y"];[T"z"];]
    | Equation ->
      [[N Var; T"="; N Expression]; [N Var; T"="; N Expression; N Next; N Equation]; ]
    | Next ->
      [[T "->"]; [T "^"]; [T "v"]]
    | Expression ->
      [[T"("; N Expression; T ")"];[T"("; N Expression; T ")"; N Binop; N Expression];[N Var];[N Var; N Binop; N Expression]]
    | Binop ->
      [[T"="]; [T"+"]; [T"-"]; [T"*"]; [T"/"]]
  )

let acceptor x y = match y with | [] -> Some(x,y) | _ -> None;; 
let test_1 = ((parse_prefix math acceptor ["a"; "="; "b"; "^"; "b"; "="; "c"; "->"; "a"; "=";"c"]) =
Some
([(Equation, [N Var; T "="; N Expression; N Next; N Equation]);
  (Var, [T "a"]); (Expression, [N Var]); (Var, [T "b"]); (Next, [T "^"]);
  (Equation, [N Var; T "="; N Expression; N Next; N Equation]);
  (Var, [T "b"]); (Expression, [N Var]); (Var, [T "c"]); (Next, [T "->"]);
  (Equation, [N Var; T "="; N Expression]); (Var, [T "a"]);
  (Expression, [N Var]); (Var, [T "c"])],
 []));;
let test_2 = ((parse_prefix math acceptor ["d"; "="; "a"; "*"; "("; "b"; "+"; "c"; ")"; "->";"d"; "="; "("; "a"; "*"; "b"; ")"; "+"; "("; "a"; "*"; "c"; ")"]) =
Some
([(Equation, [N Var; T "="; N Expression; N Next; N Equation]);
  (Var, [T "d"]); (Expression, [N Var; N Binop; N Expression]);
  (Var, [T "a"]); (Binop, [T "*"]);
  (Expression, [T "("; N Expression; T ")"]);
  (Expression, [N Var; N Binop; N Expression]); (Var, [T "b"]);
  (Binop, [T "+"]); (Expression, [N Var]); (Var, [T "c"]);
  (Next, [T "->"]); (Equation, [N Var; T "="; N Expression]);
  (Var, [T "d"]);
  (Expression, [T "("; N Expression; T ")"; N Binop; N Expression]);
  (Expression, [N Var; N Binop; N Expression]); (Var, [T "a"]);
  (Binop, [T "*"]); (Expression, [N Var]); (Var, [T "b"]);
  (Binop, [T "+"]); (Expression, [T "("; N Expression; T ")"]);
  (Expression, [N Var; N Binop; N Expression]); (Var, [T "a"]);
  (Binop, [T "*"]); (Expression, [N Var]); (Var, [T "c"])],
 []))
