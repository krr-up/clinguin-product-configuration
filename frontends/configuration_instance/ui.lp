elem(window, window, root).
attr(window, child_layout, flex).
attr(window, flex_direction, row).



    elem(menu_bar, menu_bar, window).
    attr(menu_bar, title, "Product domain generation").
    attr(menu_bar, icon, "fa-home").


        elem(menu_bar_restart, button, menu_bar).
        attr(menu_bar_restart, label, "Restart").
        attr(menu_bar_restart, icon, "fa-arrows-rotate").
        attr(menu_bar_restart, class, "btn-outline-danger").
        attr(menu_bar_restart, class, "border-0").
        when(menu_bar_restart, click, call, restart).

        elem(menu_bar_download, button, menu_bar).
        attr(menu_bar_download, label, "Download").
        attr(menu_bar_download, icon, "fa-download").
        when(menu_bar_download, click, call, download("#show type/1. #show part/3. #show multiplicity/4. #show attr/3. #show dom/3. #show path/3.  #show path/2.  #show constraints/2. #show left/2. #show right/2.#show entry/3. ")).

    % Fix the heights of the container later
    elem(clingraph_container, container, window).
    attr(clingraph_container, child_layout, grid).

        elem(c, canvas, clingraph_container).
        attr(c, order, 2).
        attr(c, image_type, clingraph).
        attr(c, grid_row, 1).
        attr(c, grid_row_span, 9).
        attr(c, grid_column, 1).


    

    elem(selection_container, container, window).
    attr(selection_container, child_layout, grid).
    attr(selection_container, class, align-content-start).
    
    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Add Type
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        elem(add_type, button, selection_container).
        attr(add_type, label, "Add Type").
        attr(add_type, class, "btn-info").
        attr(add_type, class, "bg-opacity-50").
        attr(add_type, class, "border-info").
        % add M2 to all buttons
        attr(add_type, class, "m-2").
        attr(add_type, child_layout, flex).
        attr(add_type, flex_direction, column).
        attr(add_type, grid_row, 1).
        when(add_type, click, update, (add_type_modal, visible, shown)).
        

        elem(add_type_modal, modal, window).
        attr(add_type_modal, title, "Add Type").
        attr(add_type_modal, class, "modal-lg").
        attr(add_type_modal, child_layout, flex).
        attr(add_type_modal, flex_direction, row).
        % this is not working, as this class needs to be added to the parent element
        attr(add_type_modal, "class", "modal-lg").

            elem(type_modal_container, container, add_type_modal).
            attr(type_modal_container, child_layout, grid).
            attr(type_modal_container, class, "align-items-center").

                elem(type_t1, textfield, type_modal_container).
                attr(type_t1, placeholder, "name of the type").
                attr(type_t1, width, 250).
                attr(type_t1, grid_row, 1).
                when(type_t1, input, context, (type_t1_content, _value)).

                elem(type_b1, button, type_modal_container).
                when(type_b1, click, call, add_atom_instance_gen(type(_context_value(type_t1_content)))).
                attr(type_b1, label, "Add").
                attr(type_b1, class, "m-1").
                attr(type_b1, class, "btn-info").
                attr(type_b1, grid_row, 2).
                attr(type_b1, icon, "fa-plus").




        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Add Part
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        elem(add_part, button, selection_container).
        attr(add_part, label, "Add Part").
        attr(add_part, class, "btn-info").
        attr(add_part, class, "bg-opacity-50").
        attr(add_part, class, "border-info").
        attr(add_part, class, "m-2").
        attr(add_part, child_layout, flex).
        attr(add_part, flex_direction, column).
        attr(add_part, grid_row, 2).
        when(add_part, click, update, (add_part_modal, visible, shown)).
        

        elem(add_part_modal, modal, window).
        attr(add_part_modal, title, "Add Part").

            elem(part_modal_container, container, add_part_modal).
            attr(part_modal_container, child_layout, grid).
            attr(part_modal_container, class, align-content-start).
            attr(part_modal_container, class, align-items-left).

                % These are the dropdown options, 
                % problem: right now i cant pull the context out of the dropdowns, which i need, as there are multiple DD's in the modal

                elem(part_parent_dropdown, dropdown_menu, part_modal_container).
                attr(part_parent_dropdown, class, "btn-info").
                attr(part_parent_dropdown, class, "m-2").
                attr(part_parent_dropdown, grid_row, 1).
                attr(part_parent_dropdown, grid_column, 0).
                attr(part_parent_dropdown, selected, "Parent Type").
                % this only works, aftera  backend call:
                %attr(part_parent_dropdown, selected, T) :- _clinguin_context(part_parent_content,T).
                
                elem(part_parent_dropdown_item(T), dropdown_menu_item, part_parent_dropdown) :- type(T).
                attr(part_parent_dropdown_item(T), class, "text-info") :- type(T).
                attr(part_parent_dropdown_item(T), label, T) :- type(T).
                when(part_parent_dropdown_item(T), click, context, (part_parent_content, T)) :- type(T).
                when(part_parent_dropdown_item(T), click, update, (part_parent_dropdown, selected,T)) :- type(T).
                
                elem(part_child_dropdown, dropdown_menu, part_modal_container).
                attr(part_child_dropdown, class, "btn-info").
                attr(part_child_dropdown, class, "m-2").
                attr(part_child_dropdown, grid_row, 2).
                attr(part_child_dropdown, grid_column, 0).
                attr(part_child_dropdown, selected, "Child Type").
                
                
                elem(part_child_dropdown_item(T), dropdown_menu_item, part_child_dropdown) :- type(T).
                attr(part_child_dropdown_item(T), class, "text-info") :- type(T).
                attr(part_child_dropdown_item(T), label, T) :- type(T).
                when(part_child_dropdown_item(T), click, context, (part_child_content, T)) :- type(T).
                when(part_child_dropdown_item(T), click, update, (part_child_dropdown, selected,T)) :- type(T).



                elem(part_t1, textfield, part_modal_container).
                attr(part_t1, placeholder, "name of the Part").
                attr(part_t1, width, 250).
                attr(part_t1, grid_row, 3).
                when(part_t1, input, context, (part_t1_content, _value)).


                elem(part_t2, textfield, part_modal_container).
                attr(part_t2, placeholder, "multiplicity e.g.:1;2;3").
                attr(part_t2, width, 250).
                attr(part_t2, grid_row, 4).
                when(part_t2, input, context, (part_t2_content, _value)).


                elem(part_b1, button, part_modal_container).
                when(part_b1, click, call, (add_atom_instance_gen(part(_context_value(part_parent_content),
                                                            _context_value(part_child_content),
                                                            _context_value(part_t1_content))),
                                        add_atom_instance_gen(multiplicity(_context_value(part_parent_content),
                                                            _context_value(part_child_content),
                                                            _context_value(part_t1_content),
                                                            _context_value(part_t2_content))))).
                attr(part_b1, label, "Add").
                attr(part_b1, class, "m-1").
                attr(part_b1, class, "btn-info").
                attr(part_b1, icon, "fa-plus").
                attr(part_b1, grid_row, 5).




        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Add Attribute
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        elem(add_attribute, button, selection_container).
        attr(add_attribute, label, "Add Attribute").
        attr(add_attribute, class, "btn-info").
        attr(add_attribute, class, "bg-opacity-50").
        attr(add_attribute, class, "border-info").
        attr(add_attribute, class, "m-2").
        attr(add_attribute, child_layout, flex).
        attr(add_attribute, flex_direction, column).
        attr(add_attribute, grid_row, 3).
        when(add_attribute, click, update, (add_attribute_modal, visible, shown)).
        

        elem(add_attribute_modal, modal, window).
        attr(add_attribute_modal, title, "Add attribute").

        % maybe there is a class that 

            elem(attribute_modal_container, container, add_attribute_modal).
            attr(attribute_modal_container, child_layout, grid).
            attr(attribute_modal_container, class, "align-items-left").

                elem(attribute_parent_dropdown, dropdown_menu, attribute_modal_container).
                attr(attribute_parent_dropdown, class, "btn-info").
                attr(attribute_parent_dropdown, class, "m-2").
                attr(attribute_parent_dropdown, grid_row, 1).
                attr(attribute_parent_dropdown, grid_column, 0).
                attr(attribute_parent_dropdown, selected, "Parent Type").
                
                elem(attribute_parent_dropdown_item(T), dropdown_menu_item, attribute_parent_dropdown) :- type(T).
                attr(attribute_parent_dropdown_item(T), class, "text-info") :- type(T).
                attr(attribute_parent_dropdown_item(T), label, T) :- type(T).
                when(attribute_parent_dropdown_item(T), click, context, (attribute_parent_content, T)) :- type(T).
                when(attribute_parent_dropdown_item(T), click, update, (attribute_parent_dropdown, selected,T)) :- type(T).
                


                elem(attribute_t1, textfield, attribute_modal_container).
                attr(attribute_t1, placeholder, "name of the attribute").
                attr(attribute_t1, width, 250).
                attr(attribute_t1, grid_row, 2).
                when(attribute_t1, input, context, (attribute_t1_content, _value)).


                elem(attribute_t2, textfield, attribute_modal_container).
                attr(attribute_t2, placeholder, "domain e.g.: (red;green)").
                attr(attribute_t2, width, 250).
                attr(attribute_t2, grid_row, 3).
                when(attribute_t2, input, context, (attribute_t2_content, _value)).


                elem(attribute_b1, button, attribute_modal_container).
                when(attribute_b1, click, call, (add_atom_instance_gen(attr(_context_value(attribute_parent_content),
                                                            _context_value(attribute_t1_content),
                                                            "discrete")),
                                        add_atom_instance_gen(dom(_context_value(attribute_parent_content),
                                                            _context_value(attribute_t1_content),
                                                            _context_value(attribute_t2_content))))).
                attr(attribute_b1, label, "Add").
                attr(attribute_b1, class, "m-1").
                attr(attribute_b1, class, "btn-info").
                attr(attribute_b1, icon, "fa-plus").
                attr(attribute_b1, grid_row, 4).





        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Add Aggregated aggregated_attribute
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        elem(add_aggregated_attribute, button, selection_container).
        attr(add_aggregated_attribute, label, "Add Aggregated Attribute").
        attr(add_aggregated_attribute, class, "btn-info").
        attr(add_aggregated_attribute, class, "bg-opacity-50").
        attr(add_aggregated_attribute, class, "border-info").
        attr(add_aggregated_attribute, class, "m-2").
        attr(add_aggregated_attribute, child_layout, flex).
        attr(add_aggregated_attribute, flex_direction, column).
        attr(add_aggregated_attribute, grid_row, 4).
        when(add_aggregated_attribute, click, update, (add_aggregated_attribute_modal, visible, shown)).
        
        elem(add_aggregated_attribute_modal, modal, window).
        attr(add_aggregated_attribute_modal, title, "Add Aggregated Attribute").

            elem(aggregated_attribute_modal_container, container, add_aggregated_attribute_modal).
            attr(aggregated_attribute_modal_container, child_layout, grid).
            attr(aggregated_attribute_modal_container, class, "align-items-left").

                % These are the dropdown options, 
                % problem: right now i cant pull the context out of the dropdowns, which i need, as there are multiple DD's in the modal

                elem(aggregated_attribute_parent_dropdown, dropdown_menu, aggregated_attribute_modal_container).
                attr(aggregated_attribute_parent_dropdown, class, "btn-info").
                attr(aggregated_attribute_parent_dropdown, class, "m-2").
                attr(aggregated_attribute_parent_dropdown, grid_row, 1).
                attr(aggregated_attribute_parent_dropdown, grid_column, 0).
                attr(aggregated_attribute_parent_dropdown, selected, "Parent Type").
                
                elem(aggregated_attribute_parent_dropdown_item(T), dropdown_menu_item, aggregated_attribute_parent_dropdown) :- type(T).
                attr(aggregated_attribute_parent_dropdown_item(T), class, "text-info") :- type(T).
                attr(aggregated_attribute_parent_dropdown_item(T), label, T) :- type(T).
                when(aggregated_attribute_parent_dropdown_item(T), click, context, (aggregated_attribute_parent_content, T)) :- type(T).
                when(aggregated_attribute_parent_dropdown_item(T), click, update, (aggregated_attribute_parent_dropdown, selected,T)) :- type(T).
                


                elem(aggregated_attribute_t1, textfield, aggregated_attribute_modal_container).
                attr(aggregated_attribute_t1, placeholder, "name of the aggregated_attribute").
                attr(aggregated_attribute_t1, width, 200).
                attr(aggregated_attribute_t1, grid_row, 2).
                when(aggregated_attribute_t1, input, context, (aggregated_attribute_t1_content, _value)).


                elem(aggregated_attribute_t2, dropdown_menu, aggregated_attribute_modal_container).
                attr(aggregated_attribute_t2, class, "btn-info").
                attr(aggregated_attribute_t2, class, "m-2").
                attr(aggregated_attribute_t2, grid_row, 3).
                attr(aggregated_attribute_t2, grid_column, 0).
                attr(aggregated_attribute_t2, selected, "Aggregation Operator").
                
                operator(sum;count;min;max).
                elem(aggregated_attribute_operator_dropdown_item(T), dropdown_menu_item, aggregated_attribute_t2) :- operator(T).
                attr(aggregated_attribute_operator_dropdown_item(T), class, "text-info") :- operator(T).
                attr(aggregated_attribute_operator_dropdown_item(T), label, T) :- operator(T).
                when(aggregated_attribute_operator_dropdown_item(T), click, context, (aggregated_attribute_operator_content, T)) :- operator(T).
                when(aggregated_attribute_operator_dropdown_item(T), click, update, (aggregated_attribute_t2, selected,T)) :- operator(T).



                elem(aggregated_attribute_t3, textfield, aggregated_attribute_modal_container).
                attr(aggregated_attribute_t3, placeholder, "paths, seperated by ;").
                attr(aggregated_attribute_t3, width, 200).
                attr(aggregated_attribute_t3, grid_row, 4).
                when(aggregated_attribute_t3, input, context, (aggregated_attribute_t3_content, _value)).


                elem(aggregated_attribute_b1, button, aggregated_attribute_modal_container).
                when(aggregated_attribute_b1, click, call, (add_atom_instance_gen(attr(_context_value(aggregated_attribute_parent_content),
                                                            _context_value(aggregated_attribute_t1_content),
                                                            _context_value(aggregated_attribute_operator_content))),
                                        add_atom_instance_gen(path(_context_value(aggregated_attribute_parent_content),
                                                            _context_value(aggregated_attribute_t1_content),
                                                            _context_value(aggregated_attribute_t3_content))))).


                attr(aggregated_attribute_b1, label, "Add").
                attr(aggregated_attribute_b1, class, "m-1").
                attr(aggregated_attribute_b1, class, "btn-info").
                attr(aggregated_attribute_b1, icon, "fa-plus").
                attr(aggregated_attribute_b1, grid_row, 5).




                elem(aggregated_attribute_l3a, label, aggregated_attribute_modal_container).
                attr(aggregated_attribute_l3a, label, "Attribute Paths:").
                attr(aggregated_attribute_l3a, grid_row, 1).
                attr(aggregated_attribute_l3a, grid_column, 2).

                elem(aggregated_attribute_l3b, label, aggregated_attribute_modal_container).
                attr(aggregated_attribute_l3b, label, "Object Paths:").
                attr(aggregated_attribute_l3b, grid_row, 1).
                attr(aggregated_attribute_l3b, grid_column, 3).


                elem(aggregated_attribute_attr_path_container, container, aggregated_attribute_modal_container).
                attr(aggregated_attribute_attr_path_container, child_layout, flex).
                attr(aggregated_attribute_attr_path_container, grid_row, 2).
                attr(aggregated_attribute_attr_path_container, grid_row_span, 5).
                attr(aggregated_attribute_attr_path_container, grid_column, 2).

                elem(aggregated_attribute_l3(A,P), label, aggregated_attribute_attr_path_container) :- selector(O,(A,P),_), attr(_,A,_), object(O).
                attr(aggregated_attribute_l3(A,P), label, @concat("","(",A,",",P,")")) :- selector(O,(A,P),_), attr(_,A,_), object(O).


                elem(aggregated_attribute_object_path_container, container, aggregated_attribute_modal_container).
                attr(aggregated_attribute_object_path_container, child_layout, flex).
                attr(aggregated_attribute_object_path_container, grid_row, 2).
                attr(aggregated_attribute_object_path_container, grid_row_span, 5).
                attr(aggregated_attribute_object_path_container, grid_column, 3).

                
                elem(aggregated_attribute_l4(A,P), label, aggregated_attribute_object_path_container) :- selector(O,(A,P),_), not attr(_,A,_), object(O).
                attr(aggregated_attribute_l4(A,P), label, @concat("","(",A,",",P,")")) :- selector(O,(A,P),_), not attr(_,A,_), object(O).





        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Add Comparison Constraint
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        elem(add_comparison_constraint, button, selection_container).
        attr(add_comparison_constraint, label, "Add Comparison Constraint").
        attr(add_comparison_constraint, class, "btn-warning").
        attr(add_comparison_constraint, class, "bg-opacity-50").
        attr(add_comparison_constraint, class, "border-info").
        attr(add_comparison_constraint, class, "m-2").
        attr(add_comparison_constraint, child_layout, flex).
        attr(add_comparison_constraint, flex_direction, column).
        attr(add_comparison_constraint, grid_row, 5).
        when(add_comparison_constraint, click, update, (add_comparison_constraint_modal, visible, shown)).
        

        elem(add_comparison_constraint_modal, modal, window).
        attr(add_comparison_constraint_modal, title, "Add Comparison Constraint").

            elem(comparison_constraint_modal_container, container, add_comparison_constraint_modal).
            attr(comparison_constraint_modal_container, child_layout, grid).
            attr(comparison_constraint_modal_container, class, "align-items-left").

                % These are the dropdown options, 
                % problem: right now i cant pull the context out of the dropdowns, which i need, as there are multiple DD's in the modal


                elem(comparison_constraint_parent_dropdown, dropdown_menu, comparison_constraint_modal_container).
                attr(comparison_constraint_parent_dropdown, class, "btn-info").
                attr(comparison_constraint_parent_dropdown, class, "m-2").
                attr(comparison_constraint_parent_dropdown, grid_row, 1).
                attr(comparison_constraint_parent_dropdown, grid_column, 0).
                attr(comparison_constraint_parent_dropdown, selected, "Parent Type").
                
                elem(comparison_constraint_parent_dropdown_item(T), dropdown_menu_item, comparison_constraint_parent_dropdown) :- type(T).
                attr(comparison_constraint_parent_dropdown_item(T), class, "text-info") :- type(T).
                attr(comparison_constraint_parent_dropdown_item(T), label, T) :- type(T).
                when(comparison_constraint_parent_dropdown_item(T), click, context, (comparison_constraint_parent_content, T)) :- type(T).
                when(comparison_constraint_parent_dropdown_item(T), click, update, (comparison_constraint_parent_dropdown, selected,T)) :- type(T).
                

                elem(comparison_constraint_t2, dropdown_menu, comparison_constraint_modal_container).
                attr(comparison_constraint_t2, class, "btn-info").
                attr(comparison_constraint_t2, class, "m-2").
                attr(comparison_constraint_t2, grid_row, 2).
                attr(comparison_constraint_t2, grid_column, 0).
                attr(comparison_constraint_t2, selected, "Constraint Operator").
                
                constraint_operator(eq;neq;leq;geq;lte;gte).
                elem(comparison_constraint_operator_dropdown_item(T), dropdown_menu_item, comparison_constraint_t2) :- constraint_operator(T).
                attr(comparison_constraint_operator_dropdown_item(T), class, "text-info") :- constraint_operator(T).
                attr(comparison_constraint_operator_dropdown_item(T), label, T) :- constraint_operator(T).
                when(comparison_constraint_operator_dropdown_item(T), click, context, (comparison_constraint_operator_content, T)) :- constraint_operator(T).
                when(comparison_constraint_operator_dropdown_item(T), click, update, (comparison_constraint_t2, selected, T)) :- constraint_operator(T).




                elem(comparison_constraint_t3, textfield, comparison_constraint_modal_container).
                attr(comparison_constraint_t3, placeholder, "left path").
                attr(comparison_constraint_t3, width, 200).
                attr(comparison_constraint_t3, grid_row, 3).
                when(comparison_constraint_t3, input, context, (comparison_constraint_t3_content, _value)).


                elem(comparison_constraint_t4, textfield, comparison_constraint_modal_container).
                attr(comparison_constraint_t4, placeholder, "right path").
                attr(comparison_constraint_t4, width, 200).
                attr(comparison_constraint_t4, grid_row, 4).
                when(comparison_constraint_t4, input, context, (comparison_constraint_t4_content, _value)).


                elem(comparison_constraint_b1, button, comparison_constraint_modal_container).
                when(comparison_constraint_b1, click, call, (add_atom_instance_gen(constraint((_context_value(comparison_constraint_parent_content),0),
                                                                _context_value(comparison_constraint_t2_content))),
                                                            add_atom_instance_gen(left((_context_value(comparison_constraint_parent_content),0),
                                                                _context_value(comparison_constraint_t3_content))),
                                                            add_atom_instance_gen(right((_context_value(comparison_constraint_parent_content),0),
                                                                _context_value(comparison_constraint_t4_content))))).


                attr(comparison_constraint_b1, label, "Add").
                attr(comparison_constraint_b1, class, "m-1").
                attr(comparison_constraint_b1, class, "btn-info").
                attr(comparison_constraint_b1, icon, "fa-plus").
                attr(comparison_constraint_b1, grid_row, 5).



                elem(comparison_constraint_l3a, label, comparison_constraint_modal_container).
                attr(comparison_constraint_l3a, label, "Attribute Paths:").
                attr(comparison_constraint_l3a, grid_row, 1).
                attr(comparison_constraint_l3a, grid_column, 2).

                elem(comparison_constraint_attr_path_container, container, comparison_constraint_modal_container).
                attr(comparison_constraint_attr_path_container, child_layout, flex).
                attr(comparison_constraint_attr_path_container, grid_row, 2).
                attr(comparison_constraint_attr_path_container, grid_row_span, 5).
                attr(comparison_constraint_attr_path_container, grid_column, 2).

                elem(comparison_constraint_l3(A,P), label, comparison_constraint_attr_path_container) :- selector(O,(A,P),_), attr(_,A,_), object(O).
                attr(comparison_constraint_l3(A,P), label, @concat("","(",A,",",P,")")) :- selector(O,(A,P),_), attr(_,A,_), object(O).



        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Add table Constraint
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        elem(add_table_constraint, button, selection_container).
        attr(add_table_constraint, label, "Add Table Constraint").
        attr(add_table_constraint, class, "btn-warning").
        attr(add_table_constraint, class, "bg-opacity-50").
        attr(add_table_constraint, class, "border-info").
        attr(add_table_constraint, class, "m-2").
        attr(add_table_constraint, child_layout, flex).
        attr(add_table_constraint, flex_direction, column).
        attr(add_table_constraint, grid_row, 6).
        when(add_table_constraint, click, update, (add_table_constraint_modal, visible, shown)).
        

        elem(add_table_constraint_modal, modal, window).
        attr(add_table_constraint_modal, title, "Add Table Constraint").

            elem(table_constraint_modal_container, container, add_table_constraint_modal).
            attr(table_constraint_modal_container, child_layout, grid).
            attr(table_constraint_modal_container, class, "align-items-left").

                % These are the dropdown options, 
                % problem: right now i cant pull the context out of the dropdowns, which i need, as there are multiple DD's in the modal

                elem(table_constraint_parent_dropdown, dropdown_menu, table_constraint_modal_container).
                attr(table_constraint_parent_dropdown, class, "btn-info").
                attr(table_constraint_parent_dropdown, class, "m-2").
                attr(table_constraint_parent_dropdown, grid_row, 1).
                attr(table_constraint_parent_dropdown, grid_column, 0).
                attr(table_constraint_parent_dropdown, selected, "Parent Type").
                
                elem(table_constraint_parent_dropdown_item(T), dropdown_menu_item, table_constraint_parent_dropdown) :- type(T).
                attr(table_constraint_parent_dropdown_item(T), class, "text-info") :- type(T).
                attr(table_constraint_parent_dropdown_item(T), label, T) :- type(T).
                when(table_constraint_parent_dropdown_item(T), click, context, (table_constraint_parent_content, T)) :- type(T).
                when(table_constraint_parent_dropdown_item(T), click, update, (table_constraint_parent_dropdown, selected,T)) :- type(T).
               

                elem(table_constraint_t3, textfield, table_constraint_modal_container).
                attr(table_constraint_t3, placeholder, "left path").
                attr(table_constraint_t3, width, 200).
                attr(table_constraint_t3, grid_row, 2).
                when(table_constraint_t3, input, context, (table_constraint_t3_content, _value)).


                elem(table_constraint_t4, textfield, table_constraint_modal_container).
                attr(table_constraint_t4, placeholder, "right path").
                attr(table_constraint_t4, width, 200).
                attr(table_constraint_t4, grid_row, 3).
                when(table_constraint_t4, input, context, (table_constraint_t4_content, _value)).


                elem(table_constraint_t5, textfield, table_constraint_modal_container).
                attr(table_constraint_t5, placeholder, "left values (;-seperated)").
                attr(table_constraint_t5, width, 200).
                attr(table_constraint_t5, grid_row, 4).
                when(table_constraint_t5, input, context, (table_constraint_t5_content, _value)).


                elem(table_constraint_t6, textfield, table_constraint_modal_container).
                attr(table_constraint_t6, placeholder, "right values (;-seperated)").
                attr(table_constraint_t6, width, 200).
                attr(table_constraint_t6, grid_row, 5).
                when(table_constraint_t6, input, context, (table_constraint_t6_content, _value)).


                elem(table_constraint_b1, button, table_constraint_modal_container).
                when(table_constraint_b1, click, call, (add_atom_instance_gen(constraint((_context_value(table_constraint_parent_content),0),
                                                                table)),
                                                            add_atom_instance_gen(column((_context_value(table_constraint_parent_content),0),0,
                                                                _context_value(table_constraint_t3_content))),
                                                            add_atom_instance_gen(column((_context_value(table_constraint_parent_content),0),1,
                                                                _context_value(table_constraint_t4_content))),
                                                            add_atom_instance_gen(entries((_context_value(table_constraint_parent_content),0),0,
                                                                _context_value(table_constraint_t5_content))),
                                                            add_atom_instance_gen(entries((_context_value(table_constraint_parent_content),0),1,
                                                                _context_value(table_constraint_t6_content))),
                                                            )).


                attr(table_constraint_b1, label, "Add").
                attr(table_constraint_b1, class, "m-1").
                attr(table_constraint_b1, class, "btn-info").
                attr(table_constraint_b1, icon, "fa-plus").
                attr(table_constraint_b1, grid_row, 6).



                elem(table_constraint_l3a, label, table_constraint_modal_container).
                attr(table_constraint_l3a, label, "Attribute Paths:").
                attr(table_constraint_l3a, grid_row, 1).
                attr(table_constraint_l3a, grid_column, 2).

                elem(table_constraint_attr_path_container, container, table_constraint_modal_container).
                attr(table_constraint_attr_path_container, child_layout, flex).
                attr(table_constraint_attr_path_container, grid_row, 2).
                attr(table_constraint_attr_path_container, grid_row_span, 6).
                attr(table_constraint_attr_path_container, grid_column, 2).

                elem(table_constraint_l3(A,P), label, table_constraint_attr_path_container) :- selector(O,(A,P),_), attr(_,A,_), object(O).
                attr(table_constraint_l3(A,P), label, @concat("","(",A,",",P,")")) :- selector(O,(A,P),_), attr(_,A,_), object(O).





        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Add consistency Constraint
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        elem(add_consistency_constraint, button, selection_container).
        attr(add_consistency_constraint, label, "Add Consistency Constraint").
        attr(add_consistency_constraint, class, "btn-warning").
        attr(add_consistency_constraint, class, "bg-opacity-50").
        attr(add_consistency_constraint, class, "border-info").
        attr(add_consistency_constraint, class, "m-2").
        attr(add_consistency_constraint, child_layout, flex).
        attr(add_consistency_constraint, flex_direction, column).
        attr(add_consistency_constraint, grid_row, 7).
        when(add_consistency_constraint, click, update, (add_consistency_constraint_modal, visible, shown)).
        

        elem(add_consistency_constraint_modal, modal, window).
        attr(add_consistency_constraint_modal, title, "Add Consistency Constraint").

            elem(consistency_constraint_modal_container, container, add_consistency_constraint_modal).
            attr(consistency_constraint_modal_container, child_layout, grid).
            attr(consistency_constraint_modal_container, class, "align-items-left").

                % These are the dropdown options, 
                % problem: right now i cant pull the context out of the dropdowns, which i need, as there are multiple DD's in the modal

                elem(consistency_constraint_parent_dropdown, dropdown_menu, consistency_constraint_modal_container).
                attr(consistency_constraint_parent_dropdown, class, "btn-info").
                attr(consistency_constraint_parent_dropdown, class, "m-2").
                attr(consistency_constraint_parent_dropdown, grid_row, 1).
                attr(consistency_constraint_parent_dropdown, grid_column, 0).
                attr(consistency_constraint_parent_dropdown, selected, "Parent Type").
                
                elem(consistency_constraint_parent_dropdown_item(T), dropdown_menu_item, consistency_constraint_parent_dropdown) :- type(T).
                attr(consistency_constraint_parent_dropdown_item(T), class, "text-info") :- type(T).
                attr(consistency_constraint_parent_dropdown_item(T), label, T) :- type(T).
                when(consistency_constraint_parent_dropdown_item(T), click, context, (consistency_constraint_parent_content, T)) :- type(T).
                when(consistency_constraint_parent_dropdown_item(T), click, update, (consistency_constraint_parent_dropdown, selected,T)) :- type(T).
                


                elem(consistency_constraint_t2, dropdown_menu, consistency_constraint_modal_container).
                attr(consistency_constraint_t2, class, "btn-info").
                attr(consistency_constraint_t2, class, "m-2").
                attr(consistency_constraint_t2, grid_row, 2).
                attr(consistency_constraint_t2, grid_column, 0).
                attr(consistency_constraint_t2, selected, "Constraint Operator").
                
                consistency_constraint_operator(alldiff;allsame).
                elem(consistency_constraint_operator_dropdown_item(T), dropdown_menu_item, consistency_constraint_t2) :- consistency_constraint_operator(T).
                attr(consistency_constraint_operator_dropdown_item(T), class, "text-info") :- consistency_constraint_operator(T).
                attr(consistency_constraint_operator_dropdown_item(T), label, T) :- consistency_constraint_operator(T).
                when(consistency_constraint_operator_dropdown_item(T), click, context, (consistency_constraint_operator_content, T)) :- consistency_constraint_operator(T).
                when(consistency_constraint_operator_dropdown_item(T), click, update, (consistency_constraint_t2, selected,T)) :- consistency_constraint_operator(T).




                elem(consistency_constraint_t4, textfield, consistency_constraint_modal_container).
                attr(consistency_constraint_t4, placeholder, "paths (;-seperated)").
                attr(consistency_constraint_t4, width, 200).
                attr(consistency_constraint_t4, grid_row, 3).
                when(consistency_constraint_t4, input, context, (consistency_constraint_t4_content, _value)).


                elem(consistency_constraint_b1, button, consistency_constraint_modal_container).
                when(consistency_constraint_b1, click, call, (add_atom_instance_gen(constraint((_context_value(consistency_constraint_parent_content),0),
                                                                _context_value(consistency_constraint_t3_content))),
                                                            add_atom_instance_gen(paths((_context_value(consistency_constraint_parent_content),0),
                                                                _context_value(consistency_constraint_t4_content))))).


                attr(consistency_constraint_b1, label, "Add").
                attr(consistency_constraint_b1, class, "m-1").
                attr(consistency_constraint_b1, class, "btn-info").
                attr(consistency_constraint_b1, icon, "fa-plus").
                attr(consistency_constraint_b1, grid_row, 4).



                elem(consistency_constraint_l3a, label, consistency_constraint_modal_container).
                attr(consistency_constraint_l3a, label, "Attribute Paths:").
                attr(consistency_constraint_l3a, grid_row, 1).
                attr(consistency_constraint_l3a, grid_column, 2).

                elem(consistency_constraint_attr_path_container, container, consistency_constraint_modal_container).
                attr(consistency_constraint_attr_path_container, child_layout, flex).
                attr(consistency_constraint_attr_path_container, grid_row, 2).
                attr(consistency_constraint_attr_path_container, grid_row_span, 4).
                attr(consistency_constraint_attr_path_container, grid_column, 2).

                elem(consistency_constraint_l3(A,P), label, consistency_constraint_attr_path_container) :- selector(O,(A,P),_), attr(_,A,_), object(O).
                attr(consistency_constraint_l3(A,P), label, @concat("","(",A,",",P,")")) :- selector(O,(A,P),_), attr(_,A,_), object(O).






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
    return String(''.join([str(x).strip('"') for x in args]))

#end.