%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ||Author - Marc Khristian Partoriza  ||
%% ||Date   - February 16th 2014        ||
%% ||Class  - ICS 313 Programming Theory||
%% ||Professor David Chin & Amy Takeyesu||
%%   -----------------------------------
%%      This program is intended to simulate a form of the jealous
%%	husbands puzzle: travelling couples to another island with
%%	a boat that can only carry up to 2 people and a wife cannot
%%	be on an island with another husband, while her own is not
%%	present (Only 1-3 couples work)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Easy Access Methods
onecouple:-   travel([left, [h1,w1],[]]).
twocouple:-   travel([left, [h1,w1,h2,w2],[]]).
threecouple:- travel([left, [h1,w1,h2,w2,h3,w3],[]]).


%% couple(husband, wife)
%%
%%	Couples used to travel from island to island
couple(h1,w1).
couple(h2,w2).
couple(h3,w3).


%% travel(STARTING_STATE).
%%
%%	Solves the jealous husband puzzle in the shortest way while
%%	printing the paths and the # of crossings. Uses Iterative
%%	deepening DFS.
%%
%%	Start Clause
travel(StartingState):-
	from(X,1,1),
	travel(StartingState,[], 0, X).
%% travel(GOAL_STATE,
%%	  LIST_OF_PREVIOUS_STATES,
%%	  GOAL_NUMBER_OF_PATHS,
%%        MAX_DEPTH)
%%
%%	End Clause
travel([right, [], RightPersons],PastIterations, NumOfPaths, _):-
	add([right,[],RightPersons], PastIterations, NewPastIterations),
	reverse(NewPastIterations, SortedPastIterations),
	write('number of crossings:'),
	write(NumOfPaths), nl,
	writelist(SortedPastIterations).
%% travel(CURRENT_STATE,
%%	  LIST_OF_PREVIOUS_STATES,
%%        CURRENT_NUM_OF_PATHS,
%%        MAX_DEPTH)
%%
%%	Recursive Clause
travel(CurrentState,
       PastIterations,
       NumOfPaths,
       MaxDepth):-
	NumOfPaths < MaxDepth,
	move(CurrentState, NewState),
	not(setmember(NewState,PastIterations)),
	add(CurrentState, PastIterations, NewPastIterations),
	/* Deepening Iterative DFS debug/proof   */
	/* write(NewState), nl, write(MaxDepth), */
	NewNumOfPaths is NumOfPaths + 1,
	travel(NewState,  NewPastIterations, NewNumOfPaths, MaxDepth).


%% from(INCREMENTED_NUMBER,
%%      NUMBER_TO_INCREMENT,
%%      INCREMENTING_NUMBER)
%%
%%	Method to increment a variable with each pass.
%%
%%	Contains code from:
%%	http://www.csee.umbc.edu/courses/771/current/
%%	presentations/prolog%20search.pdf
from(X,X,_).
from(X,N,Inc):-
	N2 is N+Inc,
	from(X,N2,Inc).


%% writelist(LIST)
%%
%%	Method to print the elements in a list in an formatted fashion
writelist([]).
writelist([Element|RestList]):-
	write(Element), nl,
	writelist(RestList).


%% setmember(STATE, LIST_OF_STATES)
%%
%%	True if a certain state is within a list of states
%%	regardless of order
%%
%%	End Clause
setmember([Boat1, LeftPersons1, RightPersons1],
	  [[Boat2, LeftPersons2, RightPersons2] | _]):-
	equal(LeftPersons1, LeftPersons2),
	equal(RightPersons1, RightPersons2),
	Boat1 = Boat2.
%%
%%	Recursive Clause
setmember([Boat1, LeftPersons1, RightPersons1],[_| RestPersons]):-
	setmember([Boat1, LeftPersons1, RightPersons1], RestPersons).


%% isSubset(SUBSET, CONTAINS_SUBSET)
%%
%%      True if the variable is a subset of another
%%
%%	Contains code from: http://stackoverflow.com/questions/
%%      2710479/prolog-program-to-find-equality-of-two-lists-in
%%      -any-order
isSubset([],_).
isSubset([H|T],Y):-
    member(H,Y),
    select(H,Y,Z),
    isSubset(T,Z).


%% equal(ELEMENT(S)1, ELEMENT(S)2)
%%
%%	Uses isSubset to check if two lists are equal regardless of
%%	order.
%%
%%	Contains code from: http://stackoverflow.com/questions/
%%      2710479/prolog-program-to-find-equality-of-two-lists-in
%%      -any-order
equal(X,Y):-
    isSubset(X,Y),
    isSubset(Y,X).


