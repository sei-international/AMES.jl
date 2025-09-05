using AMES
using Test

include("../src/AMESlib.jl")
using .AMESlib

curr_working_dir = pwd()
cd(@__DIR__)

@testset "AMESlib" begin
	# char_index_to_int
	@test AMESlib.char_index_to_int("W") == 23
	@test AMESlib.char_index_to_int("CB") == 80
	@test AMESlib.char_index_to_int("ABP") == 744

	# excel_ref_to_rowcol
	@test AMESlib.excel_ref_to_rowcol("A276") == [276,1]
	@test AMESlib.excel_ref_to_rowcol("AB5") == [5,28]
	@test AMESlib.excel_ref_to_rowcol("WM76") == [76,611]

	# haskeyvalue
	@test AMESlib.haskeyvalue(Dict("a" => 1, "b" => 2), "a")
	@test !AMESlib.haskeyvalue(Dict("a" => 1, "b" => 2), "c")
	@test !AMESlib.haskeyvalue(Dict("a" => nothing, "b" => 2), "a")
end

@testset "AMES.run" begin
	@test AMES.run("AMES_params.yml",
						dump_err_stack = true,
						continue_if_error = false,
						load_leap_first = false,
						include_energy_sectors = true,
						add_timestamp = true) == 0
	@test AMES.run("AMES_params.yml",
						dump_err_stack = true,
						continue_if_error = false,
						load_leap_first = false,
						include_energy_sectors = false,
						add_timestamp = true) == 0
	@test AMES.run("AMES_params_all_options.yml",
						dump_err_stack = true,
						continue_if_error = false,
						load_leap_first = false,
						include_energy_sectors = true,
						add_timestamp = true) == 0
	@test AMES.run("AMES_params_all_options.yml",
						dump_err_stack = true,
						continue_if_error = false,
						load_leap_first = false,
						include_energy_sectors = false,
						add_timestamp = true) == 0
	@test AMES.run("AMES_minimal_params.yml",
						dump_err_stack = true,
						continue_if_error = false,
						load_leap_first = false,
						include_energy_sectors = true,
						add_timestamp = true) == 0
	@test AMES.run("AMES_params_IO.yml",
						dump_err_stack = true,
						continue_if_error = false,
						load_leap_first = false,
						include_energy_sectors = true,
						add_timestamp = true) == 0
	@test AMES.run("AMES_params_IO.yml",
						dump_err_stack = true,
						continue_if_error = false,
						load_leap_first = false,
						include_energy_sectors = false,
						add_timestamp = true) == 0
	# @test AMES.run("AMES_params.yml",
	# 					dump_err_stack = true,
	# 					continue_if_error = false,
	# 					load_leap_first = true,
	# 					get_results_from_leap_version = "CALCULATED TEST",
	# 					only_push_leap_results = true,
	# 					include_energy_sectors = false,
	#					add_timestamp = true) == 0
end

cd(curr_working_dir)
