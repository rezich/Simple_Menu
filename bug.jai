Thing :: struct(items: ..Subthing) { proc :: () { (#import "Basic").log("It works!"); }; }
Subthing :: struct { text: string; }
CONSTANT :: #type Thing( .{"A"}, .{"B"} );
main :: () { CONSTANT.proc(); }