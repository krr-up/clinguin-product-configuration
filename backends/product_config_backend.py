from clinguin.server.application.backends import ClingraphBackend, ClingoBackend
from clingo import Control, parse_term
import textwrap
from clingraph.clingo_utils import ClingraphContext
from clingraph import Factbase, compute_graphs, render

from xclingo import XclingoControl
from clingo import Control

import os

class ProductConfigBackend(ClingraphBackend):
    """
    TODO
    """
    def __init__(self, args):

        self._clingraph_files = args.clingraph_files

        # Explanation stuff
        self._muc=None
        self._lit2symbol = {}
        self._mc_base_assumptions = set()
        self._last_prg = None
        self.added_assumptions = []
        if not args.assumption_signature:
            args.assumption_signature = []
        super().__init__(args)

        for a in args.assumption_signature:
            try:
                name = a.split(",")[0]
                arity = int(a.split(",")[1])
            except:
                raise ValueError("Argument assumption_signature must have format name,arity")
            for s in self._ctl.symbolic_atoms:
                if s.symbol.match(name,arity):
                    self._mc_base_assumptions.add(s.symbol)
                    self._add_symbol_to_dict(s.symbol)
        self._assumptions = self._mc_base_assumptions.copy()


    @classmethod
    def register_options(cls, parser):
        ClingraphBackend.register_options(parser)

        parser.add_argument('--assumption-signature',
                        help = textwrap.dedent('''\
                            Signatures that will be considered as assumtions. Must be have format name,arity'''),
                        nargs='+',
                        metavar='')

    # ---------------------------------------------
    # Overwrite
    # ---------------------------------------------

    def _add_assumption(self, predicate_symbol):
        self.added_assumptions += [predicate_symbol]
        self._add_symbol_to_dict(predicate_symbol)
        self._assumptions.add(predicate_symbol)



    def _update_uifb_ui(self, extra_program=''):
        super()._update_uifb_ui(extra_program=extra_program)
        graphs = self._compute_clingraph_graphs(self._uifb.conseq_facts, extra_program)
        if not self._disable_saved_to_file:
            self._save_clingraph_graphs_to_file(graphs)
        self._replace_uifb_with_b64_images_clingraph(graphs)
        
    
    @property
    def _backend_state_prg(self):
        """
        Additional program to pass to the UI computation. It represents to the state of the backend
        """
        prg = super()._backend_state_prg
        if self._uifb.is_unsat:
            self._logger.info("UNSAT Answer, will add explanation here")
            clingo_core = self._uifb._unsat_core
            # TODO: Problem: after getting and accepting a suggestion and removing an assumption, there is one key missing in the self._lit2symbol dict
            # might have to do with the remove_assumption function
            # maybe also with the added atoms: recomendation?
            # clingo_core_symbols = [self._lit2symbol[s] for s in clingo_core if s!=-1]
            clingo_core_symbols = [self._lit2symbol[s] for s in clingo_core if s!=-1 and s in self._lit2symbol.keys()]
            muc_core = self._get_minimum_uc(clingo_core_symbols)
            self.muc_constraints = []
            for s in muc_core:
                if 'constraint' in str(s):
                    self.muc_constraints += [str(s) + '.']
                prg = prg + f"_muc({str(s)})."
        return prg

    def _compute_clingraph_graphs(self,prg,extra_program):
        fbs = []
        ctl = Control("0")
        for f in self._clingraph_files:
            ctl.load(f)
        ctl.add("base",[],extra_program)
        ctl.add("base",[],prg)
        ctl.add("base",[],self._backend_state_prg)
        ctl.ground([("base",[])],ClingraphContext())
        ctl.solve(on_model=lambda m: fbs.append(Factbase.from_model(m)))
        if self._select_model is not None:
            for m in self._select_model:
                if m>=len(fbs):
                    raise ValueError(f"Invalid model number selected {m}")
            fbs = [f if i in self._select_model else None
                        for i, f in enumerate(fbs) ]



        graphs = compute_graphs(fbs, graphviz_type=self._type)

        return graphs

    # ---------------------------------------------
    # Private methods
    # ---------------------------------------------

    def _add_symbol_to_dict(self,symbol):
        lit = self._ctl.symbolic_atoms[symbol].literal
        self._lit2symbol[lit]=symbol


    def _solve_core(self, assumptions):
        with self._ctl.solve(assumptions=[(a,True) for a in assumptions], yield_=True) as solve_handle:
            satisfiable = solve_handle.get().satisfiable
            core = [self._lit2symbol[s] for s in solve_handle.core() if s!=-1 and s in self._lit2symbol.keys()]
            # core = [self._lit2symbol[s] for s in solve_handle.core() if s!=-1]
        return satisfiable, core

    def _get_minimum_uc(self, different_assumptions):
        sat, _ = self._solve_core(assumptions=different_assumptions)

        if sat:
            return []

        assumption_set = different_assumptions
        probe_set = []

        for i, assumption in enumerate(assumption_set):
            working_set = assumption_set[i+1:]
            sat, _ = self._solve_core(assumptions=working_set + probe_set)
            if sat:
                probe_set.append(assumption)

                if not self._solve_core(assumptions=probe_set)[0]:
                    break

        return probe_set



    # ---------------------------------------------
    # Policy methods (Overwrite ClingoBackend)
    # ---------------------------------------------

    def clear_assumptions(self):
        self.remove_atom_only_ui(f'recommendation')
        self.remove_atom_only_ui(f'explanation')
        self.added_assumptions = []
        self._end_browsing()
        self._assumptions = self._mc_base_assumptions.copy()
        self._update_uifb()
        return self.get()
    
    def _add_atom_prod_conf(self, predicate):
        """
        Policy: Adds an assumption and basically resets the rest of the application (reground) - finally it returns the udpated Json structure.
        """
        predicate_symbol = parse_term(predicate)
        if predicate_symbol not in self._atoms:
            self._atoms.add(predicate_symbol)
            # Maybe best to do using the callback tuple?
            self._init_ctl()
            self._ground()
            self._end_browsing()

        # return self.get()

    def get_suggestion(self, opt_mode='ignore'):
        self._add_atom_prod_conf(f'recommendation')

        if self._ctl.configuration.solve.opt_mode != opt_mode:
            self._logger.debug("Ended browsing since opt mode changed")
            self._end_browsing()
        optimizing = opt_mode in ['optN','opt']
        if not self._iterator:
            self._ctl.configuration.solve.enum_mode = 'auto'
            self._ctl.configuration.solve.opt_mode = opt_mode
            self._ctl.configuration.solve.models = 0
            self._handler = self._ctl.solve(
                assumptions=[(a,True) for a in self._assumptions],
                yield_=True)
            self._iterator = iter(self._handler)
        try:
            self.current_model = next(self._iterator)
            while optimizing and not self.current_model.optimality_proven:
                self._logger.info("Skipping non-optimal model")
                self.current_model = next(self._iterator)
            # for latest clinguin version:
            self._uifb.set_auto_conseq(self.current_model)
            # self._uifb.set_auto_conseq(self.current_model.symbols(shown=True,atoms=False))
            self._update_uifb_ui()
        except StopIteration:
            self._logger.info("No more solutions")
            self._end_browsing()
            self._update_uifb()
            self._uifb.add_message("Browsing Information","No more solutions")

        return self.get()



    def remove_atom_only_ui(self, predicate):
        """
        Policy: Removes an assumption and basically resets the rest of the application (reground) -
        finally it returns the udpated Json structure.
        """
        predicate_symbol = parse_term(predicate)
        if predicate_symbol in self._atoms:
            self._atoms.remove(predicate_symbol)
            self._init_ctl()
            self._ground()
            self._end_browsing()
            self._update_uifb_ui()
        return self.get()

    def remove_assumption(self, predicate):
        """
        Policy: Removes an assumption and returns the udpated Json structure.
        """
        self.remove_atom_only_ui(f'recommendation')
        predicate_symbol = parse_term(predicate)
        self.added_assumptions.remove(predicate_symbol)
        if predicate_symbol in self._assumptions:
            self._assumptions.remove(predicate_symbol)
            self._end_browsing()
            self._update_uifb()
        return self.get()

    def add_assumption(self, predicate):
        """
        Policy: Adds an assumption and returns the udpated Json structure.
        """
        self.remove_atom_only_ui(f'recommendation')
        predicate_symbol = parse_term(predicate)
        if predicate_symbol not in self._assumptions:
            self._add_assumption(predicate_symbol)
            self._end_browsing()
            self._update_uifb()

        return self.get()

    def add_assumption_prod_conf(self, predicate):
        """
        Policy: Adds an assumption and returns the udpated Json structure.
        """
        predicate_symbol = parse_term(predicate)
        if predicate_symbol not in self._assumptions:
            self.added_assumptions += [predicate]
            self._add_assumption(predicate_symbol)
            self._end_browsing()
        # return self.get()

    def accept_solution(self):
        '''
        here we want to add the atoms from the current solution as assumptions
        '''

        # Maybe the aggregates are added here, which they shouldn't
        for fact in self._uifb.conseq_facts.split('.'):
            if fact.startswith('_c('):
                fact_tmp = fact.replace(').','')
                new_assumption = fact_tmp[3:]
                if 'count(' in new_assumption:
                    self.add_assumption_prod_conf(new_assumption)
                    self._logger.info(f'added {new_assumption}')
                if 'val(' in new_assumption:
                    self.add_assumption_prod_conf(new_assumption)
                    self._logger.info(f'added {new_assumption}')

        # TODO: we also want to assume all the cautios atoms here, so the ones shown in the clingraph
        if not hasattr(self, 'current_model'):
            self._update_uifb()
            return self.get()

        # TODO: breaks when it is defined with '' and without it, sum might be part of some name
        aggregates = [i.split(',')[1].split(',')[0] for i in str(self.current_model).split(' ') if '"sum"' in i]
        skip_assumption = False
        for new_assumption in str(self.current_model).split(' '):
            if 'count(' in new_assumption:
                self.add_assumption_prod_conf(new_assumption)
            if 'val(' in new_assumption:
                for agg in aggregates:
                    if agg in new_assumption:
                        skip_assumption = True
                if not skip_assumption:
                    self.add_assumption_prod_conf(new_assumption)
                    skip_assumption = False
        
        # also add all cautios atoms
        # we want to loop through all cautios atom, check if they are already assumed, and add as assumption is not
        
        self.remove_atom(f'recommendation')
        return self.get()
        


    def remove_solution(self):
        self.remove_atom_only_ui(f'recommendation')
        self._update_uifb()
        return self.get()


    def remove_explanation_prod_conf(self):
        self.remove_atom_only_ui(f'explanation')
        self._update_uifb()
        return self.get()




    def get_explanation_aggregates(self):

        # load the annotated encoding
        with open('examples/configuration/xclingo_encoding_aggregates.lp', "r") as file:
            xclingo_encoding = file.read()

        # load the actual instance, 
        # TODO: we dont need this anymore, as they are contained in the _uifb.conseq_facts
        for f in self._domain_files:
            if 'instance' in str(f):
                with open(str(f).replace('_translated',''), "r") as file:
                    file_contents = file.read()



        # this might be unnecessary:
        # It is not, as the xclingo encoding lacks the integrety constraint :- unsat(C).
        # Therefore no bag objects are created and a constraint is falsely activated

        assumption_list = []
        for fact in self._uifb.conseq_facts.split('\n'):
            # This ensures to use the same facts, as the clingraph solution
            if fact.startswith('_c(val('):
                assumption_list += [str(fact)[3:-2]+'.']
            if fact.startswith('_c(selected('):
                assumption_list += [str(fact)[3:-2]+'.']
        
        for assumpt in self.added_assumptions:
            assumption_blank = ','.join(str(assumpt).split(',')[:-1]) + ',_)'
            for i in assumption_list:
                assumption_blank_tmp = ','.join(i.split(',')[:-1]) + ',_)'
                if assumption_blank_tmp == assumption_blank:
                    assumption_list.remove(i)
                    assumption_list += [str(assumpt) + '.']



        # TODO: Here we need to add the actual assumptions as facts
        assumptions = ''
        for assumption in assumption_list:
            # here we dont want the aggregates
            # there should be a better way of doing this, but it works for now
            if 'stowage' in assumption or 'totalWeight' in assumption or 'totalBags' in assumption :
                continue
            assumptions += str(assumption) + '\n'



        annotated_program = xclingo_encoding + assumptions + file_contents
        
        xclingo_control = XclingoControl(
            ['1'],
            n_explanations='0'
        )
        xclingo_control.add('base', [], annotated_program)
        xclingo_control.ground([("base", [])])
        nanswer = 0
        explanations = []
        for xModel in xclingo_control.solve():
            nanswer += 1
            for graphModel in xModel.explain_model():
                explanation = [graphModel.explain(s).ascii_tree() for s in graphModel.show_trace]
                if len(explanation) == 0:
                    self._logger.info("no explanation found")
                    return self.get()
                # idea: maybe we want to take the explanations that have more than 1 entries
                for i in explanation:
                    if (len(i.split('\n')) <= 1) or (not 'Object' in i):
                        continue
                    explanations += i.split('\n')

        if len(explanations) == 0:
            self._logger.info("no unsat solution found")
            return self.get()

        expl_counter = 0
        old = '"'
        new = ''
        atoms_to_add = []
        for i in explanations:
            if expl_counter > 20:
                break
            explanation_string = i.strip().replace(old,new)
            atoms_to_add += [f'explanation({expl_counter},"{explanation_string}")']
            expl_counter += 1
        
        atoms_to_add += [f'explanation']
        atoms_to_add += ['attr(explanation_modal, visible, shown)']
        
        
        additional_program = '.\n'.join(atoms_to_add) + '.'
        
        self._update_uifb_ui(extra_program=additional_program)
        return self.get()
        




    def get_explanation_unsat(self):

        # load the annotated encoding
        with open('examples/configuration/xclingo_encoding_unsat.lp', "r") as file:
            xclingo_encoding = file.read()

        # load the actual instance, 
        # TODO: we dont need this anymore, as they should be contained in the _uifb.conseq_facts
        for f in self._domain_files:
            if 'instance' in str(f):
                with open(str(f), "r") as file:
                    file_contents = file.read()
        # Delete the contraint rows, as they are added later
        file_contents_no_constraints = ''
        for row in file_contents.split('\n'):
            if not 'constraint' in row:
                file_contents_no_constraints += row + '\n'



        # this might be unnecessary:
        # It is not, as the xclingo encoding lacks the integrety constraint :- unsat(C).
        # Therefore no bag objects are created and a constraint is falsely activated
        # this would be the other approach. This fixes some examples, like stowage >= minStowage constraint,
        # but it also breaks the size == size AND size, weight table 
        # assumptions = '\n' + '.\n'.join([str(s) for s in self.added_assumptions]) + '.\n'
        
        assumption_list = []
        for fact in self._uifb.conseq_facts.split('\n'):
            if fact.startswith('val('):
                assumption_list += [str(fact)]
            if fact.startswith('selected('):
                assumption_list += [str(fact)]
        
        helper_assumptions = []
        for assumpt in self.added_assumptions:
            assumption_blank = ','.join(str(assumpt).split(',')[:-1]) + ',_)'
            atom_tmp = str(assumpt).replace('.','')
            helper_assumptions += [f'assumption({atom_tmp}).']

            for i in assumption_list:
                assumption_blank_tmp = ','.join(i.split(',')[:-1]) + ',_)'
                if assumption_blank_tmp == assumption_blank:
                    assumption_list.remove(i)
                    assumption_list += [str(assumpt) + '.']




        # TODO: Here we need to add the actual assumptions as facts
        assumptions = ''
        for assumption in assumption_list:
            # here we dont want the aggregates
            # TODO: there should be a better way of doing this, but it works for now
            if 'stowage' in assumption or 'totalWeight' in assumption or 'totalBags' in assumption:
                continue
            assumptions += str(assumption) + '\n'


        helper_assumptions_to_add = '\n' + '\n'.join(helper_assumptions)
        contraints_to_add = '\n' + '\n'.join(self.muc_constraints)

        annotated_program = xclingo_encoding + assumptions + file_contents_no_constraints + contraints_to_add + helper_assumptions_to_add
        
        xclingo_control = XclingoControl(
            ['1'],
            n_explanations='0'
        )
        xclingo_control.add('base', [], annotated_program)
        xclingo_control.ground([("base", [])])
        nanswer = 0
        explanations = []
        for xModel in xclingo_control.solve():
            nanswer += 1
            for graphModel in xModel.explain_model():
                explanation = [graphModel.explain(s).ascii_tree() for s in graphModel.show_trace]
                if len(explanation) == 0:
                    self._logger.info("no explanation found")
                    return self.get()
                # idea: maybe we want to take the explanations that have more than 1 entries
                for i in explanation:
                    if (not 'Constraint' in i):
                        continue
                    explanations += i.split('\n')
        
        if len(explanations) == 0:
            self._logger.info("no unsat solution found")
            return self.get()

        expl_counter = 0
        old = '"'
        new = ''
        atoms_to_add = []
        # This was used in the old tkinter frontend to truncate the explanations
        # max_string_length = 68 # 68 for font 12
        for i in explanations:
            if expl_counter > 20:
                break
            explanation_string = i.strip().replace(old,new)
            atoms_to_add += [f'explanation({expl_counter},"{explanation_string}")']
            expl_counter += 1
        
        atoms_to_add += [f'explanation']
        atoms_to_add += ['attr(explanation_modal, visible, shown)']

        
        additional_program = '.\n'.join(atoms_to_add) + '.'
        self._update_uifb_ui(extra_program=additional_program)
        return self.get()
        
    


    def download(self, show_prg= None, directory='exports'):
        """
        Policy: Downloads the current state of the backend. All added atoms and assumptions
        are put together as a list of facts. 

        Args:
            show_prg (_type_, optional): Program to filter output using show statements. Defaults to None.
            file_name (str, optional): The name of the file for the download. Defaults to "clinguin_download.lp".

        """
        file_name = "model_representation.lp"
        image_name = "finished_configuration"

        prg = self._output_prg
        was_browsing = self._is_browsing
        self._end_browsing()
        self._update_uifb()
        if was_browsing:
            self._uifb.add_message("Warning", "Browsing was active during download, only selected solutions will be present on the file.", "warning")
        if show_prg is not None:
            ctl = Control()
            ctl.add("base", [], prg)
            ctl.add("base", [], show_prg.replace('"',''))
            ctl.ground([("base", [])])
            with ctl.solve(yield_=True) as hnd:
                for m in hnd:
                    atoms = [f"{str(s)}." for s in m.symbols(shown=True)]
            prg = "\n".join(atoms)

        if not os.path.exists(directory):
            os.makedirs(directory)
        with open(os.path.join(directory, file_name), "w") as file:
            file.write(prg)
        self._uifb.add_message("Download successful", f"Information saved in file {directory}/{file_name}", "success")


        fbs = []
        ctl = Control("0")
        for f in self._clingraph_files:
            ctl.load(f)
        ctl.add("base",[],self._uifb.conseq_facts)
        ctl.add("base",[],self._backend_state_prg)
        ctl.ground([("base",[])],ClingraphContext())
        ctl.solve(on_model=lambda m: fbs.append(Factbase.from_model(m)))
        if self._select_model is not None:
            for m in self._select_model:
                if m>=len(fbs):
                    raise ValueError(f"Invalid model number selected {m}")
            fbs = [f if i in self._select_model else None
                        for i, f in enumerate(fbs) ]

        graphs = compute_graphs(fbs, graphviz_type=self._type)
        graphs = [{'solution':graphs[0]['solution']}]
        write_arguments = {"directory": directory, "name_format": image_name}
        paths = render(
            graphs, format="png", engine=self._engine, view=False, **write_arguments
        )
        self._uifb.add_message("Download successful", f"Information saved in file {directory}/{image_name}.png", "success")
        



    
    def add_atom_instance_gen(self, predicate):
        """
        Policy: Adds an assumption and basically resets the rest of the application (reground) -
        finally it returns the udpated Json structure.
        This is updated to work with spread operators atoms like atom(1..5) or atom(a;b;c).
        It is designed for the instance generation, and might be easier with clingo parsing or something.
        """
        # for multiplicities and domains, this adds the simple attoms
        if predicate.startswith('multiplicity(') or predicate.startswith('dom(') or predicate.startswith('path('):
            if predicate.startswith('multiplicity('):
                split_index = 3
            else:
                split_index = 2

            if predicate.startswith('path('):
                predicate = ",".join(predicate.split(',')[:split_index] + [','.join(predicate.split(',')[split_index:]).replace('"',"")])
            else:
                predicate = ",".join(predicate.split(',')[:split_index] + [predicate.split(',')[split_index].replace('"',"")])
            base_string = ','.join(predicate.split(',')[:split_index])
            # 0..n
            if '..' in predicate:
                start = int(predicate.split(',')[split_index][:-1].split('..')[0])
                end = int(predicate.split(',')[split_index][:-1].split('..')[1])
                iterators = list(range(end + 1))[start:]
            # 1;3;5
            else:
                if base_string.startswith('path('):
                    iterators = ','.join(predicate.split(',')[split_index:])[:-1].split(';')    
                else:
                    iterators = predicate.split(',')[split_index][:-1].split(';')    
            
            for i in iterators:
                parsed_string = base_string + ',' + str(i) + ')'
                predicate_symbol = parse_term(parsed_string)
                if predicate_symbol not in self._atoms:
                    self._add_atom(predicate_symbol)
            self._init_ctl()
            self._ground()
            self._end_browsing()
            self._update_uifb()

        # for constraints, the operator need to be parsed with the "", and not without
        elif predicate.startswith('constraint('):
            predicate = ','.join(predicate.split(',')[:2]) + '"' + predicate.split(',')[2].split(')')[0] + '")'
            predicate_symbol = parse_term(predicate)
            if predicate_symbol not in self._atoms:
                self._add_atom(predicate_symbol)
            self._init_ctl()
            self._ground()
            self._end_browsing()
            self._update_uifb()
        else:
            predicate_symbol = parse_term(predicate)
            if predicate_symbol not in self._atoms:
                self._add_atom(predicate_symbol)
                self._init_ctl()
                self._ground()
                self._end_browsing()
                self._update_uifb()