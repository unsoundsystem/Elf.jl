#!/bin/julia
using Elf

function main()
    isempty(ARGS) && error("No file specifed.")

    bin = read(ARGS[1])

    ehdr = Elf64_Ehdr(bin)

    !iself(ehdr) && error("Not an ELF binary.")

    !(elfclass(ehdr) == ELFCLASS64) && error("Unknown class.")

    !(endian(ehdr) == ELFDATA2MSB) && error("Unknown endian.")

    # Print ELF file type
    println("ELF Type: $(elftype(ehdr))")

    # Print Section Names
    println("Sections:")
    for (i, s) in enumerate(collect(sections(bin)))
        println("\t[$i]:\t\"$(s.first)\"$(" " ^ (25 - length(s.first)))type: $(SHType(s.second.sh_type))")
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
        println("\t[$i]:\t\"$(s.first)\"$(" " ^ (50 - length(s.first)))type: $(elf64_st_type(s.second.st_info))")
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
