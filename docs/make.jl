using XNumbers
using Documenter

DocMeta.setdocmeta!(XNumbers, :DocTestSetup, :(using XNumbers); recursive=true)

makedocs(;
    modules=[XNumbers],
    authors="Michael Boyle <michael.oliver.boyle@gmail.com> and contributors",
    repo="https://github.com/moble/XNumbers.jl/blob/{commit}{path}#{line}",
    sitename="XNumbers.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://moble.github.io/XNumbers.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/moble/XNumbers.jl",
    devbranch="main",
)
