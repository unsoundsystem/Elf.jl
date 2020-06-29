module Elf
using Base
using StaticArrays, DataStructures, Match

export iself, elfclass, endian, sections, segments, symbols, elfosabi
include("./constants.jl")
# include("./types.jl")

"""
    iself(bin) -> Bool

Verify ELF Header with Magic numbers

# Examples
```julia-repl
julia> iself(read("/path/to/binary"))
true
```

# Arguments
- `bin::Vector{UInt8}` : binary file to check.

"""
iself(ehdr::Elf64_Ehdr) = ehdr.e_ident[begin:4] == [ELFMAG1, ELFMAG2, ELFMAG3, ELFMAG4]

"""
    elfclass(ehdr::Elf64_Ehdr) -> Symbol

Detrmines ELF class(64bit or 32bit) if invalid error will occur. Return symbol :x64 or :x32.
"""
function elfclass(ehdr::Elf64_Ehdr)
    @match ehdr.e_ident[EI_CLASS] begin
        0 => error("Invalid class.")  # ELFCLASSNONE
        1 => :x32  # ELFCLASS32
        2 => :x64  # ELFCLASS64
        _ => error("Unexpected value.")
    end
end

function endian(ehdr::Elf64_Ehdr)
    @match ehdr.e_ident[EI_DATA] begin
        0 => error("Invalid data encoding.") # ELFDATANONE
        1 => :LittleEndian # ELFDATA2LSB
        2 => :BigEndian # ELFDATA2MSB
        _ => error("Unexpected value.")
    end
end

"""
    elfversion(ehdr::Elf64_Ehdr) -> :Current

If binary has valid ELF version, returns symbol :Current.
"""

function elfversion(ehdr::Elf64_Ehdr)
    @match ehdr.e_ident[EI_VERSION] begin
        0 => error("Invalid ELF version.")
        1 => :Current
    end
end

function elfosabi(ehdr::Elf64_Ehdr)
    arch = @match ehdr.e_ident[EI_OSABI] begin
        0 => :SystemV
        1 => :HP_UX
        2 => :NetBSD
        3 => :Linux
        6 => :Solaris
        7 => :AIX
        8 => :Irix
        9 => :FreeBSD
        10 => :TRU64
        11 => :Modesto
        12 => :OpenBSD
        64 => :ARM
        97 => :ARM_EABI
        255 => :Standalone
        _ => error("Unexpected architecture.")
    end

    (arch = arch, version = ehdr.e_ident[9])
end

function elftype(ehdr::Elf64_Ehdr)
    @match ehdr.e_type begin
        1 => :Rel
        2 => :Exec
        3 => :Dyn
        4 => :Core
        _ => error("Unknown ELF filetype.")
    end
end

"""
    sections(bin::Vector{UInt8}) -> OrderedDict{String,Elf64_Shdr}

Section header infomation. Returns dictoinary represents section name and its infomation ordered by section number.
"""
function sections(bin::Vector{UInt8})
    sections_info::OrderedDict{String,Elf64_Shdr} = OrderedDict()
    ehdr = Elf64_Ehdr(bin)
    shstr = Elf64_Shdr(bin, ehdr.e_shoff + ehdr.e_shentsize * ehdr.e_shstrndx)
    for i = 0:(ehdr.e_shnum - 1)
        shdr = Elf64_Shdr(bin, ehdr.e_shoff + ehdr.e_shentsize * i)
        sname = unsafe_string(pointer(bin, shstr.sh_offset + shdr.sh_name + 1))
        push!(sections_info, sname => shdr)
    end

    sections_info
end

"""
    segments(bin::Vector{UInt8} -> OrderedDict{String,Elf64_Phdr}

Program header infomation. Returns dictoinary represents segment name and its infomation ordered by segment number.
"""

function segments(bin::Vector{UInt8})
    ehdr = Elf64_Ehdr(bin)
    shstr = Elf64_Shdr(bin, ehdr.e_shoff + ehdr.e_shentsize * ehdr.e_shstrndx)
    segments_info::OrderedDict{String,Elf64_Phdr} = OrderedDict()

    for i = 0:(ehdr.e_phnum - 1)
        phdr = Elf64_Phdr(bin, ehdr.e_phoff + ehdr.e_phentsize * i)
        for j = 0:(ehdr.e_shnum - 1)
            shdr = Elf64_Shdr(bin, ehdr.e_shoff + ehdr.e_shentsize * j)
            size = shdr.sh_type != UInt32(SHT_NOBITS) ? shdr.sh_size : 0
            if shdr.sh_offset < phdr.p_offset
                continue
            end
            if shdr.sh_offset + size > phdr.p_offset + phdr.p_filesz
                continue
            end
            seg_name = unsafe_string(pointer(bin, shstr.sh_offset + shdr.sh_name + 1))
            push!(segments_info, seg_name => phdr)
        end
    end

    segments_info
end

"""
    symbols(bin::Vector{UInt8}) -> (OrderedDict{String,Elf64_Sym}, OrderedDict{String,Elf64_Rel})

ELF symbols in the file. Returns tuple of ELF symbols and relocatable symbols.

# Examples
```julia-repl
julia> symbols(read("/path/to/binary"))
(OrderedDict{String,Elf64_Sym}(...),OrderedDict{String,Elf64_Rel}())
```

# Arguments
- `bin::Vector{UInt8}`: ELF binary.
"""

function symbols(bin::Vector{UInt8})
    ehdr = Elf64_Ehdr(bin)
    symbols_info::OrderedDict{String,Elf64_Sym} = OrderedDict()
    str = sections(bin)[".strtab"]

    for i = 0:(ehdr.e_shnum - 1)
        shdr = Elf64_Shdr(bin, ehdr.e_shoff + ehdr.e_shentsize * i)
        if shdr.sh_type != UInt32(SHT_SYMTAB)
            continue
        end
        global sym = shdr
        for j = 0:(div(sym.sh_size, sym.sh_entsize) - 1)
            symp = Elf64_Sym(bin, sym.sh_offset + sym.sh_entsize * j)
            if symp.st_name == 0
                continue
            end
            push!(
                symbols_info,
                unsafe_string(pointer(bin, str.sh_offset + symp.st_name + 1)) => symp,
            )
        end
    end

    symbols_rel_info::OrderedDict{String,Elf64_Rel} = OrderedDict()

    for i = 0:(ehdr.e_shnum - 1)
        shdr = Elf64_Shdr(bin, ehdr.e_shoff + ehdr.e_shentsize * i)
        if shdr.sh_type != UInt32(SHT_REL) && shdr.sh_type != UInt32(SHT_RELA)
            continue
        end
        rel = shdr
        for j = 0:(div(rel.sh_size, rel.sh_entsize) - 1)
            relp = Elf64_Rel(bin, rel.sh_offset + rel.sh_entsize * j)
            symp =
                Elf64_Sym(bin, sym.sh_offset + (sym.sh_entsize * ELF64_R_SYM(relp.r_info)))
            if symp.st_name == 0
                continue
            end
            push!(
                symbols_rel_info,
                unsafe_string(pointer(bin, str.sh_offset + symp.st_name + 1)) => relp,
            )
        end
    end

    symbols_info, symbols_rel_info
end

end # module
