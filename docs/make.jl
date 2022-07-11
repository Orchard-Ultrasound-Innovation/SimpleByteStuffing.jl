using SimpleByteStuffing
using Documenter

DocMeta.setdocmeta!(SimpleByteStuffing, :DocTestSetup, :(using SimpleByteStuffing); recursive=true)

makedocs(;
    modules=[SimpleByteStuffing],
    authors="Morten F. Rasmussen <10264458+mofii@users.noreply.github.com> and contributors",
    repo="https://github.com/Orchard-Ultrasound-Innovation/SimpleByteStuffing.jl/blob/{commit}{path}#{line}",
    sitename="SimpleByteStuffing.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://Orchard-Ultrasound-Innovation.github.io/SimpleByteStuffing.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/Orchard-Ultrasound-Innovation/SimpleByteStuffing.jl",
    devbranch="main",
)
