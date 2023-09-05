julia -e "using Pkg; Pkg.add(\"PackageCompiler\")"
julia --trace-compile=AMES_precompile.jl AMES-run.jl
julia -e "using PackageCompiler; PackageCompiler.create_sysimage([\"AMES\"]; sysimage_path=\"AMES-sysimage.so\", precompile_statements_file=\"AMES_precompile.jl\")"
