#!/usr/bin/env julia
using Coverage, Formatting

c = vcat(Coverage.process_folder.(ARGS)...)

function get_stat(file)
    runs = filter(x -> x!=nothing, file.coverage)
    return (count(runs.==0), count(runs.!=0), file.filename)
end


subdirs = Dict{Vector{String}, Tuple{Int, Int, Set{String}}}()

function add_subdir(bad, good, subpath, child)
    x = (0,0,Set{String}())

    if haskey(subdirs, subpath)
        x = subdirs[subpath]
    end

    obad,ogood,ochild=x

    subdirs[subpath] = (obad+bad, ogood+good, 
        child == nothing ? ochild : union(ochild, [child]))
end

for f in c
    bad, good, fn = get_stat(f)
    path = splitpath(fn)
    for i in 1:length(path)
        add_subdir(bad,good,path[1:i-1], path[i])
    end
    add_subdir(bad,good,path, nothing)
end

ks = sort([k for k in keys(subdirs)])

# TODO: check if the terminal supports colors
normal = Base.text_colors[:normal]
bold = Base.text_colors[:bold]
green = Base.text_colors[:green]
red = Base.text_colors[:red]
cyan = Base.text_colors[:cyan]

function fbad(n)
    if n>0
        red * format(n; width=8) * normal
    else
        " "^8
    end
end

function ftot(n)
    format(n; width=8)
end

function fgood(n)
    if n>0
        green * format(n; width=8) * normal
    else
        " "^8
    end
end

function fperc(bad,good)
    total = bad + good
    if total == 0
        " "^8
    else
        ratio = good/total
        col=Base.text_colors[:white]
        if ratio<0.4
            col=Base.text_colors[:red]
        elseif ratio<0.7
            col=Base.text_colors[:light_red]
        elseif ratio<0.85
            col=Base.text_colors[:yellow]
        elseif ratio<0.92
            col=Base.text_colors[:light_yellow]
        elseif ratio<0.96
            col=Base.text_colors[:green]
        elseif ratio<1
            col=Base.text_colors[:light_green]
        end
            
        col * format(100*ratio; width=7, suffix="%", precision=2) * normal
    end
end

for k in ks
    bad, good, uc = subdirs[k]
    name = isempty(k) ?
        bold * "(TOTAL)" * normal :
        joinpath(vcat(k[1:length(k)-1], [cyan * k[length(k)] * normal])...)
    println("$(fbad(bad))$(ftot(bad+good))$(fgood(good))$(fperc(bad,good)) $name")
end

