```@meta
CurrentModule = AMES
```

# [Running the AMES model](@id running-ames)
Once the configuration and external parameter files have been prepared, the AMES model can be run in a stand-alone mode without LEAP. If the LEAP model is also prepared, then AMES can be run from LEAP.

## Running AMES stand-alone
When running AMES multiple times -- for example, when calibrating -- it is best to work in Julia's command-line read-eval-print loop (the REPL). That way, the AMES library is only included once, which speeds up subsequent runs. Alternatively, AMES can be run stand-alone from the Windows Command Prompt, as explained below.

### Running from Julia's REPL
The only command needed is `AMES.run()`, which is defined as follows, with the default values indicated:
```julia
function run(config_file::AbstractString = "AMES_params.yml";
             dump_err_stack::Bool = false,
             include_energy_sectors::Bool = false,
             load_leap_first::Bool = false,
             get_results_from_leap_version::Union{Nothing,Integer,AbstractString} = nothing,
             only_push_leap_results::Bool = false,
             run_number_start::Integer = 0,
             continue_if_error::Bool = false)
```

The options are:
  * `config_file`: The name of the [configuration file](@ref config), if it is not `AMES_params.yml`;
  * `dump_err_stack`: Report detailed information about an error in the [log file](@ref model-outputs) (useful when debugging the AMES code, but not much use when debugging a model);
  * `include_energy_sectors`: Run the model with the [energy sectors](@ref config-sut) included (only useful in standalone mode, without LEAP, particularly when calibrating);
  * `load_leap_first`: Pull results from LEAP before running AMES (useful when LEAP has already been run and results are available);
  * `get_results_from_leap_version`: Specify the LEAP version, either by comment or number, from which to pull initial results (ignored if `load_leap_first = false`);
  * `only_push_leap_results`: Run AMES and push results to LEAP, but do not run LEAP;
  * `run_number_start`: Specify the first run number to use (default is 0);
  * `continue_if_error`: Try to continue if the linear goal program returns an error.

!!! info "When to use `continue_if_error`"
    The `continue_if_error` flag should ordinarily be set to `false`. When there is an error, the results cannot be trusted, and some reported outputs and all LEAP indices are set to `NaN` (Not a Number). Nevertheless, it has some use. It is most useful when running AMES many times using different inputs; for example, during an automated calibration or when running an ensemble of LEAP scenarios. In that case, setting the flag to `true` _may_ enable calculations to proceed even if one particular run gives an error. However, there is a chance that the program will halt anyway, if the error is too severe to recover from.

For example, each of the following is a valid call to the `run()` function:
```julia
AMES.run()
AMES.run("AMES_params_MyScenario.yml")
AMES.run(dump_err_stack = true)
AMES.run("AMES_params_Calibration.yml", include_energy_sectors = true)
```

If the `config_file` argument is not specified, then it is set equal to `AMES_params.yml`. If that is the name of the [configuration file](@ref config), then after [installing the AMES package](@ref installation), the model can be run by simply typing the following commands in the Julia REPL:
```
julia> import AMES

julia> AMES.run()
With configuration file 'AMES_params.yml':
AMES model run (0)...completed
0
```

### Running from the Windows Command Prompt
In some circumstances it can be helpful to specify options as command-line parameters and run AMES from the Windows Command Prompt. The ArgParse Julia package makes that relatively easy. Here is a sample script, which can be saved as `runleapames.jl`:
```julia
# script 'runleapames.jl'
using AMES
using ArgParse

function parse_commandline()
    argp = ArgParseSettings(autofix_names = true)
    @add_arg_table! argp begin
        "config-file"
            help = "name of the configuration file"
            arg_type = AbstractString
            default = "AMES_params.yml"
            required = false
        "--verbose-errors", "-v"
            help = "send detailed error message to log file"
            action = :store_true
        "--load-leap-first", "-l"
            help = "load results from LEAP before running AMES"
            action = :store_true
        "--use-leap-version", "-u"
            help = "If load-leap-first is set, pull results from this version"
        "--only-push-leap-results", "-p"
            help = "only push results to LEAP and do not run LEAP from AMES"
            action = :store_true
        "--init-run-number", "-r"
            help = "initial run number"
            arg_type = Int64
            default = 0
        "--include-energy-sectors", "-e"
            help = "include energy sectors in the model simulation"
            action = :store_true
        "--continue-if-error", "-c"
            help = "try to continue if the linear goal program returns an error"
            action = :store_true
    end

    return parse_args(argp)
end

parsed_args = parse_commandline()

AMES.run(parsed_args["config_file"],
              dump_err_stack = parsed_args["verbose_errors"],
              load_leap_first = parsed_args["load_leap_first"],
              get_results_from_leap_version = parsed_args["use_leap_version"], 
              only_push_leap_results = parsed_args["only_push_leap_results"],
              run_number_start = parsed_args["init_run_number"],
              include_energy_sectors = parsed_args["include_energy_sectors"],
              continue_if_error = parsed_args["continue_if_error"])
```
For example, if the configuration file as the the default filename, `AMES_params.yml`, then a call to the `runleapames.jl` script could look something like this:
```
D:\path\to\model> julia runleapames.jl -ve
```
In this case, AMES would report verbose errors in the log file, and would include energy sectors.

!!! tip "Speeding up AMES with a pre-compiled system image"
    If AMES will be run multiple times from the command line, execution can be speeded up by pre-compiling the AMES plugin. In the [sample files](assets/AMES.zip), there is a Windows batch file, `make_AMES_sysimage.bat`. Running this batch file (from the command line or by double-clicking) will generate a "system image" called `AMES-sysimage.so`. After running the batch file, put the system image in the folder where you want to run AMES and call Julia with an additional `sysimage` argument -- `julia --sysimage=AMES-sysimage.so ...` -- where `...` is the name of your script followed by any command-line arguments. E.g., the call to `runleapames.jl` in the example above would become
    ```
    D:\path\to\model> julia --sysimage=AMES-sysimage.so runleapames.jl -ve
    ```

## [Running AMES from LEAP](@id running-ames-from-LEAP)
The [Freedonia sample model](assets/AMES.zip) includes a Visual Basic script for running AMES from LEAP. Located in the `scripts` folder, and called `AMES_AMESModelCalc.vbs`, it can be placed in a LEAP Area folder and called from LEAP using LEAP's scripting feature. See the [quick start guide](@ref quick-start) for more information.

The Visual Basic script assumes that the AMES model files are in a folder called `AMES` and it calls a Julia file called `AMES-run.jl` in that folder. The version of the `AMES-run.jl` file distributed with the Freedonia sample model looks like this:
```julia
using AMES

curr_working_dir = pwd()
cd(@__DIR__)

println("Running Baseline...")
AMES.run()

cd(curr_working_dir)
```
The default `AMES-run.jl` file can be modified to run different configuration files.
