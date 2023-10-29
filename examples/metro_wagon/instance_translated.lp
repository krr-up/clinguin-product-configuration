
% Types
type(wagon).
type(handrail).
type(seat).


% Parts
part(wagon,handrail,handrail).
multiplicity(wagon,handrail,handrail,(0;1)).

part(wagon,seat,seat).
% Ui works for 10, breaks for 80, intersting
% actually, it moves down in the containter with the growing range, lol
multiplicity(wagon,seat,seat,(2..20)).


% Attributes
attr(handrail,htype,"discrete").
dom(handrail,htype,(standard;premium)).

attr(seat,stype,"discrete").
dom(seat,stype,(standard;premium;special)).

attr(seat,color,"discrete").
dom(seat,color,(blue;red;white)).

attr(wagon,length_mm,"discrete").
dom(wagon,length_mm,(10000;11000;12000;13000;14000;15000;16000;17000;18000;19000;20000)).

attr(wagon,standing_room,"discrete").
dom(wagon,standing_room,(0;10;20;30;40;50;60;70;80;90;100;110;120;130;140;150;160;170;180;190;200)).

attr(wagon,nr_seats,"count").
attr(wagon,nr_passengers,"sum").


% Aggregate paths

path(wagon,nr_seats,(seat,())).

path(wagon,nr_passengers,(nr_seats,())).
path(wagon,nr_passengers,(standing_room,())).



% i think we need to create new constraaints for the linear domains

{constraint((seat,0),"table")}.
    column((seat,0),0,(stype,())).   column((seat,0),1,(color,())).
    entry((seat,0),(0,0),special).              entry((seat,0),(1,0),red).
    entry((seat,0),(0,1),premium).              entry((seat,0),(1,1),blue).
    entry((seat,0),(0,2),premium).               entry((seat,0),(1,2),red).
    entry((seat,0),(0,3),premium).               entry((seat,0),(1,3),white).
    entry((seat,0),(0,4),standard).              entry((seat,0),(1,4),blue).
    entry((seat,0),(0,5),standard).               entry((seat,0),(1,5),red).
    entry((seat,0),(0,6),standard).               entry((seat,0),(1,6),white).

% nr_passengers cant be below 50.
{constraint((wagon,0),"gte")}.
    left((wagon,0),(nr_passengers,())).
    right((wagon,0),constant(50)).

% The following contraints are ridiculously slow, even for only two seats
% all seats need to have the equal stype
{constraint((wagon,1),"allsame")}.
    path((wagon,1),(stype,(seat,()))).


% all seats need to have the equal color
{constraint((wagon,2),"allsame")}.
    path((wagon,2),(color,(seat,()))).


% the number of seats + stading room/3 has to be less or equal to 4*length/1000
% not sure how/if we can do math in this instance declaration.
{constraint((wagon,3),"lte")}.
    left((wagon,3),(nr_seats,())).
    right((wagon,3),constant(50)).

% If there is standing room > 0 --> we need a handrail.
