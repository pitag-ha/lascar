(* These FSM models check whether values on its input [e] alternates between 0 and 1
   and sets its output [s] whenever this condition fails *)

(* First model : three states and no variable *)

module S1 =
    struct
      type t = Init | E0 | E1
      let compare = compare
      let to_string = function Init -> "Init" | E0 -> "E0" | E1 -> "E1"
    end

open S1

module F1 = Fsm.Make(S1)

let m1 = F1.create
  ~inps:["e",[0;1]]
  ~outps:["s",[0;1]]
  ~vars:[]
  ~states:[Init,[]; E0,[]; E1,[]]
  ~istate:("s:=0", Init)
  ~trans:[
    Init, ("e=0",""), E0;
    Init, ("e=1",""), E1;
    E0, ("e=1","s:=0"), E1;
    E0, ("e=0","s:=1"), E0;
    E1, ("e=0","s:=0"), E0;
    E1, ("e=1","s:=1"), E1;
    ]

let _ = F1.dot_output "m1"  m1

(* Second model : using a variable to memorize the last read input value *)

module S2 =
    struct
      type t = Init | E
      let compare = compare
      let to_string = function Init -> "Init" | E -> "E"
    end

open S2

module F2 = Fsm.Make(S2)

let m2 = F2.create
  ~inps:["e",[0;1]]
  ~outps:["s",[0;1]]
  ~vars:["last",[0;1]]
  ~states:[Init,[]; E,[]]
  ~istate:("s:=0", Init)
  ~trans:[
    Init, ("e=0","last:=0"), E;
    Init, ("e=1","last:=1"), E;
    E, ("e=1;last=0","s:=0;last:=1"), E;
    E, ("e=1;last=1","s:=1"), E;
    E, ("e=0;last=1","s:=0;last:=0"), E;
    E, ("e=0;last=0","s:=1"), E;
    ]

let _ = F2.dot_output "m2"  m2

(* Let's check that, by defactorizing [m2] wrt. variable [last] we get back to [m1] : *)
      
module FF2 = Conv.Fsm(F2)

let m3 = FF2.defactorize ~init:(Some ("",(Init,["last",0]))) ["last"] m2

let _ = FF2.dot_output ~options:[Dot.RankdirUD] "m3" m3