%% add(ELEMENT,
%%     LIST,
%%     NEW LIST)
%%
%%     Adds an element to a list and returns a new list
add(X,L,[X|L]).


%%move( INPUT  STATE,
%%	OUTPUT STATE)
%%
%%	Moves 1-2 people from the left island to the right or
%%	vice versa

   /*Move two people from left to right*/
move([left, LeftPersons, RightPersons],
     [right, NewLeftPersons2, NewRightPersons]):-
	member(FirstPerson,  LeftPersons),
	rest(FirstPerson, LeftPersons, RestLeftPersons),
	member(SecondPerson, RestLeftPersons),
	delete(LeftPersons, FirstPerson, NewLeftPersons),
	delete(NewLeftPersons, SecondPerson, NewLeftPersons2),
	append([FirstPerson, SecondPerson], RightPersons, NewRightPersons),
	validstates([_, NewLeftPersons2, NewRightPersons]).

   /*Move one person from left to right*/
move([left, LeftPersons, RightPersons] ,
     [right, NewLeftPersons, [LeftPerson|RightPersons]]):-
	member(LeftPerson, LeftPersons),
	delete(LeftPersons, LeftPerson, NewLeftPersons),
	validstates([_,NewLeftPersons, [LeftPerson|RightPersons]]).

   /*Move one person from right to left*/
move([right, LeftPersons, RightPersons],
     [left, [RightPerson|LeftPersons], NewRightPersons]):-
	member(RightPerson, RightPersons),
	delete(RightPersons, RightPerson, NewRightPersons),
	validstates([_,[RightPerson|LeftPersons], NewRightPersons]).

   /*Move two people from right to left*/
move([right, LeftPersons, RightPersons],
     [left, NewLeftPersons, NewRightPersons2]):-
	member(FirstPerson, RightPersons),
	rest(FirstPerson, RightPersons, RestRightPersons),
	member(SecondPerson, RestRightPersons),
	delete(RightPersons, FirstPerson, NewRightPersons),
	delete(NewRightPersons, SecondPerson, NewRightPersons2),
	append([FirstPerson, SecondPerson], LeftPersons, NewLeftPersons),
	validstates([_, NewLeftPersons, NewRightPersons2]).


%% rest( X,
%%	 LIST_OF_ELEMENTS,
%%	 LIST_OF_ELEMENTS_AFTER_X)
%%
%%	 Returns the elements in a list after a certain element.
rest(Element, [Element | RestOfList], RestOfList).
rest(Element, [_ | RestOfList], Result) :-
	rest(Element, RestOfList, Result).


%% validstates(STATE)
%%
%%	Checks to see if a state is valid according to the rules
%%	of the puzzle
%%
%%	Contains code from:http://colin.barker.pagesperso-orange
%%      .fr/sands.htm#Ex_18_1_iii
validstates([_, LeftPersons, RightPersons]):-
	validstate(LeftPersons),
	validstate(RightPersons).
	/*True if the island has only wives, or*/
validstate(Persons):- onlywives(Persons), !.
	/*All the wives on the island has their husband*/
validstate(Persons):- wiveswithhusbands(Persons, Persons).


%% onlywives( LIST_OF_PERSONS )
%%
%%	Returns true if everyone in LIST_OF_PERSONS is a wife
%%
%%	Contains code from:http://colin.barker.pagesperso-orange
%%      .fr/sands.htm#Ex_18_1_iii
onlywives([]).
onlywives([Wife|RestPersons]):-
	couple(_,Wife),
	onlywives(RestPersons).


%% wiveswithhusbands( LIST_OF_PERSONS_FOR_RECURSION,
%%		      LIST_OF_PERSONS_FOR_CHECKING)
%%
%%	Returns true if every wife in the list is with their husbands
%%
%%	Contains code from:http://colin.barker.pagesperso-orange
%%      .fr/sands.htm#Ex_18_1_iii
%%
%%	Ending Clause
wiveswithhusbands([], _).
%%	Husband Clause
wiveswithhusbands([Husband|RestPersons], Persons):-
	couple(Husband,_),
	wiveswithhusbands(RestPersons, Persons).
%%	Wife clause
wiveswithhusbands([Wife|RestPersons], Persons):-
	couple(Husband, Wife),
	member(Husband, Persons),
	wiveswithhusbands(RestPersons, Persons).














