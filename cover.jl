#!/usr/bin/env julia
using Coverage

if length(ARGS)!=1
    throw(ValueError(length(ARGS), "wrong number of arguments"))
end

c = Coverage.process_file(ARGS[1])
lines = split(c.source, '\n')
for (c,l) in zip(c.coverage, lines)
    if c==nothing
        print("-\t")
    elseif c==0
        print("0 ***\t")
    else
        print("$c\t")
    end
    println(l)
end
