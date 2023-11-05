
#script(python)
from clingo import String
def concat(*args):
    """
    Concatenates the given symbols as a string
    Args:
        args: All symbols
    Returns:
        (clingo.Symbol.String) The string concatenating all symbols
    """
    args = []
    return String(''.join([str(x).strip('"') for x in args]))

#end.


% most of them should be not used anymore:

#const width_value = 1120.
#const config_width_value = 500.
#const clingraph_width_value = 620.
#const space_size = 20.
#const header_rows = 2.

#const containerWidth = 300.
#const labelWidth = 200.
#const dropDownWidth = 90.
#const entryHeight = 25.
#const containerBorderWidth = 5.
#const subContainerBorderWidth = 1.
#const headerFontSize = 24.
#const recommendationFontSize = 20.
#const basicFontSize = 16.
#const explanationFontSize = 12.



% Menu Bar might have an option to toggle the product domain on an off

%---------------------------------------------------------------------------------------
% Bike Configuration Window
%---------------------------------------------------------------------------------------

elem(window, window, root).
% this orders the clingraphs randomly
attr(window, child_layout, flex).
attr(window, flex_direction, row).
% this disables the buttons somehow
%attr(window, child_layout, grid).
%attr(window, class, "pt-0").



% ---------
% Menu bar
% ---------
elem(menu_bar, menu_bar, window).
attr(menu_bar, title,  @concat("","Product Configuration: ",T,I)) :- root(T), selected(O,T,I).
attr(menu_bar, icon, "fa-home").

elem(menu_bar_clear, button, menu_bar).
attr(menu_bar_clear, label, "Clear").
attr(menu_bar_clear, icon, "fa-trash").
attr(menu_bar_clear, class, "btn-outline-danger").
attr(menu_bar_clear, class, "border-0").
when(menu_bar_clear, click, callback, clear_assumptions).


elem(menu_bar_download, button, menu_bar).
attr(menu_bar_download, label, "Download").
attr(menu_bar_download, icon, "fa-download").
when(menu_bar_download, click, call, download("#show selected/2. #show val/2.",exports)).



elem(menu_bar_toggle_domain, button, menu_bar).
attr(menu_bar_toggle_domain, label, "Show product domain") :- hide_domain.
attr(menu_bar_toggle_domain, label, "Hide product domain") :- not hide_domain.
attr(menu_bar_toggle_domain, icon, "fa-eye") :- hide_domain.
attr(menu_bar_toggle_domain, icon, "fa-eye-slash") :- not hide_domain.
when(menu_bar_toggle_domain, click, callback, add_atom(hide_domain)) :- not hide_domain.
when(menu_bar_toggle_domain, click, callback, remove_atom(hide_domain)) :- hide_domain.




elem(menu_bar_explain, button, menu_bar).
attr(menu_bar_explain, label, "Explain Aggregates").
attr(menu_bar_explain, icon, "fa-question").
% how can i get the explanation AND still show the modal?
when(menu_bar_explain, click, call, get_explanation_aggregates).
%when(menu_bar_explain, click, update, (explanation_modal, visible, shown)).


elem(explain_unsat_button, button, menu_bar) :- not explanation, _clinguin_unsat.
attr(explain_unsat_button, label, "Explain UNSAT").
attr(explain_unsat_button, class, "btn-outline-danger").
attr(explain_unsat_button, class, "border-0").
attr(explain_unsat_button, icon, "fa-question").
when(explain_unsat_button, click, call, get_explanation_unsat).
%when(explain_unsat_button, click, update, (explanation_modal, visible, shown)).




%---------------------------------------------------------------------------------------
% Left Large container
%---------------------------------------------------------------------------------------
% Left container (with configuration stuff)
elem(left_container, container, window).
attr(left_container, child_layout, grid).
attr(left_container, background_color, "#F6F1F1").
attr(left_container, class, "border").
attr(left_container, class, "border-3").
attr(left_container, class, "rounded").
attr(left_container, class, "border-primary").
attr(left_container, text-align, "left").
attr(left_container, class, "align-content-left").
attr(left_container, class, "justify-content-start").
attr(left_container, class, "text-start").

attr(left_container, grid_row, 0).
attr(left_container, grid_column, 0).










%---------------------------------------------------------------------------------------
% Middle Large container
%---------------------------------------------------------------------------------------
% middle_container container (with the solution clingraph)
elem(middle_container, container, window).
attr(middle_container, grid_row, 0).
attr(middle_container, grid_column, 1).
attr(middle_container, child_layout, flex).
attr(middle_container, class, "border-3").
attr(middle_container, class, "border").
attr(middle_container, class, "rounded").
attr(middle_container, class, "align-content-left").
attr(middle_container, class, "justify-content-start").


