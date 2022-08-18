module LEAPfunctions
using DelimitedFiles, PyCall, DataFrames, CSV

export hide_leap, send_results_to_leap, calculate_leap, get_results_from_leap, LEAPresults

"Values passed from LEAP to Macro"
mutable struct LEAPresults
    I_en::Array{Any,1} # Investment in the energy sector x year
end

"Return a LEAPresults struct initialized to zero"
function initialize_leapresults(params::Dict)
    return LEAPresults(
        zeros(1 + (params["years"]["end"] - params["years"]["start"])) # I_en
    )
end # initialize_leapresults

"Hide or show LEAP by setting visibility."
function hide_leap(state::Bool)
	LEAP = connect_to_leap()
	LEAP.Visible = !state
	disconnect_from_leap(LEAP)
end # hide_leap

"First obtain LEAP branch info from `params` and then send Macro model results to LEAP."
function send_results_to_leap(params::Dict, indices::Array)
    base_year = params["years"]["start"]
    final_year = params["years"]["end"]

    # connects program to LEAP
    LEAP = connect_to_leap()

    # Set ActiveView
    LEAP.ActiveView = "Analysis"

	branch_data = Dict(:branch => String[], :variable => String[], :last_historical_year => Int64[], :col => Int64[])
	col = 0
    if haskey(params, "GDP-branch")
        col += 1
        append!(branch_data[:branch], [params["GDP-branch"]["branch"]])
        append!(branch_data[:variable], [params["GDP-branch"]["variable"]])
        append!(branch_data[:last_historical_year], [params["LEAP-info"]["last_historical_year"]])
        append!(branch_data[:col], [col])
    end
    if haskey(params, "Employment-branch")
        col += 1
        append!(branch_data[:branch], [params["Employment-branch"]["branch"]])
        append!(branch_data[:variable], [params["Employment-branch"]["variable"]])
        append!(branch_data[:last_historical_year], [params["LEAP-info"]["last_historical_year"]])
        append!(branch_data[:col], [col])
    end

	for leap_sector in params["LEAP-sectors"]
		col += 1
		for branch in leap_sector["branches"]
			append!(branch_data[:branch], [branch["branch"]])
			append!(branch_data[:variable], [branch["variable"]])
			append!(branch_data[:last_historical_year], [params["LEAP-info"]["last_historical_year"]])
			append!(branch_data[:col], [col])
		end
	end

	branch_df = DataFrame(branch_data)

    # send results to LEAP
    ndxrows = final_year - base_year + 1
    try
        for i = axes(branch_df, 1) # loops through each branch path
            branch = branch_df[i,:branch]
            variable = branch_df[i,:variable]
            lasthistoricalyear = branch_df[i,:last_historical_year]
            col = branch_df[i,:col]
            start_ndx = (1+(col*ndxrows))
            end_ndx = (col+1)*ndxrows

            if lasthistoricalyear > base_year
                newexpression = interp_expression(base_year, indices[start_ndx:end_ndx], lasthistoricalyear=lasthistoricalyear)
            else
                newexpression = interp_expression(base_year, indices[start_ndx:end_ndx])
            end
            setbranchvar_expression(LEAP, branch, variable, newexpression, region = params["LEAP-info"]["region"], scenario=params["LEAP-info"]["input_scenario"])

        end
        LEAP.SaveArea()
    finally
	    disconnect_from_leap(LEAP)
    end
end # send_results_to_leap

"""
Connect to the currently running instance of LEAP, if one exists; otherwise starts an instance of LEAP.

Return a `PyObject` corresponding to the instance.
If LEAP cannot be started, return `missing`
"""
function connect_to_leap()
	try
		LEAPPyObj = pyimport("win32com.client").Dispatch("Leap.LEAPApplication")
        max_loops = 5
        while !LEAPPyObj.ProgramStarted & max_loops > 0
            sleep(5)
            max_loops -= 1
        end
        if !LEAPPyObj.ProgramStarted
            error("LEAP is not responding.")
            return missing
        else
            return LEAPPyObj
        end
	catch
        error("Cannot connect to LEAP. Is it installed?")
		return missing
	end
