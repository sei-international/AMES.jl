using AMES

curr_working_dir = pwd()
cd(@__DIR__)

println("Running Baseline...")
AMES.run()

cd(curr_working_dir)
