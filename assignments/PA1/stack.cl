(*
 *  CS164 Fall 94
 *
 *  Programming Assignment 1
 *    Implementation of a simple stack machine.
 *
 *  Skeleton file
 *)

class Main inherits IO {

   oplist : List <- new List;
   op : String;
   a2itool : A2I <- new A2I;

   prompt() : Bool {
      {
         out_string(">");
         op <- in_string();
         if op = "" then
            false
         else if op = "x" then
            false
         else
            true
         fi fi;
      }
   };

   main() : Int {
      (* out_string("Nothing implemented\n")*)
      run()
   };

   run() : Int {
      {
         while prompt() loop {
            if op = "d" then {
               oplist.printList();
            } else if op = "e" then {
               if not oplist.isNil() then
                  exec()
               else 1 fi;
            } else
               oplist <- oplist.cons(op)
            fi fi;
         } pool;
         1;
      }
   };
   exec() : Int {
      let op : String <- oplist.head() in {
         -- out_string("eop:");
         -- out_string(op);
         -- out_string("\n");
         if op = "+" then {
            oplist.pop();
            let n1 : Int <- a2itool.a2i(oplist.head()),
                rt : Bool <- oplist.pop(),
                n2 : Int <- a2itool.a2i(oplist.head()),
                rt : Bool <- oplist.pop() in {
               oplist <- oplist.cons(a2itool.i2a(n1 + n2));
            };
         } else if op = "s" then {
            oplist.pop();
            let item1: String <- oplist.head(),
                rt : Bool <- oplist.pop(),
                item2: String <- oplist.head(),
                rt : Bool <- oplist.pop() in {
               oplist <- oplist.cons(item1);
               oplist <- oplist.cons(item2);
            };
         } else
            0
         fi fi;
         1;
      }
   };
};

class List inherits IO {
   head() : String {{ abort(); "nil"; }};
   tail() : List {{ abort(); self; }};
   pop() : Bool {{ abort(); false; }};
   isNil() : Bool { true };
   printList() : IO { self };
   cons(s : String) : List {
      (new Cons).init(s, self)
   };
};

class Cons inherits List {
   car : String;
   cdr : List;
   head() : String { car };
   tail() : List{ cdr };
   pop() : Bool {
      {
         -- out_string("pop:");
         -- out_string(car);
         -- out_string("\n");
         if not (cdr.isNil()) then {
            car <- cdr.head();
            cdr <- cdr.tail();
            true;
         } else {
            --car <- "nil";
            false;
         } fi;
      }
   };

   isNil() : Bool { car = "nil" };

   printList() : IO {
      {
         if not isNil() then {
            out_string(car);
            out_string("\n");
            cdr.printList();
         } else self fi;
      }
   };
   init(s : String, tail : List) : SELF_TYPE {
      {
         car <- s;
         cdr <- tail;
         self;
      }
   };
};

(*copy from A2I*)
(*
   c2i   Converts a 1-character string to an integer.  Aborts
         if the string is not "0" through "9"
*)
class A2I {

     c2i(char : String) : Int {
	if char = "0" then 0 else
	if char = "1" then 1 else
	if char = "2" then 2 else
        if char = "3" then 3 else
        if char = "4" then 4 else
        if char = "5" then 5 else
        if char = "6" then 6 else
        if char = "7" then 7 else
        if char = "8" then 8 else
        if char = "9" then 9 else
        { abort(); 0; }  (* the 0 is needed to satisfy the
				  typchecker *)
        fi fi fi fi fi fi fi fi fi fi
     };

(*
   i2c is the inverse of c2i.
*)
     i2c(i : Int) : String {
	if i = 0 then "0" else
	if i = 1 then "1" else
	if i = 2 then "2" else
	if i = 3 then "3" else
	if i = 4 then "4" else
	if i = 5 then "5" else
	if i = 6 then "6" else
	if i = 7 then "7" else
	if i = 8 then "8" else
	if i = 9 then "9" else
	{ abort(); ""; }  -- the "" is needed to satisfy the typchecker
        fi fi fi fi fi fi fi fi fi fi
     };

(*
   a2i converts an ASCII string into an integer.  The empty string
is converted to 0.  Signed and unsigned strings are handled.  The
method aborts if the string does not represent an integer.  Very
long strings of digits produce strange answers because of arithmetic 
overflow.

*)
     a2i(s : String) : Int {
        if s.length() = 0 then 0 else
	if s.substr(0,1) = "-" then ~a2i_aux(s.substr(1,s.length()-1)) else
        if s.substr(0,1) = "+" then a2i_aux(s.substr(1,s.length()-1)) else
           a2i_aux(s)
        fi fi fi
     };

(* a2i_aux converts the usigned portion of the string.  As a
   programming example, this method is written iteratively.  *)


     a2i_aux(s : String) : Int {
	(let int : Int <- 0 in	
           {	
               (let j : Int <- s.length() in
	          (let i : Int <- 0 in
		    while i < j loop
			{
			    int <- int * 10 + c2i(s.substr(i,1));
			    i <- i + 1;
			}
		    pool
		  )
	       );
              int;
	    }
        )
     };

(* i2a converts an integer to a string.  Positive and negative 
   numbers are handled correctly.  *)

    i2a(i : Int) : String {
	if i = 0 then "0" else 
        if 0 < i then i2a_aux(i) else
          "-".concat(i2a_aux(i * ~1)) 
        fi fi
    };
	
(* i2a_aux is an example using recursion.  *)		

    i2a_aux(i : Int) : String {
        if i = 0 then "" else 
	    (let next : Int <- i / 10 in
		i2a_aux(next).concat(i2c(i - next * 10))
	    )
        fi
    };

};
