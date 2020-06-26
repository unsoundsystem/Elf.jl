#!/bin/julia
using Elf

function main()
    isempty(ARGS) && error("No file specifed.")

    bin = read(ARGS[1])

    ehdr = Elf64_Ehdr(bin)

    !iself(ehdr) && error("Not an ELF binary.")

    !(elfclass(ehdr) == :x64) && error("Unknown class.")

    !(endian(ehdr) == :LittleEndian) && error("Unknown endian.")

    # Print Section Names
    println("Sections:")
    for (i, s) in enumerate(collect(sections(bin)))
        println("\t[$i]:\t$(s.first)")
    end
    println()

    # Print Segments Names
    println("Segments:")
    for (i, s) in enumerate(collect(segments(bin)))
        println("\t[$i]:\t$(s.first)")
    end

    # Print Symbols Names
    println("Symbols:")
    syms, rels = symbols(bin)

    for (i, s) in enumerate(collect(syms))
        println("\t[$i]:\t$(s.first)")
    end

    println()

    if isempty(rels)
        println("No relocations.")
    else
        println("Relocations:")
        for (i, s) in enumerate(collect(rels))
            println("\t[$i]:\t$(s.first)")
        end
    end
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