%---------------------------------------------------------------------------------------
% solution Clingraph
%---------------------------------------------------------------------------------------
elem(clingraph_solution, canvas, middle_container).
attr(clingraph_solution, image_type, clingraph__solution) :- not recommendation.
attr(clingraph_solution, image_type, clingraph__recommendation) :- recommendation.


elem(clingraph_solution_header, label, middle_container).
attr(clingraph_solution_header, label, "Current Solution") :- not recommendation.
attr(clingraph_solution_header, label, "Suggested Configuration") :- recommendation.
attr(clingraph_solution_header, class, "h3").
attr(clingraph_solution_header, height, 50).





%---------------------------------------------------------------------------------------
% Right Large container
%---------------------------------------------------------------------------------------
% right container (with the clingraph)
elem(right_container, container, window) :- not hide_domain.
attr(right_container, grid_row, 0).
attr(right_container, grid_column, 2).
attr(right_container, child_layout, flex).
attr(right_container, flex_direction, "column").
attr(right_container, class, "border-3").
attr(right_container, class, "border").
attr(right_container, class, "rounded").
attr(right_container, class, "align-content-left").
attr(right_container, class, "justify-content-start").




elem(clingraph_domain_header, label, right_container) :- not hide_domain.
attr(clingraph_domain_header, label, "Product Domain").
attr(clingraph_domain_header, class, "h3").
attr(clingraph_domain_header, height, 50).

%---------------------------------------------------------------------------------------
% product domain Clingraph
%---------------------------------------------------------------------------------------
elem(clingraph_domain, canvas, right_container) :- not hide_domain.
attr(clingraph_domain, image_type, clingraph).








selected(O,T,I) :- _c(selected(O,T)), I = #count{ O': _c(selected(O',T)), O'<O }.

%---------------------------------------------------------------------------------------
% Main Header
%---------------------------------------------------------------------------------------
elem(bike_header, label, left_container).
attr(bike_header, label, "Configuration Panel").
attr(bike_header, class, "h3").
attr(bike_header, grid_row, 0).
attr(bike_header, grid_column, 0).
attr(bike_header, grid_column_span, 4).






%---------------------------------------------------------------------------------------
%---------------------------------------------------------------------------------------
%---------------------------------------------------------------------------------------
% Attributes
%---------------------------------------------------------------------------------------
%---------------------------------------------------------------------------------------
%---------------------------------------------------------------------------------------



row_opts(O) :- _c(selected(O,S)), part(S,T,D), N = #count{ V: multiplicity(S,T,D,V)}, N != 1.
row_opts(O,N+1) :- row_opts(O), N=#count{ O': row_opts(O'), O'<O }.

sub_row_opts(O,D) :- row_opts(O), _c(selected(O,S)), part(S,T,D), N = #count{ V: multiplicity(S,T,D,V)}, N != 1.
sub_row_opts(O,D,N) :- sub_row_opts(O,D), N=#count{ D': sub_row_opts(O,D'), D'<D }.


%---------------------------------------------------------------------------------------
% Optional attribute container
%---------------------------------------------------------------------------------------
elem(optCon(O), container, left_container) :- row_opts(O,_).
attr(optCon(O), grid_row,  N + header_rows) :- row_opts(O,N).
attr(optCon(O), grid_column, 1) :- row_opts(O,_).
attr(optCon(O), grid_column_span, 3) :- row_opts(O,_).
attr(optCon(O), child_layout, grid) :- row_opts(O,_).
attr(optCon(O), class, "rounded") :- row_opts(O,_).
attr(optCon(O), class, "border-primary") :- row_opts(O,_).
attr(optCon(O), class, "border") :- row_opts(O,_).
attr(optCon(O), class, "m-1") :- row_opts(O,_).
attr(optCon(O), class, "p-1") :- row_opts(O,_).
attr(optCon(O), class, "bg-light") :- row_opts(O,_).




