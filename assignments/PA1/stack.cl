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
