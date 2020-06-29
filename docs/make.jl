using Elf
using Documenter

makedocs(;
    modules=[Elf],
    authors="sasuseso <sinai471530@gmail.com> and contributors",
    repo="https://github.com/sasuseso/Elf.jl/blob/{commit}{path}#L{line}",
    sitename="Elf.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://sasuseso.github.io/Elf.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/sasuseso/Elf.jl",
)
