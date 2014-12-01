:- use_module(library(clpfd)).

day(Shift,Day):-
	Day #= Shift/3.

shift(Shift,Time):-
	Time #= Shift mod 3.

% minimum of 11-hour break between any two working shifts
sparse_shifts([_]).
sparse_shifts([H1,H2|T]):-
	H1 #< H2-2,
	sparse_shifts([H2|T]).

% get shift days
get_days([],[]).
get_days([H|T],[D|R2]):-
	get_days(T,R2),
	day(H,D).

shifts([],[]).
shifts([H|T],[S|R2]):-
	shifts(T,R2),
	shift(H,S).

num_list(Low,High,[]):-
	Low #> High.

num_list(Low,High,[Low|R2]):-
	Low #=< High,
	Low2 #= Low +1,
	num_list(Low2,High,R2).

% get Holidays
rest_days(L,Holidays):-
	get_days(L,Days),
	Days2 = [-1|Days],
	rest_days2(Days2,Holidays).

rest_days2([_],[]).
rest_days2([H1,H2|T],L):-
	Hm #= H2 -1,
	num_list(H1,Hm,[H1|L2]),
	rest_days2([H2|T],L3),
	append(L2,L3,L).

one_rest_day([H|T],Max):-
	H #=< 5, last([H|T],X),
	X #>= Max - 6,
	one_day_off([H|T]).

one_day_off([_]).
one_day_off([H1,H2|T]):-
	H1 #>= H2-6, one_day_off([H2|T]).


two_days_off([_,_]).
two_days_off([_]).
two_days_off([H1,X,H2|T]):-
	H1 #=< H2-5, two_days_off([X,H2|T]).


count_oc([],_,0).
count_oc([X|T],X,Y):- count_oc(T,X,Z), Y #= 1+Z.
count_oc([X1|T],X,Z):- X1#\=X, count_oc(T,X,Z).

no_bridges([_]).
no_bridges([H1,H2|T]):-
	H1 #\= H2 - 2, no_bridges([H2|T]).

four_night_shifts(L):-
	shifts(L,Shifts),
	count_oc(Shifts,2,N),
	N #=< 4.



check_holidays(L):-
	rest_days(L,H),
	one_rest_day(H,14),
	two_days_off(H).

nurse_shifts(Shifts):-
	sparse_shifts(Shifts),
	rest_days(Shifts,H),
	two_days_off(H),
	no_bridges(H),
	one_rest_day(H,14),
	four_night_shifts(Shifts).

length_(X,L):- length(L,X).

count_(I,X,L):- nth1(I,L,Z), length(Z,N), N#>=X.

range(L):-  all_different(L).%,nurse_shifts(L).

check_count(Z,X):-
	Z #=< 1, X #>= 1.
check_count(2,X):-
	X #>= 1.

shifts_num(Vars,N,N):-
	Shift #= N mod 3,
	count_oc(Vars,N,Z), check_count(Shift,Z).

shifts_num(Vars,X,N):-
	X #< N,Shift #= X mod 3,
	count_oc(Vars,X,Z), check_count(Shift,Z),
	X2 #= X +1,
	shifts_num(Vars,X2,N).

shifts_num(_,0).
shifts_num(Vars,N):-
	N#>0, Shift #= N mod 3,
	count_oc(Vars,N,X), check_count(Shift,X),
	N2 #= N -1,
	shifts_num(Vars,N2).

generate_pairs(0,[0-1]).
generate_pairs(N,[N-_|L2]):-
	N >0,
	N2 is N -1,
	generate_pairs(N2,L2).


schedule(Nurses):-
	N = 2,
	length(Nurses,N),
	maplist(length_(10),Nurses),
	flatten(Nurses,Vars),
	%generate_pairs(41,L),
	%global_cardinality(Vars,L),
	Vars ins 0..20,
	all_different(Vars),
	%maplist(range,Nurses),
	shifts_num(Vars,0,18),
	label(Vars).%, label([N]).


%time((length(L, 11), all_different(L),
	%L ins 0..41, nurse_shifts(L), labeling([ff],L))).