%---------------------------------------------------------------------------------------
% Optional attributes
%---------------------------------------------------------------------------------------
elem(optLabel(O), label, left_container) :- row_opts(O,_).
attr(optLabel(O), label, @concat("",T, I,": ")) :- row_opts(O,_), selected(O,T,I).
attr(optLabel(O), font_size, basicFontSize) :- row_opts(O,_).
attr(optLabel(O), grid_row, N + header_rows) :- row_opts(O,N).
attr(optLabel(O), grid_column, 0) :- row_opts(O,_).
attr(optLabel(O), background_color, "#F6F1F1") :- row_opts(O,_).
attr(optLabel(O), order, 2):-row_opts(O,_).
attr(optLabel(O), class, "m-2"):-row_opts(O,_).
attr(optLabel(O), class, "p-2"):-row_opts(O,_).

elem(header_opt(O,D), label, optCon(O)) :- sub_row_opts(O,D,_).
attr(header_opt(O,D), label, @concat("","#",D)) :- sub_row_opts(O,D,_).
attr(header_opt(O,D), grid_row, N) :- sub_row_opts(O,D,N).
attr(header_opt(O,D), grid_column, 0) :- sub_row_opts(O,D,_).
attr(header_opt(O,D), class, ("rounded";"border";"bg-danger")) :- sub_row_opts(O,D,_), _muc(count(O,D,_)).


elem(ddOpt(O,D), dropdown_menu, optCon(O)) :- sub_row_opts(O,D,_).
attr(ddOpt(O,D), grid_row, N) :- sub_row_opts(O,D,N).
attr(ddOpt(O,D), grid_column, 1) :- sub_row_opts(O,D,_).
attr(ddOpt(O,D), selected, V) :- sub_row_opts(O,D,_), _clinguin_assume(count(O,D,V)), selected(O,S).
attr(ddOpt(O,D), class, "btn-primary") :- sub_row_opts(O,D,_).
attr(ddOpt(O,D), class, "m-1") :- sub_row_opts(O,D,_).

elem(removeddOpt(O,D,V), dropdown_menu_item, ddOpt(O,D)) :- sub_row_opts(O,D,_), _clinguin_assume(count(O,D,V)).
attr(removeddOpt(O,D,V), icon, ("fa-ban";"text-info")) :- sub_row_opts(O,D,_), _b(count(O,D,V)).
when(removeddOpt(O,D,V), click, call, remove_assumption(count(O,D,V))) :-  _clinguin_assume(count(O,D,V)), sub_row_opts(O,D,_), selected(O,S).

elem(ddOpt(O,D,V), dropdown_menu_item, ddOpt(O,D)) :- _b(selected(O,S)), sub_row_opts(O,D,_), multiplicity(S,T,D,V).
attr(ddOpt(O,D,V), label, V) :- sub_row_opts(O,D,_), multiplicity(S,T,D,V).
attr(ddOpt(O,D,V), class, "text-danger") :- sub_row_opts(O,D,_), part(S,T,D), multiplicity(S,T,D,V), not _b(count(O,D,V)).
when(ddOpt(O,D,V), click, call, add_assumption(count(O,D,V))) :- _b(selected(O,S)), sub_row_opts(O,D,_), multiplicity(S,T,D,V), not _clinguin_assume(count(O,D,V)).









%---------------------------------------------------------------------------------------
% Attributes container
%---------------------------------------------------------------------------------------
% have to do the row, with the count, so that it is sorted

row(O,N) :- _c(selected(O,T)), dom(T,_,_),  N = #count{ O': _c(selected(O',_)), O'<O}.
sub_row(O,A,M) :- row(O,_), val((O,A),_) , M = #count{ A': _b(val((O,A'),_)), A'<A }, dom(T,A,_), _c(selected(O,T)).

% for each O, create a container,:
elem(container(O), container, left_container) :- row(O,_).
attr(container(O), grid_row, N + header_rows + K + 2) :- row(O,N), K = #count {J:row_opts(_,J)}.
attr(container(O), grid_column, 1) :- row(O,_).
attr(container(O), grid_column_span, 3) :- row(O,_).
attr(container(O), child_layout, grid) :- row(O,_).
attr(container(O), background_color, "#F6F1F1") :- row(O,_).
attr(container(O), class, "rounded") :- row(O,_).
attr(container(O), class, "border-primary") :- row(O,_).
attr(container(O), class, "border") :- row(O,_).
attr(container(O), class, "m-1") :- row(O,_).
attr(container(O), class, "p-1") :- row(O,_).
attr(container(O), class, "bg-light") :- row(O,_).

