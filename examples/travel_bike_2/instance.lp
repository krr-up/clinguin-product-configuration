% Types:
type(travelBike).
type(wheel).
type(carrier).
type(bag).

% Parts:
part(travelBike,wheel,wheels).
multiplicity(travelBike,wheel,wheels,2).
part(travelBike,carrier,carrier).
multiplicity(travelBike,carrier,carrier,1).
part(wheel,bag,bags).
multiplicity(wheel,bag,bags,(0;2)).
part(carrier,bag,bags).
multiplicity(carrier,bag,bags,(0..3)).

% Attributes:
attr(bag,volume,"discrete").
dom(bag,volume,(10;20;50;100)).
attr(bag,weight,"discrete").
dom(bag,weight,(100;250;600;1200)).
attr(bag,material,"discrete").
dom(bag,material,("Cotton";"Leather";"Polyester")).
attr(wheel,size,"discrete").
dom(wheel,size,(14;16;18;20)).

% Aggregate Attributes:
attr(travelBike,totalWeight,"sum").
path(travelBike,totalWeight,(weight,(bags,(wheels,())))).
path(travelBike,totalWeight,(weight,(bags,(carrier,())))).

attr(travelBike,totalBags,"count").
path(travelBike,totalBags,(bags,(wheels,()))).
path(travelBike,totalBags,(bags,(carrier,()))).

% Constraints:
constraint((travelBike,0),"lte").
    left((travelBike,0),(totalBags,())).
    right((travelBike,0),constant(4)).

constraint((bag,0),"table").
    column((bag,0),0,(volume,())). column((bag,0),1,(weight,())).
    entry((bag,0),(0,0),10).       entry((bag,0),(1,0),100).
    entry((bag,0),(0,1),20).       entry((bag,0),(1,1),250).
    entry((bag,0),(0,2),50).       entry((bag,0),(1,2),600).
    entry((bag,0),(0,3),100).      entry((bag,0),(1,3),1200).

constraint((travelBike,1),"allsame").
    path((travelBike,1),(size,(wheels,()))).

