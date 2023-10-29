graph(solution) :- not recommendation.
attr(graph,solution,center,true) :- not recommendation.

attr(graph,solution,splines,polyline) :- not recommendation.
% attr(graph,solution,rankdir,"TB").
% attr(graph,solution,nodesep,"0.02").
% attr(graph,solution,ranksep,"0.02").



%%%%%%%%%%%%%%%%%%
%%% Objects
%%%%%%%%%%%%%%%%%%

% attr(graph,model,fontsize,20).
attr(graph,solution,style,invis) :- not recommendation.
% attr(graph_nodes,model,penwidth,"1.5").
attr(graph_edges,solution,style,solid) :- not recommendation.
% attr(graph_edges,model,penwidth,"1.5").

% Give selecteds global index
% maybe also use this in ui.lp

selected(O,T,I) :- _c(selected(O,T)), I = #count{ O': _c(selected(O',T)), O'<O }, not recommendation.

% Generate nodes
node(O,solution)                    :- _c(selected(O,T)), not recommendation.

attr(node,O,label,@concat(
                        "{% set attr = attr|default({}) %}",
                        "<<TABLE BORDER='0' CELLBORDER='1' CELLSPACING='0' CELLPADDING='1'>",
                        "<TR><TD ><B>{{name}}{{index}} </B></TD></TR>",
                        % "<TR><TD ALIGN='left'> {% for key,a in attr|dictsort %} {{a}} {% if not loop.last %} <br ALIGN='left' />  {% endif %} {% endfor %} </TD></TR>",
                        "<TR><TD ALIGN='left'> {% for key,a in attr|dictsort %} {{a}} {% endfor %} </TD></TR>",
                        "</TABLE>>"))   :- _c(selected(O,T)), not recommendation.

attr(node,O,(label,name),T)             :- _c(selected(O,T)), not recommendation.
attr(node,O,(label,index),I)            :- selected(O,T,I), not recommendation.
attr(node,O,(label,attr,D),@format("{0} = {1} <br ALIGN='left' />",D,V)) :- _c(val((O,D),V)), not recommendation.

attr(node,O,shape,rectangle)            :- _c(selected(O,T)), not recommendation.
attr(node,O,style,"filled")             :- _c(selected(O,T)), not recommendation.
attr(node,O,fillcolor,"#F0ED94")        :- _c(selected(O,T)), not recommendation, not _clinguin_browsing.
attr(node,O,fillcolor,"#859F7A")        :- _c(selected(O,T)), not recommendation, _clinguin_browsing.
attr(node,O,color,"black")              :- _c(selected(O,T)), not recommendation.
attr(node,O,margin,0)                   :- _c(selected(O,T)), not recommendation.
attr(node,O,width,0)                    :- _c(selected(O,T)), not recommendation.
attr(node,O,height,0)                   :- _c(selected(O,T)), not recommendation.

%%%%%%%%%%%%%%%%%%%
%%% Associations
%%%%%%%%%%%%%%%%%%
association((O1,O2))     :- _c(selected(O2,T)), O2 = (_,(O1,_)), not recommendation.
edge(A,solution)    :- association(A), not recommendation.

attr(edge,A,label,D)     :- association(A), A = (_,(D,_)), not recommendation.
attr(edge,A,fontsize,11) :- association(A), not recommendation.














graph(recommendation) :- recommendation.
attr(graph,recommendation,center,true) :- recommendation.

attr(graph,recommendation,splines,polyline) :- recommendation.
% attr(graph,recommendation,rankdir,"TB").
% attr(graph,recommendation,nodesep,"0.02").
% attr(graph,recommendation,ranksep,"0.02").



%%%%%%%%%%%%%%%%%%
%%% Objects
%%%%%%%%%%%%%%%%%%


% attr(graph,model,fontsize,20) :- recommendation.
attr(graph,recommendation,style,invis) :- recommendation.
% attr(graph_nodes,model,penwidth,"1.5") :- recommendation.
attr(graph_edges,recommendation,style,solid) :- recommendation.
% attr(graph_edges,model,penwidth,"1.5") :- recommendation.

% Give selecteds global index
% maybe also use this in ui.lp

selected(O,T,I) :- selected(O,T), I = #count{ O': selected(O',T), O'<O } , recommendation.

% Generate nodes
node(O,recommendation)                    :- selected(O,T) , recommendation.

attr(node,O,label,@concat(
                        "{% set attr = attr|default({}) %}",
                        "<<TABLE BORDER='0' CELLBORDER='1' CELLSPACING='0' CELLPADDING='1'>",
                        "<TR><TD ><B>{{name}}{{index}} </B></TD></TR>",
                        % "<TR><TD ALIGN='left'> {% for key,a in attr|dictsort %} {{a}} {% if not loop.last %} <br ALIGN='left' />  {% endif %} {% endfor %} </TD></TR>",
                        "<TR><TD ALIGN='left'> {% for key,a in attr|dictsort %} {{a}} {% endfor %} </TD></TR>",
                        "</TABLE>>"))   :- selected(O,T) , recommendation.

attr(node,O,(label,name),T)             :- selected(O,T) , recommendation.
attr(node,O,(label,index),I)            :- selected(O,T,I) , recommendation.
attr(node,O,(label,attr,D),@format("{0} = {1} <br ALIGN='left' />",D,V)) :- val((O,D),V) , recommendation.

attr(node,O,shape,rectangle)            :- selected(O,T) , recommendation.
attr(node,O,style,"filled")             :- selected(O,T) , recommendation.
attr(node,O,fillcolor,"#F0ED94")        :- selected(O,T) , recommendation, not _clinguin_browsing.
attr(node,O,fillcolor,"#5DB182")        :- selected(O,T) , recommendation, _clinguin_browsing.
attr(node,O,color,"black")              :- selected(O,T) , recommendation.
attr(node,O,margin,0)                   :- selected(O,T) , recommendation.
attr(node,O,width,0)                    :- selected(O,T) , recommendation.
attr(node,O,height,0)                   :- selected(O,T) , recommendation.

%%%%%%%%%%%%%%%%%%%
%%% Associations
%%%%%%%%%%%%%%%%%%
association((O1,O2))     :- selected(O2,T), O2 = (_,(O1,_)),  recommendation.
edge(A,recommendation)    :- association(A), recommendation.

attr(edge,A,label,D)     :- association(A), A = (_,(D,_)), recommendation.
attr(edge,A,fontsize,11) :- association(A), recommendation.



#defined type/1.
#defined part/3.
#defined multiplicity/4.
#defined attr/2.
#defined attr/3.
#defined selected/2.
#defined association/2.
#defined recommendation/0.












