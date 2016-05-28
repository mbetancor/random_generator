-module(randerl).
-export([main/1,start_main/0]).


-define(SIGN, [ " + ", " - "]).
-define(BNOT, [" bnot "]). %% ONLY FOR POSITIVE INTEGERS (Cast with abs(X)).
-define(NUM_ARITHMETIC_OPERATIONS, [" + ", " - ", " * ", " / "]).
-define(INT_ARITHMETIC_OPERATIONS, [" div ", " rem ", " band ", " bxor ", " bsl ", " bor ", " bsr "]).
-define(BOOL_OPS,  [" and ", " or ", " andalso ", " orelse ", " xor "]).
-define(ALL_COMP_OPS,  [" =:= ", " =/= ", " == ", " /= ", " >= ", " =< ", " > ", " < "]).
-define(COMP_OPS,[" >= "," =< "," > "," < "]). %% MORE STRICT OPERATIONS.
% -define(FUN_NAMES, [" foo ", " bar ", " qux ", " foobar ", " fooqux "]). NOT USED 
-define(ARG_NAMES, [" X "," Y "," Z "," A "," B "," C "]).
-define(NAT_TO_INT, [" round ", " trunc "]).



main(Desired_Name)->
	{ok,PF0} = file:open("randprog_"++Desired_Name++"_o0.erl", write),
	{ok,PF1} = file:open("randprog_"++Desired_Name++"_o1.erl", write),
	{ok,PF2} = file:open("randprog_"++Desired_Name++"_o2.erl", write),
	{ok,PF3} = file:open("randprog_"++Desired_Name++"_o3.erl", write),
	{ok,PF4} = file:open("randprog_"++Desired_Name++"_beam.erl", write),
	S0=io_lib:format("~s~s~s",["-module(randprog_",Desired_Name,"_o0).    \n-export([main/1]). \n"]),
	S1=io_lib:format("~s~s~s",["-module(randprog_",Desired_Name,"_o1).    \n-export([main/1]). \n"]),
	S2=io_lib:format("~s~s~s",["-module(randprog_",Desired_Name,"_o2).    \n-export([main/1]). \n"]),
	S3=io_lib:format("~s~s~s",["-module(randprog_",Desired_Name,"_o3).    \n-export([main/1]). \n"]),
	S4=io_lib:format("~s~s~s",["-module(randprog_",Desired_Name,"_beam).  \n-export([main/1]). \n"]),
	X = start_main(),
	io:put_chars(PF0,S0++X),
	io:put_chars(PF1,S1++X),
	io:put_chars(PF2,S2++X),
	io:put_chars(PF3,S3++X),
	io:put_chars(PF4,S4++X),
	file:close(PF0),
	file:close(PF1),
	file:close(PF2),
	file:close(PF3),
	file:close(PF4).