end  # connect_to_leap

"Repeatedly call PyCall's `pydecref(obj)` until null"
function disconnect_from_leap(LEAPPyObj)
    while !ispynull(LEAPPyObj)
    	pydecref(LEAPPyObj)
    end
end # disconnect_from_leap

"Create LEAP Interp expression from an array of values."
function interp_expression(base_year::Integer, newdata::Array; lasthistoricalyear::Integer=0)
    # Creates start of expression. Includes historical data if available
    if lasthistoricalyear > 0
        newexpression = string("If(year <= ", lasthistoricalyear, ", ScenarioValue(Current Accounts), Value(", base_year,") * Interp(")
        diff = lasthistoricalyear - base_year + 2
        year = lasthistoricalyear + 1
    else
        newexpression = string("(Value(", base_year,") * Interp(")
        diff = 2
        year = base_year + 1
    end

    # Incorporates Macro results into the rest of the expression
    for i = diff:size(newdata,1)
        if isnan(newdata[i]) == false
            newexpression = string(newexpression, year, ", ", newdata[i], ", ")
        end
        if i == size(newdata,1)
            newexpression = newexpression[1:(lastindex(newexpression)-2)]
            newexpression = string(newexpression, "))")
        end
        year = year + 1
    end
    return newexpression
end # interp_expression

"""
Set a LEAP branch-variable expression.

The region and scenario arguments can be omitted by leaving them as empty strings.
Note that performance is best if neither region nor scenario is specified.
"""
function setbranchvar_expression(leapapplication::PyObject, branch::AbstractString, variable::AbstractString, newexpression::AbstractString; region::AbstractString = "", scenario::AbstractString = "")
    # Set ActiveRegion and ActiveScenario as Julia doesn't allow a function call (ExpressionRS) to be set to a value
    if region != ""
        leapapplication.ActiveRegion = region
    end

    if scenario != ""
        leapapplication.ActiveScenario = scenario
    end

    # Set expression
    leapapplication.Branch(branch).Variable(variable).Expression = newexpression

    # Refresh LEAP display
    leapapplication.Refresh()
end  # setbranchvarexpression

"Calculate the LEAP model, returning results for the specified scenario."
function calculate_leap(scen_name::AbstractString)
    # connects program to LEAP
    LEAP = connect_to_leap()
    try
        LEAP.Scenario(scen_name).ResultsShown = true
        LEAP.Calculate()
        LEAP.SaveArea()
    finally
	    disconnect_from_leap(LEAP)
    end
end # calculate_leap

"Obtain energy investment data from the LEAP model."
function get_results_from_leap(params::Dict, run::Integer)
    base_year = params["years"]["start"]
    final_year = params["years"]["end"]

    # connects program to LEAP
    LEAP = connect_to_leap()

    # Set ActiveView and ActiveScenario
    LEAP.ActiveView = "Results"
    LEAP.ActiveScenario = params["LEAP-info"]["result_scenario"]

    leapvals = initialize_leapresults(params) # Initialize to zero
    nrows = (final_year - base_year) + 1
    I_en_temp = Array{Float64}(undef, nrows)

    try
        for b in LEAP.Branches
            if b.BranchType == 2 && b.Level == 2 && b.VariableExists("Investment Costs")
                for y = base_year:final_year
                    I_en_temp[(y-base_year+1)] = b.Variable("Investment Costs").Value(y, params["LEAP-info"]["inv_costs_unit"]) / params["LEAP-info"]["inv_costs_scale"]
                end
                leapvals.I_en += I_en_temp
            end
        end
    finally
    	disconnect_from_leap(LEAP)
    end

    writedlm(joinpath(params["results_path"],string("I_en_",run,".csv")), leapvals.I_en, ',')

    return leapvals
end # get_results_from_leap

end # LEAPfunctions
