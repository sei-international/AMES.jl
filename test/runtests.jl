using AMES
using Test

curr_working_dir = pwd()
cd(@__DIR__)

@testset "AMES.run" begin
	@test AMES.run("AMES_params.yml",
						dump_err_stack = true,
						continue_if_error = false,
						load_leap_first = false,
						include_energy_sectors = true) == 0
	# @test AMES.run("AMES_params.yml",
	# 					dump_err_stack = true,
	# 					continue_if_error = false,
	# 					load_leap_first = false,
	# 					include_energy_sectors = false) == 0
	# @test AMES.run("AMES_params_all_options.yml",
	# 					dump_err_stack = true,
	# 					continue_if_error = false,
	# 					load_leap_first = false,
	# 					include_energy_sectors = true) == 0
	# @test AMES.run("AMES_params_all_options.yml",
	# 					dump_err_stack = true,
	# 					continue_if_error = false,
	# 					load_leap_first = false,
	# 					include_energy_sectors = false) == 0
	# @test AMES.run("AMES_minimal_params.yml",
	# 					dump_err_stack = true,
	# 					continue_if_error = false,
	# 					load_leap_first = false,
	# 					include_energy_sectors = true) == 0
	# @test AMES.run("AMES_params.yml",
	# 					dump_err_stack = true,
	# 					continue_if_error = false,
	# 					load_leap_first = true,
	# 					get_results_from_leap_version = "CALCULATED TEST",
	# 					only_push_leap_results = true,
	# 					include_energy_sectors = false) == 0
end

cd(curr_working_dir)