start_main() ->
	io_lib:format("~s",["main(List) -> 
		Start=time(),
		F = try foo(List) of 
			_ -> foo(List) 
			catch
				_:_ -> 42 
			end, 
		End=time(), 
		[timer:now_diff(End,Start),F].\n"]) ++
	io_lib:format("~s",["foo([]) -> \n"]) ++
	arithmetic_Operation([],random:uniform(5)) ++
	io_lib:format("~s",["; \n"]) ++
	generate_Functions(random:uniform(5)).

generate_Functions(0) ->
	Args = lists:sublist(?ARG_NAMES, random:uniform(length(?ARG_NAMES))),
	io_lib:format("~s",["foo(List) "]) ++
	io_lib:format("~s",[" -> \n"]) ++
	generate_Arguments(Args,[" hd(List) "]) ++
	cases_of(Args,random:uniform(4)) ++
	io_lib:format("~s",[" ."]);

generate_Functions(N) ->
	Args = lists:sublist(?ARG_NAMES, random:uniform(length(?ARG_NAMES))),
	io_lib:format("~s",["foo(List) when "]) ++
	generate_Comparisons([" hd(List) "],random:uniform(4)) ++
	io_lib:format("~s",[" -> \n"]) ++
	generate_Arguments(Args,[" hd(List) "]) ++
	cases_of(Args,random:uniform(4)) ++
	io_lib:format("~s",[" ;\n"]) ++
	generate_Functions(N-1).


%%TODO: DIFFERENCE BETWEEN VAR OR NUM
%% GENERATES ARGUMENTS: X = 9000 rem 4 * 5 + 6.0 ..
generate_Arguments([],_) -> [];
generate_Arguments([X|Xs],Vars) -> 
	OP = lists:nth(random:uniform(length(?INT_ARITHMETIC_OPERATIONS)), ?INT_ARITHMETIC_OPERATIONS),
	[NAT1,NAT2] = [lists:nth(random:uniform(2),?NAT_TO_INT),lists:nth(random:uniform(2),?NAT_TO_INT)],
	[Var1,Var2,Var3] = [arithmetic_Operation(Vars,random:uniform(3)), arithmetic_Operation(Vars,random:uniform(3)),
	arithmetic_Operation(Vars,random:uniform(2))],
	[B1,B2] = [lists:nth(random:uniform(2),[""," bnot abs"]), lists:nth(random:uniform(2),[""," bnot abs"])],
	BIG_ARG = 
	B1 ++  
	io_lib:format("~s",["("]) ++
	NAT1 ++
	io_lib:format("~s",["("]) ++
	parse_Argument(Var1) ++
	io_lib:format("~s",["))"]) ++
	OP ++ 
	B2 ++
	io_lib:format("~s",["("]) ++
	NAT2 ++
	io_lib:format("~s",["("]) ++
	parse_Argument(Var2) ++
	io_lib:format("~s",["))"]) ++
	parse_Argument(Var3),
	X ++ 
	io_lib:format("~s",[" = "]) ++ 
	io_lib:format("~s",["try "]) ++
	BIG_ARG ++
	io_lib:format("~s",[" of
		_ -> "]) ++
	BIG_ARG ++
	io_lib:format("~s~p~s",["
		catch
			_:_ -> ", num(), "
		end,
		"]) ++
	generate_Arguments(Xs,Vars++[X]).

%% Num OP Var, Num Op Num.
arithmetic_Operation(Vars,1) ->    
 	Var = lists:nth(random:uniform(length(Vars)+1), Vars++[num()]),
	Sign = lists:nth(random:uniform(length(?SIGN)), ?SIGN),
	Sign ++ parse_Argument(Var);
arithmetic_Operation(Vars,N) ->
	OP = lists:nth(random:uniform(length(?NUM_ARITHMETIC_OPERATIONS)), ?NUM_ARITHMETIC_OPERATIONS),
	Var = lists:nth(random:uniform(length(Vars)+1), Vars++[num()]), 
	Sign = lists:nth(random:uniform(length(?SIGN)), ?SIGN),
	Sign ++ parse_Argument(Var) ++ OP ++ arithmetic_Operation(Vars,N-1).


cases_of(Vars,N) -> 
	io_lib:format("~s",["case round (length(List) "]) ++
	arithmetic_Operation(Vars,N) ++
	io_lib:format("~s", [") rem 6 of \n "]) ++
	cases_in_detail(random:uniform(6),Vars).


cases_in_detail(0,Vars) ->
	OP = lists:nth(random:uniform(length(?NUM_ARITHMETIC_OPERATIONS)),?NUM_ARITHMETIC_OPERATIONS),
	io_lib:format("~s",[" _ -> "]) ++
	arithmetic_Operation(Vars,random:uniform(3)) ++
	io_lib:format("~s~s",[OP," foo(tl(List)) \n end "]);
cases_in_detail(N,Vars) -> 
	OP = lists:nth(random:uniform(length(?NUM_ARITHMETIC_OPERATIONS)),?NUM_ARITHMETIC_OPERATIONS),
	io_lib:format("~p~s",[N,"-> "]) ++
	arithmetic_Operation(Vars,random:uniform(3)) ++

	io_lib:format("~s~s",[OP," (foo(tl(List)) "]) ++
	list_Comprehension() ++
	io_lib:format("~s",[");\n"]) ++
	cases_in_detail(N-1,Vars).

parse_Argument(Arg) -> case is_list(Arg) of 
	false -> io_lib:format("~p",[Arg]);
	_ -> io_lib:format("~s",[Arg])
end.


generate_Comparisons(Vars,0) -> 
	[Arg1,Arg2] = [arithmetic_Operation(Vars,2),arithmetic_Operation(Vars,2)],
	COMP = lists:nth(random:uniform(length(?ALL_COMP_OPS)),?ALL_COMP_OPS),
	io_lib:format("~s",[" ("]) ++
	Arg1 ++
	COMP ++
	Arg2 ++
	io_lib:format("~s",[") "]);

generate_Comparisons(Vars,Iteration) ->
	[Arg1,Arg2] = [arithmetic_Operation(Vars,2),arithmetic_Operation(Vars,2)],
	COMP = lists:nth(random:uniform(length(?ALL_COMP_OPS)),?ALL_COMP_OPS),
	BOOL = lists:nth(random:uniform(length(?BOOL_OPS)),?BOOL_OPS),
	io_lib:format("~s",[" ("]) ++
	Arg1 ++
	COMP ++
	Arg2 ++
	io_lib:format("~s",[") "]) ++
	BOOL ++
	generate_Comparisons(Vars,Iteration-1).


list_Comprehension() -> 
	S = lists:nth(random:uniform(2),[" ++ ", " -- "]),
	io_lib:format("~s~s",[S," [ "]) ++
	arithmetic_Operation(["X"],random:uniform(3)) ++
	io_lib:format("~s",[" || X <- List, "]) ++
	generate_Comparisons(["X"],0) ++
	io_lib:format("~s",["] "])
	.


num() ->
	case random:uniform(10) of
	1 -> random:uniform(50);
	2 -> random:uniform(100);
	3 -> random:uniform(500);
	4 -> random:uniform();
	5 -> random:uniform(10) + random:uniform();
	6 -> random:uniform(100) + random:uniform();
	7 -> random:uniform(100000) + random:uniform();
	_ -> random:uniform(500) + random:uniform()
	end.