%---------------------------------------------------------------------------------------
% Attributes
%---------------------------------------------------------------------------------------
elem(label(O), label, left_container) :- row(O,_).
attr(label(O), label,@concat("",T,I,": ")) :- sub_row(O,A,_), selected(O,T,I).
attr(label(O), font_size, basicFontSize) :- row(O,_).
attr(label(O), grid_row, N + header_rows + K+ 2) :- row(O,N), K = #count {J:row_opts(_,J)}.
attr(label(O), grid_column, 0) :- row(O,N).
attr(label(O), background_color, "#F6F1F1") :- row(O,N).
attr(label(O), order, 2):-row(O,_).
attr(label(O), class, "m-2") :- row(O,_).
attr(label(O), class, "p-2") :- row(O,_).

elem(header(O,A), label, container(O)) :- sub_row(O,A,_).
attr(header(O,A), label, A) :- sub_row(O,A,_).
attr(header(O,A), grid_row, N) :- sub_row(O,A,N).
attr(header(O,A), grid_column, 0) :- sub_row(O,A,_).
attr(header(O,A), class, ("rounded";"border";"bg-danger")) :- sub_row(O,A,_), _muc(val((O,A),_)).

elem(dropdown(O,A), dropdown_menu, container(O)) :- sub_row(O,A,_).
attr(dropdown(O,A), grid_row, N) :- sub_row(O,A,N).
attr(dropdown(O,A), grid_column, 1) :- sub_row(O,A,_).
attr(dropdown(O,A), selected, V) :- dom(T,A,V), sub_row(O,A,_), _clinguin_assume(val((O,A),V)).
attr(dropdown(O,A), class, "btn-primary") :-  sub_row(O,A,_).
attr(dropdown(O,A), class, "m-1") :-  sub_row(O,A,_).

elem(remove_dropdown(O,A,V), dropdown_menu_item, dropdown(O,A)) :- sub_row(O,A,_), _clinguin_assume(val((O,A),V)).
attr(remove_dropdown(O,A,V), icon, ("fa-ban";"text-info")) :- sub_row(O,A,_), _clinguin_assume(val((O,A),V)).
when(remove_dropdown(O,A,V), click, call, remove_assumption(val((O,A),V))) :- sub_row(O,A,_), _clinguin_assume(val((O,A),V)).


elem(dropdown(O,A,V), dropdown_menu_item, dropdown(O,A)) :- sub_row(O,A,_), dom(T,A,V), selected(O,T,_).
attr(dropdown(O,A,V), label, V) :- dom(T,A,V), sub_row(O,A,_).
attr(dropdown(O,A,V), class, "text-danger") :- dom(T,A,V), sub_row(O,A,_), not _b(val((O,A),V)).
when(dropdown(O,A,V), click, call, add_assumption(val((O,A),V))) :- dom(T,A,V), sub_row(O,A,_), not _clinguin_assume(val((O,A),V)).















%---------------------------------------------------------------------------------------
% multiplicities label Choose quantity of the following:'
%---------------------------------------------------------------------------------------
elem(multi_label, label, left_container) :- row_opts(_,_).
attr(multi_label, label, "Choose quantity of the following:").
attr(multi_label, class, "h4").
attr(multi_label, grid_row, header_rows).
attr(multi_label, grid_column, 0).
attr(multi_label, grid_column_span, 4).
attr(multi_label, background_color, "#F6F1F1").

%---------------------------------------------------------------------------------------
% other Label 'Choose Attributes:'
%---------------------------------------------------------------------------------------
elem(other_label, label, left_container).
attr(other_label, label, "Choose Attributes:").
attr(other_label, class, "h4").
attr(other_label, grid_row, header_rows + 1 + K) :- K = #count {N:row_opts(_,N)}, K != 0.
attr(other_label, grid_row, header_rows) :- 0 = #count {N:row_opts(_,N)}.
attr(other_label, grid_column, 0).
attr(other_label, grid_column_span, 4).
attr(other_label, background_color, "#F6F1F1").







%---------------------------------------------------------------------------------------
%---------------------------------------------------------------------------------------
%---------------------------------------------------------------------------------------
% Buttons
%---------------------------------------------------------------------------------------
%---------------------------------------------------------------------------------------
%---------------------------------------------------------------------------------------


%---------------------------------------------------------------------------------------
% Suggestion Container
%---------------------------------------------------------------------------------------
elem(suggestion_container, container, left_container).
attr(suggestion_container, child_layout, grid).
attr(suggestion_container, grid_row, 1).
attr(suggestion_container, grid_column, 0).
attr(suggestion_container, grid_column_span, 2).
attr(suggestion_container, grid_row_span, 1).
attr(suggestion_container, class, "justify-content-start").






