-module(script).
-export([start/2,prop_correct_list/1,partitions/2,sort/1,prop_right_times/1]).

-include_lib("proper/include/proper.hrl").

-spec sort([L]) -> [L].
sort([]) -> [];
sort([H|T]) -> sort([ X || X <- T, X =< H]) ++ [H] ++ sort([ X || X <- T, X > H]).

start(SEED,[Num1,Num2,Num3,Num4]) ->
	execute_command(SEED),
	Seed_String = integer_to_list(SEED),
	% {_,Program0}=code:load_file(list_to_atom("randprog_"++Seed_String++"_o0")),
	{_,Program1}=code:load_file(list_to_atom("randprog_"++Seed_String++"_o1")), 
	{_,Program2}=code:load_file(list_to_atom("randprog_"++Seed_String++"_o2")), 
	{_,Program3}=code:load_file(list_to_atom("randprog_"++Seed_String++"_o3")), 
	{_,Program4}=code:load_file(list_to_atom("randprog_"++Seed_String++"_beam")), 
	% Start = time(),
	% R0 = Program0:main(Num1,Num2,Num3,Num4),
	T0 = time(),
	R1 = Program1:main(Num1,Num2,Num3,Num4),
	T1 = time(),
	R2 = Program2:main(Num1,Num2,Num3,Num4),
	T2 = time(),
	R3 = Program3:main(Num1,Num2,Num3,Num4),
	T3 = time(),
	R4 = Program4:main(Num1,Num2,Num3,Num4),
	T4 = time(),
	% code:purge(Program0),
	code:purge(Program1),
	code:purge(Program2),
	code:purge(Program3),
	code:purge(Program4),
	os:cmd("rm randprog*"),
	[
	% timer:now_diff(T0,Start),
	timer:now_diff(T1,T0),
	timer:now_diff(T2,T1),timer:now_diff(T3,T2),timer:now_diff(T4,T3)]
	++ [R1,R2,R3,R4] .

	

partitions([],_) -> [];
partitions(L,N) -> 
	{L2,L3}=lists:split(N,L),
	[L2] ++ partitions(L3,N). 


right_times([T1,T2,T3|_]) -> sort([T1,T2,T3]) == [T1,T2,T3].

correct_list([_,_,_,_|L]) -> 
	[L1,L2,L3,_] = partitions(L,1),
	((L1==L2) and (L2==L3)).

execute_command(SEED) ->
	Seed_String=integer_to_list(SEED),
	os:cmd("./generator.sh "++ Seed_String).

prop_correct_list(SEED) -> 
	?FORALL(L,vector(4,number()), correct_list(start(SEED,L))).

prop_right_times(SEED) ->
	?FORALL(L,vector(4,number()), right_times(start(SEED,L))).

