#=
AMES: A macroeconomic model for LEAP

Authors:
  Eric Kemp-Benedict
  Jason Veysey
  Emily Ghosh
  Anisha Nazareth

Copyright ©2019-2022 Stockholm Environment Institute
=#

"Main module for `AMES.jl` -- a macroeconomic model for LEAP"
module AMES

using Logging, Dates, YAML, Formatting

include("./AMEScore.jl")
include("./AMESlib.jl")
using .AMEScore, .AMESlib

export run

"Run an AMES model as specified in `config_file`. If running from LEAP, set `include_energy_sectors` to `false` (the default)."
function run(config_file::AbstractString = "AMES_params.yml";
			 dump_err_stack::Bool = false,
			 include_energy_sectors::Bool = false,
			 load_leap_first::Bool = false,
			 get_results_from_leap_version::Union{Nothing,Integer,AbstractString} = nothing, # Only used if load_leap_first = true
			 only_push_leap_results::Bool = false,
			 run_number_start::Integer = 0,
			 continue_if_error::Bool = false)

	# Ensure needed folders exist
	if !isdir("inputs")
		throw(ErrorException(AMESlib.gettext("The \"inputs\" folder is needed, but does not exist")))
	end

	# First check that the configuration file loads correctly
	try
		YAML.load_file(config_file)
	catch err
		exit_status = 1
		if Sys.iswindows()
			eol_length = 2 # YAML mis-counts lines on Windows
		else
			eol_length = 1
		end
		println(format(AMESlib.gettext("Configuration file '{1}' did not load properly: {2} on line {3:d}"), config_file, err.problem, err.problem_mark.line ÷ eol_length))
		return(exit_status)
	end

	params = YAML.load_file(config_file)

	# Enable logging
	if include_energy_sectors
		logfilename = format("AMES_log_{1}_full.txt", params["output_folder"])
	else
		logfilename = format("AMES_log_{1}.txt", params["output_folder"])
	end
	if run_number_start == 0
		logfile = open(logfilename, "w")
	else
		logfile = open(logfilename, "a")
	end
	logger = ConsoleLogger(logfile)
	global_logger(logger)
	@info now()
	@info format(AMESlib.gettext("Configuration file: '{1}'"), config_file)
	exit_status = 0
	try
		AMEScore.leapmacro(config_file, logfile, include_energy_sectors, load_leap_first, get_results_from_leap_version, only_push_leap_results, run_number_start, continue_if_error)
	catch err
		exit_status = 1
		println(format(AMESlib.gettext("AMES exited with an error: Please check the log file '{1}'"), logfilename))
		@error err
		if dump_err_stack
			@error stacktrace(catch_backtrace())
		end
	finally
		@info now()
		close(logfile)
		return(exit_status)
	end
end # function run

end #module
