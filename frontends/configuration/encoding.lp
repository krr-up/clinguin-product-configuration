% Partonomy has to be acyclic and rooted
partonomic_path(X,Y) :- part(X,Y,_).
partonomic_path(X,Z) :- partonomic_path(X,Y), partonomic_path(Y,Z).
:- partonomic_path(X,X).

root(T) :- type(T), not partonomic_path(_,T).
:- {root(T)} > 1.

% Generate maximal object tree
object((),T) :- root(T).
object((D,(O,0..Max-1)),T) :- object(O,S), part(S,T,D), Max = #max { N : multiplicity(S,T,D,N)}.
% why is this not the same:
%object((D,(O,N-1)),T) :- object(O,S), part(S,T,D), multiplicity(S,T,D,N).
object(O) :- object(O,T).

% Select subtree (root has to be selected)
selected((),T) :- root(T).
{ selected(O,T) : object(O,T) }.
selected(O) :- selected(O,_).

% You can only select an object if its "parent object" is selected as well
:- selected(O1), O1 = (_,(O2,_)), not selected(O2).

% Select such that indices are in ascending order
:- selected((D,(O,I))), not selected((D,(O,I-1))), I > 0.

% Select at least minimal number of required objects
selected((D,(O,0..Min-1)),T) :- selected(O,S), part(S,T,D), Min = #min { N : multiplicity(S,T,D,N)}.

% Check part multiplicities
:- part(S,T,D), not multiplicity(S,T,D,X), selected(O,S), X = #count { I : selected((D,(O,I)),T) }.

% the following do nothing, i believe:
% Create all possible connection ports and select
association(O1,O2,D,"connection") :- connection(S,T,D), object(O1,S), object(O2,T).
{ connected(O1,O2,D) : association(O1,O2,D,"connection") }.

:- connected(O1,O2,_), not selected(O1).
:- connected(O1,O2,_), not selected(O2).

% :- connected(O,O,_). % Should this be allowed or not?

% Check connection multiplicities
:- connection(S,T,D), not multiplicity(S,T,D,X),
   selected(O1,S), X = #count { O2 : connected(O1,O2,D) }.
% until here

% Assign values to attribute variables
{ val((O,D),V) : dom(T,D,V) } = 1 :- selected(O,T), attr(T,D,"discrete").
% Exactly one value has to be assigned for an attribute variable (Can be done in the actual assignment, i guess)
%:- attr(T,D,"discrete"), selected(O,T), not val((O,D),_).
%:- val(X,V1), val(X,V2), V1 < V2.

%%% Selectors
% this also does nothing, i believe:
% Determine longest path in constraints and aggregates
len_path(P,P,0) :- path(_,_,P).
len_path(P,P,0) :- column(_,_,P).
len_path(P,P,0) :- right(_,P).
len_path(P,P,0) :- left(_,P).

len_path(P,P',N+1) :- len_path(P,(D,P'),N).
len_path(P,N) :- len_path(P,(),N).
longest_path(X) :- X = #max { N : len_path(P,N) }.
% until here

