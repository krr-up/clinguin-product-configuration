# Interactive product configuration

This repository contains an interactive product configuration application, built on top of clinguin and Answer Set Programming (ASP). 
The App consists of two parts:
1. the interactive creation of a production domain.
2. the interactive configuration of a product from such a product domain.

Clinguin is a framework built on top of clingo and its multi-shot colving capabilities, that can be extended with custom behavior.
More on clinguin can be found in its [main repo in the web branch](https://github.com/potassco/clinguin/tree/web_sus).

In this repo, i built a custom backend under `/backends/product_config_backend.py` and a custom frontend under `/frontends`.

## Backend

The backend consists of only one python script, inheriting from the standard Clingraph backend.

## Frontend

The UI for the product domain creation (`frontends/configuration_instance/`) needs to be differentiated from the configuration of a specific product (`frontends/configuration/`).

Each of these directories contains one or multiple of the following:
- `ui.lp`: defines the components and their layout of the website in ASP logic.
- `encoding.lp`: contains the domain logic as an ASP program
- `viz.lp`: defines one or multiple clingraph representation, that are displayed in the website.


## How to use it:

1. Make a virtual environment (optional) 
2. Install the requirements, including clinguin
3. build and prepare clinguin and the angular frontend
4. Run clinguin with the custom backend and UI definitions from this repo


**Step 1:**
```shell
conda create --name clinguin_product_configuration
```


**Step 2:**
```shell
pip install -r requirements.txt
```


**Step 3:**
This step currently needs some manual assistance.

Move into the clinguin codebase in your virtual environment.
Then execute these two commands to build the Angular application:
```
pushd angular_frontend/; ng build; popd
mv angular_frontend/dist/clinguin_angular_frontend clinguin/client/presentation/frontends/angular_frontend
```

Depending on you setup you might have to move this build into this repo under `/clinguin`.


**Step 4:**
### Configuration of a product domain

Run this command for the product domain generation:

```shell
clinguin client-server --custom-classes "./backends" --backend=ProductConfigBackend --domain-files frontends/configuration_instance/encoding.lp --ui-files frontends/configuration_instance/ui.lp  --clingraph-files frontends/configuration_instance/viz.lp --include-menu-bar --disable-saved-to-file --ignore-unsat-msg --server-port 8000 --frontend AngularFrontend --client-port 8080
```

### Configuration of a product

Run the following command for the product configuration of a travel bike.

```shell
clinguin client-server --custom-classes "./backends" --backend=ProductConfigBackend --domain-files examples/travel_bike_2/instance_translated.lp frontends/configuration/encoding.lp --ui-files frontends/configuration/ui.lp  --clingraph-files frontends/configuration/viz_instance.lp frontends/configuration/viz_solution.lp --include-menu-bar --assumption-signature=constraint,2 --disable-saved-to-file --ignore-unsat-msg --server-port 8001 --frontend AngularFrontend --client-port 8081
```

There are other examples in the directory `/examples`, which can be used by simply changing the first argument under `--domain-files` from ` examples/travel_bike_2/instance_translated.lp` to `examples/kids_bike/instance_translated.lp`


## weird bugs:
- when booting up the app, the first argument of @concat() was systematically ignored. this didn't happen before and might not happen on other machines (fixed this by adding an empty string infront)


# ToDo:
- the ui contains a custom version of '_clinguin_browsing', using an atom "recommendation". This should be removed for '_clinguin_browsing'.