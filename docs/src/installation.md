```@meta
CurrentModule = AMES
```
# [Installing AMES](@id installation)

AMES is installed via GitHub. You must first have a working [Julia](https://julialang.org/downloads/) installation on your computer. **The AMES team has verified AMES's compatibility with Julia 1.9; other versions of Julia may not work correctly.**

Once Julia is set up, start a Julia session and add the AMES package (named `AMES`). Once Julia is started, press the `]` key to open up the package manager, and then add AMES.jl from GitHub:
```
julia> ]

pkg> add https://github.com/sei-international/AMES.jl
```

To update to the newest code after AMES is installed, use `update`:
```
julia> ]

pkg> update AMES
```
