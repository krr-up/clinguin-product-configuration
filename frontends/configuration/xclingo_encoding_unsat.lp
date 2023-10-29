%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Configuration model check
%%%%%%%%%%%%%%%%%%%%%%%%%
% Partonomy has to be acyclic and rooted
partonomic_path(X,Y) :- part(X,Y,J).
partonomic_path(X,Z) :- partonomic_path(X,Y), partonomic_path(Y,Z).
:- partonomic_path(X,X).

root(T) :- type(T), not partonomic_path(_,T).
:- {root(T)} > 1.

% Unique outgoing port descriptors for a type (this should also hold for cardinalities?)
% :- part(S,T1,D,_,_), part(S,T2,D,_,_), T1 < T2.

% Make attr/3 format uniform
attr(T,D,"atomic") :- attr(T,D).

% For a given type an attribute can only be declared once
:- attr(T,D,E), attr(T,D,E'), E < E'.

% Set of port and attribute descriptors has to be disjoint
descriptor("port",D) :- part(A,B,D).
descriptor("attribute",D) :- attr(A,D,B).
:- descriptor("port",D), descriptor("attribute",D).

% Number of columns/paths and their for a constraint
max_row_index(C,N) :- constraint(C,"table"), N = #max{ R: entry(C,(I,R),J)}.
max_column_index(C,N) :- constraint(C,"table"), N = #max{ Col : column(C,Col,J)}.

% Constraints are defined uniquely

% Table constraints are well-defined (indices of columns and rows start at 0 and increase by 1)

%%%%%%%%%%%%%%%%%%%%%%%%%
%%% User requirements check
%%%%%%%%%%%%%%%%%%%%%%%%%
% TODO: How can users specify objects and how can the correctness be checked?
% :- type(T), object(O), not objecttype(O,T).

% Given attribute values have to lie inside range (TODO: Distinguish between user given)
:- val((O,D),V), attr(T,D), object(O,T), not dom(T,D,V).

% Check that all objects have values assigned (totality)?

%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Instantiation
%%%%%%%%%%%%%%%%%%%%%%%%%

% There needs to be always a root object
object(()).
object((),T) :- object(()), root(T).

% Object generation
minmax(S,T,D,Min,Max) :- part(S,T,D),
                            Min = #min { N : multiplicity(S,T,D,N)},
                            Max = #max { N : multiplicity(S,T,D,N)}.

object((D,(P,0..Min-1)),T) :- object(P,S), part(S,T,D), minmax(S,T,D,Min,V).

%{ object((D,(P,I)),T) : I = Min..Max-1 } :- object(P,S), part(S,T,D), minmax(S,T,D,Min,Max). %, Min < Max.
object(O,T) :- selected(O,T).
object(O) :- object(O,T).

% Use indices in ascending order
:- object((D,(P,I))), not object((D,(P,I-1))), I > 0.

% Check part and connection cardinalities
port(S,T,D,"partonomic") :- part(S,T,D).
% port(S,T,D,"connection") :- connection(S,T,D).

% Port multiplicities need to be satisfied for each object
count(O,D,X) :- object(O,S), part(S,T,D), X = #count { I : object((D,(O,I)),T) }.
:- part(S,T,D), object(O,S), count(O,D,X), not multiplicity(S,T,D,X).

% Assign values to attribute variables
{ val((O,D),V) : dom(T,D,V) } :- object(O,T), attr(T,D,"atomic").

% Exactly one value has to be assigned for an attribute variable
:- attr(T,D,"atomic"), object(O,T), not val((O,D),_).
:- val(X,V1), val(X,V2), V1 < V2.

%%% Selectors
% An object selector (O,P,O') selects
%   all objects O' which lie on
%   path P relative to object O
selector(O,(),O) :- object(O).
selector(O,(D,P),(D,(O',I))):- selector(O,P,O'), object((D,(O',I))).

% An attribute selector (O,P,X) selects
%   all attribute variables X whie lie on
%   path P relative to object O
selector(O,(D,P),(O',D)) :- selector(O,P,O'), object(O',T), attr(T,D,V).

%%% Aggregates
% Count
val((O,D),V) :- object(O,T), attr(T,D,"count"), V = #count { O',P : path(T,D,P), selector(O,P,O') }.
% Sum
val((O,D),V) :- object(O,T), attr(T,D,"sum"), V = #sum { V',X,P : path(T,D,P), val(X,V'), selector(O,P,X) }.
% Min
val((O,D),V) :- object(O,T), attr(T,D,"min"), V = #min { V',X,P : path(T,D,P), val(X,V'), selector(O,P,X) }.
% Max
val((O,D),V) :- object(O,T), attr(T,D,"max"), V = #max { V',X,P : path(T,D,P), val(X,V'), selector(O,P,X) }.

%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Constraints
%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Table constraints

% Generate cross product tuples for each object and corresponding constraint
var_tuple((O,C),N,((),X)) :- object(O,T), max_column_index((T,C),N), selector(O,P,X), column((T,C),N,P).
var_tuple((O,C),N,(VT,X)) :- object(O,T), var_tuple((O,C),N+1,VT), selector(O,P,X), column((T,C),N,P), N>=0.

% For each tuple check that it satisfies some row
% by unpacking the nested tuples and checking the columns from left to right
sat_row((O,C),VT,(0,Row),VT') :- object(O,T), var_tuple((O,C),0,VT), VT = (VT',X), val(X,V), entry((T,C),(0,Row),V).
sat_row((O,C),VT,(Col,Row),VT'') :- object(O,T), sat_row((O,C),VT,(Col-1,Row),VT'), VT' = (VT'',X), val(X,V), entry((T,C),(Col,Row),V).

% A table constraint is not satisfied if some tuple does not satisfy all values in a row
unsat(C) :- var_tuple(C,0,VT), not sat_row(C,VT,_,()).

%%% Comparison constraints
left_compare((O,C),Op,X) :- object(O,T), constraint((T,C),Op), left((T,C),P), selector(O,P,X).
right_compare((O,C),Op,X) :- object(O,T), constraint((T,C),Op), right((T,C),P), selector(O,P,X).

left_compare((O,C),Op,P) :- object(O,T), constraint((T,C),Op), left((T,C),P), P = constant(N).
right_compare((O,C),Op,P) :- object(O,T), constraint((T,C),Op), right((T,C),P), P = constant(N).

% Auxiliary val atoms for comparison with constants
val(P,N) :- left_compare(A,B,P), P=constant(N).
val(P,N) :- right_compare(A,B,P), P=constant(N).

object(O,T,I) :- object(O,T), I = #count{ O': object(O',T), O'<O }.


sat_pair(C,X1,X2) :- left_compare(C,"eq",X1), right_compare(C,"eq",X2), val(X1,V1), val(X2,V2), V1 = V2.
sat_pair(C,X1,X2) :- left_compare(C,"neq",X1), right_compare(C,"neq",X2), val(X1,V1), val(X2,V2), V1 != V2.
sat_pair(C,X1,X2) :- left_compare(C,"lt",X1), right_compare(C,"lt",X2), val(X1,V1), val(X2,V2), V1 < V2.
sat_pair(C,X1,X2) :- left_compare(C,"lte",X1), right_compare(C,"lte",X2), val(X1,V1), val(X2,V2), V1 <= V2.
sat_pair(C,X1,X2) :- left_compare(C,"gt",X1), right_compare(C,"gt",X2), val(X1,V1), val(X2,V2), V1 > V2.
sat_pair(C,X1,X2) :- left_compare(C,"gte",X1), right_compare(C,"gte",X2), val(X1,V1), val(X2,V2), V1 >= V2.

unsat(C) :- left_compare(C,Op,X1), right_compare(C,Op,X2), not sat_pair(C,X1,X2), Op != "table".
% A comparison constraint is not satisfied if some pair of attribute variables does not satisfy it
% :- unsat(C).


%%% consistency constraint
alldiff((O,C),X) :- constraint((T,C),"alldiff"), path((T,C),P), selector(O,P,X),
                    object(O,T), object(O'), X=(O',_).
% An all different constraint is not satisfied if two different attribute valuation have the same value assigned
unsat(C) :- alldiff(C,X1), alldiff(C,X2), val(X1,V), val(X2,V), X1 < X2.

%%% All same constraint
allsame((O,C),X) :- constraint((T,C),"allsame"), path((T,C),P), selector(O,P,X),
                    object(O,T), object(O'), X=(O',_).
% An all same constraint is not satisfied if two different attribute valuation have different value assigned
unsat(C) :- allsame(C,X1), allsame(C,X2), val(X1,V1), val(X2,V2), X1 < X2, V1 != V2.


% Define statements
#defined type/1.
#defined part/3.
#defined multiplicity/4.
#defined connection/3.
#defined attr/2.
#defined attr/3.
#defined dom/3.
#defined path/3.
#defined constraint/2.
#defined column/3.
#defined entry/3.
#defined left/2.
#defined right/2.




%!trace {unsat((O,C)), "Constraint (%,%) cannot be satisfied", T,C} :- unsat((O,C)), object(O,T), constraint((T,C),Op).
%!trace {constraint((T,C),"allsame"), "the attributes % of all objects % have to be equal", A,O} :- constraint((T,C),"allsame"), path((T,C),(A,O)).
%!trace {constraint((T,C),"alldiff"), "the attributes % of all objects % have to be different", A,O} :- constraint((T,C),"alldiff"), path((T,C),(A,O)).




% comparing two object attributes:
%!trace {right_compare(C,"eq",(O1,A1)), "% of %% has to be the same as % of %%", A1,T1,I1,A2,T2,I2} :- right_compare(C,"eq",(O1,A1)), left_compare(C,"eq",(O2,A2)), object(O1,T1,I1), object(O2,T2,I2).
%!trace {right_compare(C,"neq",(O1,A1)), "% of %% has to be different from % of %%", A1,T1,I1,A2,T2,I2} :- right_compare(C,"neq",(O1,A1)), left_compare(C,"neq",(O2,A2)), object(O1,T1,I1), object(O2,T2,I2).
%!trace {right_compare(C,"lt",(O1,A1)), "% of %% has to be less than % of %%", A1,T1,I1,A2,T2,I2} :- right_compare(C,"lt",(O1,A1)), left_compare(C,"lt",(O2,A2)), object(O1,T1,I1), object(O2,T2,I2).
%!trace {right_compare(C,"gt",(O1,A1)), "% of %% has to be greater than % of %%", A1,T1,I1,A2,T2,I2} :- right_compare(C,"gt",(O1,A1)), left_compare(C,"gt",(O2,A2)), object(O1,T1,I1), object(O2,T2,I2).
%!trace {right_compare(C,"lte",(O1,A1)), "% of %% has to be less or equal to % of %%", A1,T1,I1,A2,T2,I2} :- right_compare(C,"lte",(O1,A1)), left_compare(C,"lte",(O2,A2)), object(O1,T1,I1), object(O2,T2,I2).
%!trace {right_compare(C,"gte",(O1,A1)), "% of %% has to be greater or equal to % of %%", A1,T1,I1,A2,T2,I2} :- right_compare(C,"gte",(O1,A1)), left_compare(C,"gte",(O2,A2)), object(O1,T1,I1), object(O2,T2,I2).

% comparing object with constant:
%!trace {left_compare(C,"eq",(O2,A2)), "% of %% has to be less or equal to %", A2,T2,I2,P} :- right_compare(C,"eq",constant(P)), left_compare(C,"eq",(O2,A2)), object(O2,T2,I2).
%!trace {left_compare(C,"neq",(O2,A2)), "% of %% has to be different from %", A2,T2,I2,P} :- right_compare(C,"neq",constant(P)), left_compare(C,"neq",(O2,A2)), object(O2,T2,I2).
%!trace {left_compare(C,"lt",(O2,A2)), "% of %% has to be less than %", A2,T2,I2,P} :- right_compare(C,"lt",constant(P)), left_compare(C,"lt",(O2,A2)), object(O2,T2,I2).
%!trace {left_compare(C,"gt",(O2,A2)), "% of %% has to be greater than %", A2,T2,I2,P} :- right_compare(C,"gt",constant(P)), left_compare(C,"gt",(O2,A2)), object(O2,T2,I2).
%!trace {left_compare(C,"lte",(O2,A2)), "% of %% has to be less or equal to %", A2,T2,I2,P} :- right_compare(C,"lte",constant(P)), left_compare(C,"lte",(O2,A2)), object(O2,T2,I2).
%!trace {left_compare(C,"gte",(O2,A2)), "% of %% has to be greater or equal to %", A2,T2,I2,P} :- right_compare(C,"gte",constant(P)), left_compare(C,"gte",(O2,A2)), object(O2,T2,I2).


%!trace {val((O,D),V), "Attribute % of %% has value % (assumed)", D,T,I,V} :- val((O,D),V), object(O,T,I), assumption(val((O,A),V)).
%!trace {val((O,D),V), "Attribute % of %% has value % (implied)", D,T,I,V} :- val((O,D),V), object(O,T,I), not assumption(val((O,D),V)).



%!trace {var_tuple((O,C),N,(K,X)), "If % of %% is %, the % of %% has to be %", A1, T, I, V1, A2, T, I, V2} :- var_tuple((O,C),N,(K,X)), not sat_row((O,C),(K,X),_,()), object(O,T,I), entry((T,C),(0,Row),V1), entry((T,C),(1,Row),V2), column((T,C),0,(A1,C1)), column((T,C),1,(A2,C2)), val(X,V1).
helper(T,I) :- var_tuple((O,C),N,(K,X)), not sat_row((O,C),(K,X),_,()), object(O,T,I), entry((T,C),(0,Row),V1), entry((T,C),(1,Row),V2), column((T,C),0,(A1,C1)), column((T,C),1,(A2,C2)), val(X,V1).

%!trace {left_compare(C,"eq",(O2,A2)),"% of %% is % (assumed)", A1,T1,I1,V1} :- right_compare(C,"eq",(O1,A1)), left_compare(C,"eq",(O2,A2)), object(O1,T1,I1), object(O2,T2,I2), val((O1,A1),V1), val((O2,A2),V2), V1 != V2, assumption(val((O1,A1),V1)).
%!trace {left_compare(C,"eq",(O2,A2)),"% of %% is % (implied)", A1,T1,I1,V1} :- right_compare(C,"eq",(O1,A1)), left_compare(C,"eq",(O2,A2)), object(O1,T1,I1), object(O2,T2,I2), val((O1,A1),V1), val((O2,A2),V2), V1 != V2, not assumption(val((O1,A1),V1)).
%!trace {left_compare(C,"eq",(O2,A2)), "% of %% is % (assumed)", A2,T2,I2,V2} :- right_compare(C,"eq",(O1,A1)), left_compare(C,"eq",(O2,A2)), object(O1,T1,I1), object(O2,T2,I2), val((O1,A1),V1), val((O2,A2),V2), V1 != V2, assumption(val((O2,A2),V2)).
%!trace {left_compare(C,"eq",(O2,A2)), "% of %% is % (implied)", A2,T2,I2,V2} :- right_compare(C,"eq",(O1,A1)), left_compare(C,"eq",(O2,A2)), object(O1,T1,I1), object(O2,T2,I2), val((O1,A1),V1), val((O2,A2),V2), V1 != V2, not assumption(val((O2,A2),V2)).

%!trace {column((T,C),0,(A1,C1)), "% of %% is % (assumed)", A1, T, I, V1} :- var_tuple((O,C),N,(K,X)), not sat_row((O,C),(K,X),_,()), object(O,T,I), entry((T,C),(0,Row),V1), entry((T,C),(1,Row),V2), column((T,C),0,(A1,C1)), column((T,C),1,(A2,C2)), val(X,V1), assumption(val(X,V1)).
%!trace {column((T,C),1,(A2,C2)), "% of %% is % (implied)", A2, T, I, V3} :- var_tuple((O,C),N,(K,X)), not sat_row((O,C),(K,X),_,()), object(O,T,I), entry((T,C),(0,Row),V1), entry((T,C),(1,Row),V2), column((T,C),0,(A1,C1)), column((T,C),1,(A2,C2)), val(X,V3), V3!=V1, V3!=V2, helper(T,I), not assumption(val(X,V3)).
%!trace {column((T,C),0,(A1,C1)), "% of %% is % (assumed)", A1, T, I, V1} :- var_tuple((O,C),N,(K,X)), not sat_row((O,C),(K,X),_,()), object(O,T,I), entry((T,C),(0,Row),V1), entry((T,C),(1,Row),V2), column((T,C),0,(A1,C1)), column((T,C),1,(A2,C2)), val(X,V1), assumption(val(X,V1)).
%!trace {column((T,C),1,(A2,C2)), "% of %% is % (implied)", A2, T, I, V3} :- var_tuple((O,C),N,(K,X)), not sat_row((O,C),(K,X),_,()), object(O,T,I), entry((T,C),(0,Row),V1), entry((T,C),(1,Row),V2), column((T,C),0,(A1,C1)), column((T,C),1,(A2,C2)), val(X,V3), V3!=V1, V3!=V2, helper(T,I), not assumption(val(X,V3)).

% for the constraints, with only one column
%!trace {var_tuple((O,C),N,(K,X)), "The % of %% can be %", A1, T, I, V1} :- var_tuple((O,C),N,(K,X)), not sat_row((O,C),(K,X),_,()), object(O,T,I), entry((T,C),(0,Row),V1), not entry((T,C),(1,Row),_), column((T,C),0,(A1,C1)).
%!trace {column((T,C),0,(A1,C1)), "% of %% is % (assumed)", A1, T, I, V2} :- var_tuple((O,C),N,(K,X)), not sat_row((O,C),(K,X),_,()), object(O,T,I), entry((T,C),(0,Row),V1), not entry((T,C),(1,Row),_), column((T,C),0,(A1,C1)), val(X,V2), assumption(val(X,V2)).


%!show_trace {unsat(C)} :- unsat(C).
