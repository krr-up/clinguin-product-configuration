type(closet).
type(rectpart).
type(board).
type(drawer).
type(door).


part(closet, rectpart, rectpart).
multiplicity(closet, rectpart, rectpart, 1).
multiplicity(closet, rectpart, rectpart, 2).
multiplicity(closet, rectpart, rectpart, 3).
multiplicity(closet, rectpart, rectpart, 4).

part(rectpart, drawer, drawer).
multiplicity(rectpart, drawer, drawer, 0).
multiplicity(rectpart, drawer, drawer, 1).
multiplicity(rectpart, drawer, drawer, 2).
multiplicity(rectpart, drawer, drawer, 3).

part(rectpart, board, board).
multiplicity(rectpart, board, board, 0).
multiplicity(rectpart, board, board, 1).
multiplicity(rectpart, board, board, 2).
multiplicity(rectpart, board, board, 3).
multiplicity(rectpart, board, board, 4).
multiplicity(rectpart, board, board, 5).
multiplicity(rectpart, board, board, 6).
multiplicity(rectpart, board, board, 7).

part(rectpart, door, door).
multiplicity(rectpart, door, door, 0).
multiplicity(rectpart, door, door, 1).



%%%Attributes
attr(closet,type,"discrete").
dom(closet,type,(retro)).
dom(closet,type,(modern)).

attr(rectpart,width,"discrete").
dom(rectpart,width,(40;50;60;70;80;90;100)).

attr(rectpart,height,"discrete").
dom(rectpart,height,(100;110;120;130;140;150;160;170;180)).

attr(board,y,"discrete").
dom(board,y,(10;20;30;40;50;60;70;80;90;100;110;120;130;140;150;160;170;180)).

attr(drawer,y,"discrete").
dom(drawer,y,(10;20;30;40;50;60;70;80;90;100;110;120;130;140;150;160;170;180)).

attr(drawer,height,"discrete").
dom(drawer,height,(10;12;14;16;18;20)).


attr(door,handlePos,"discrete").
dom(door,handlePos,(left)).
dom(door,handlePos,(right)).

attr(door,handleType,"discrete").
dom(door,handleType,(retro)).
dom(door,handleType,(modern)).


attr(closet,totalHeight,"max").
attr(closet,totalWidth,"sum").
attr(closet,nrdrawers,"count").
attr(closet,nrboards,"count").

%TODO:add the Price to the model.


% Aggregate paths
path(closet,totalHeight,(height,(rectpart,()))).
path(closet,totalWidth,(width,(rectpart,()))).
path(closet,nrdrawers,(drawer,(rectpart,()))).
path(closet,nrboards,(board,(rectpart,()))).


%Constraintes
constraint((closet,0),"allsame").
    path((closet,0),(height,(rectpart,()))).

constraint((rectpart,0),"alldiff").
    path((rectpart,0),(y,(drawer,()))).
    path((rectpart,0),(y,(board,()))).