% An object selector (O,P,O') selects
%   all objects O' which lie on
%   path P relative to object O
% Selectors are created only for the longest path length needed
selector(O,0,(),O) :- object(O).
selector(O,N+1,(D,P),(D,(O',I))):- selector(O,N,P,O'), object((D,(O',I))). % Partonomic paths
% this is also not needed:
% selector(O,N+1,(D,P),O'') :- selector(O,N,P,O'), connected(O',O'',D), longest_path(X), N < X.    % Connection paths

selector(O,P,O') :- selector(O,_,P,O').

% An attribute selector (O,P,X) selects
%   all attribute variables X which lie on
%   path P relative to object O
selector(O,(D,P),(O',D)) :- selector(O,P,O'), object(O',T), attr(T,D,_).

%%% Aggregates
% Count
val((O,D),V) :- selected(O,T), attr(T,D,"count"), V = #count { O' : path(T,D,P), selector(O,P,O'), selected(O');
                                                               V' : path(T,D,P), selector(O,P,X), val(X,V') }.
% Sum
val((O,D),V) :- selected(O,T), attr(T,D,"sum"), V = #sum { V',X : path(T,D,P), val(X,V'), selector(O,P,X) }.
% Min
val((O,D),V) :- selected(O,T), attr(T,D,"min"), V = #min { V',X : path(T,D,P), val(X,V'), selector(O,P,X) }.
% Max
val((O,D),V) :- selected(O,T), attr(T,D,"max"), V = #max { V',X : path(T,D,P), val(X,V'), selector(O,P,X) }.

%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Constraints
%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Table constraints
path_expansion((O,C),Col,(X,())) :- column((T,C),Col,P), selector(O,P,X), X=(O',_), not column((T,C),Col+1,_),
                                    selected(O,T), selected(O').
path_expansion((O,C),Col,(X',X)) :- path_expansion((O,C),Col+1,X), column((T,C),Col,P), Col>=0, selector(O,P,X'), X' = (O',_),
                                    selected(O,T), selected(O').
path_expansion((O,C),GP)         :- path_expansion((O,C),0,GP).

in_path((X,GP'),GP',X) :- path_expansion(_,(X,GP')).
in_path(GP,GP',X)      :- in_path(GP,(X,GP'),_).
in_path(GP,X)          :- in_path(GP,_,X).

hit_cell((O,C),GP,(Col,Row)) :- entry((T,C),(Col,Row),V), column((T,C),Col,P), selector(O,P,X), X = (O',_),
                                selected(O,T), selected(O'), val(X,V),
                                path_expansion((O,C),GP), in_path(GP,X).
hit_row((O,C),GP,Row) :- entry((T,C),(_,Row),_), 0 = #sum{ 1,Col: entry((T,C),(Col,Row),_); -1,Col': hit_cell((O,C),GP,(Col',Row)) },
                         selected(O,T), path_expansion((O,C),GP).

:- constraint((T,C),"table"), selected(O,T), path_expansion((O,C),GP), not hit_row((O,C),GP,_).

%%% Comparison constraints
left_compare((O,C),Op,(O',D))  :- constraint((T,C),Op), left((T,C),P), selector(O,P,(O',D)), selected(O,T), selected(O').
right_compare((O,C),Op,(O',D)) :- constraint((T,C),Op), right((T,C),P),selector(O,P,(O',D)), selected(O,T), selected(O').

left_compare((O,C),Op,P)  :- constraint((T,C),Op), left((T,C),P), P = constant(N), selected(O,T).
right_compare((O,C),Op,P) :- constraint((T,C),Op), right((T,C),P),P = constant(N), selected(O,T).

% Auxiliary val atoms for comparison with constants
val(P,N) :- left_compare(_,_,P), P=constant(N).
val(P,N) :- right_compare(_,_,P), P=constant(N).

sat_pair(C,X1,X2) :- left_compare(C,"eq",X1), right_compare(C,"eq",X2), val(X1,V1), val(X2,V2), V1 = V2.
sat_pair(C,X1,X2) :- left_compare(C,"neq",X1), right_compare(C,"neq",X2), val(X1,V1), val(X2,V2), V1 != V2.
sat_pair(C,X1,X2) :- left_compare(C,"lt",X1), right_compare(C,"lt",X2), val(X1,V1), val(X2,V2), V1 < V2.
sat_pair(C,X1,X2) :- left_compare(C,"lte",X1), right_compare(C,"lte",X2), val(X1,V1), val(X2,V2), V1 <= V2.
sat_pair(C,X1,X2) :- left_compare(C,"gt",X1), right_compare(C,"gt",X2), val(X1,V1), val(X2,V2), V1 > V2.
sat_pair(C,X1,X2) :- left_compare(C,"gte",X1), right_compare(C,"gte",X2), val(X1,V1), val(X2,V2), V1 >= V2.

% A comparison constraint is not satisfied if some pair of attribute variables does not satisfy it
:- left_compare(C,Op,X1), right_compare(C,Op,X2), not sat_pair(C,X1,X2).

%%% consistency constraint
alldiff((O,C),X) :- constraint((T,C),"alldiff"), path((T,C),P), selector(O,P,X),
                    selected(O,T), selected(O'), X=(O',_).
% An all different constraint is not satisfied if two different attribute valuation have the same value assigned
:- alldiff(C,X1), alldiff(C,X2), val(X1,V), val(X2,V), X1 < X2.

%%% All same constraint
allsame((O,C),X) :- constraint((T,C),"allsame"), path((T,C),P), selector(O,P,X),
                    selected(O,T), selected(O'), X=(O',_).
% An all same constraint is not satisfied if two different attribute valuation have different value assigned
:- allsame(C,X1), allsame(C,X2), val(X1,V1), val(X2,V2), X1 < X2, V1 != V2.


% some helpers for the ui.lp to work
count(O,D,X) :- object(O,S), part(S,T,D), X = #count { I : val(((D,(O,I)),_),_)}, K = #count{J: multiplicity(S,T,D,J)}, K>1.
:- part(S,T,D), object(O,S), count(O,D,X), not multiplicity(S,T,D,X).


% Define statements
#defined type/1.
#defined part/3.
#defined multiplicity/4.
#defined connection/3.
#defined connected/2.
#defined connected/3.
#defined attr/2.
#defined attr/3.
#defined dom/3.
#defined path/3.
#defined constraint/2.
#defined column/3.
#defined entry/3.
#defined left/2.
#defined right/2.