%---------------------------------------------------------------------------------------
% Get Suggestion button
%---------------------------------------------------------------------------------------
elem(next_solution, button, suggestion_container).
attr(next_solution, class, "btn-success").
attr(next_solution, class, "m-2").
attr(next_solution, class, "btn-lg").
attr(next_solution, label, "Get Suggestion") :- not recommendation.
attr(next_solution, label, "Next Suggestion") :- recommendation.
attr(next_solution, grid_row, 0).
attr(next_solution, grid_column, 0).
attr(next_solution, grid_column_span, 2).
attr(next_solution, grid_row_span, 1).
when(next_solution, click, call, get_suggestion).



%---------------------------------------------------------------------------------------
% Accept Suggestion button
%---------------------------------------------------------------------------------------
elem(acc_solution, button, suggestion_container) :- recommendation.
attr(acc_solution, label, "Accept").
attr(acc_solution, class, "btn-outline-success").
attr(acc_solution, class, "m-2").
attr(acc_solution, grid_row, 2).
attr(acc_solution, grid_column, 0).
attr(acc_solution, grid_column_span, 1).
attr(acc_solution, grid_row_span, 1).
when(acc_solution, click, call, accept_solution).


%---------------------------------------------------------------------------------------
% Remove Suggestion button
%---------------------------------------------------------------------------------------
elem(rem_solution, button, suggestion_container) :- recommendation.
attr(rem_solution, label, "Remove").
attr(rem_solution, class, "btn-outline-success").
attr(rem_solution, class, "m-2").
attr(rem_solution, grid_row, 2).
attr(rem_solution, grid_column, 1).
attr(rem_solution, grid_column_span, 1).
attr(rem_solution, grid_row_span, 1).
when(rem_solution, click, call, remove_solution).







%---------------------------------------------------------------------------------------
% Clear Assumptions container
%---------------------------------------------------------------------------------------
elem(clear_container, container, left_container).
attr(clear_container, child_layout, grid).
attr(clear_container, grid_row, 1).
attr(clear_container, grid_column, 2).
attr(clear_container, grid_column_span, 2).
attr(clear_container, grid_row_span, 1).
attr(clear_container, background_color, "#F6F1F1").
attr(clear_container, class, "justify-content-start").



%---------------------------------------------------------------------------------------
% Clear Assumptions Button
%---------------------------------------------------------------------------------------
elem(clear_all, button, clear_container).
attr(clear_all, label, "Clear all assumptions").
attr(clear_all, class, "btn-info").
attr(clear_all, class, "m-2").
attr(clear_all, class, "btn-lg").
when(clear_all, click, call, clear_assumptions).








elem(explanation_modal, modal, window).
attr(explanation_modal, title, "Explanation").
attr(explanation_modal, class, "modal-lg").
attr(explanation_modal, child_layout, flex).
attr(explanation_modal, flex_direction, row).

elem(explanation_modal_container, container, explanation_modal).
attr(explanation_modal_container, child_layout, grid).
attr(explanation_modal_container, class, "align-items-center").






%---------------------------------------------------------------------------------------
% Explanation Text
%---------------------------------------------------------------------------------------
elem(explanation(N), label, explanation_modal_container) :- explanation(N,_), explanation.
attr(explanation(N), label, V) :- explanation(N,V).
%attr(explanation(N), font_size, explanationFontSize) :- explanation(N,_).
%attr(explanation(N), font_family_base, "courier") :- explanation(N,_).
attr(explanation(N), class, "font-monospace") :- explanation(N,_).
attr(explanation(N), grid_column, 0) :- explanation(N,_).
attr(explanation(N), grid_row, M + K + header_rows + 3 + N + 2) :- M = #max{I:row(O,I)}, K = #count {J:row_opts(_,J)}, explanation(N,_).
attr(explanation(N), grid_column_span, 4) :- explanation(N,_).
%attr(explanation(N), background_color, "#F6F1F1") :- explanation(N,_).
attr(explanation(N), class, "text-start") :- explanation(N,_).






%---------------------------------------------------------------------------------------
%---------------------------------------------------------------------------------------
%---------------------------------------------------------------------------------------
% Menu Bar
%---------------------------------------------------------------------------------------
%---------------------------------------------------------------------------------------
%---------------------------------------------------------------------------------------



% Background colors:
%attr(window, background_color, "#F6F1F1").
%attr(left_container, background_color, "#F6F1F1").
%attr(right_container, background_color, "#F6F1F1").
attr(bike_header, background_color, "#F6F1F1").
attr(bike_header_info, background_color, "#F6F1F1").






