module Elf
using Base
using StaticArrays, DataStructures

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
    elfclass(ehdr::Elf64_Ehdr) -> EHClass

Detrmines ELF class(64bit or 32bit) if invalid class error will occur.
"""
function elfclass(ehdr::Elf64_Ehdr)
    try
        EHClass(ehdr.e_ident[EI_CLASS])
    catch
        error("Invalid class.")
    end
end

"""
    endian(ehdr::Elf64_Ehdr) -> EHEndian

Detrmines ELF binary endian. Returns enum represents endian. If invalid error will occur.
"""

function endian(ehdr::Elf64_Ehdr)
    try
        EHEndian(ehdr.e_ident[EI_DATA])
    catch
        error("Invalid endian.")
    end
end

"""
    elfversion(ehdr::Elf64_Ehdr) -> Symbol

If binary has valid ELF version, else error will occur.
"""

function elfversion(ehdr::Elf64_Ehdr)
    try
        ehdr.e_ident[EI_VERSION]
    catch
        error("Invalid ELF version.")
    end
end

function elfosabi(ehdr::Elf64_Ehdr)
    try
        (arch = EHOsAbi(ehdr.e_ident[EI_OSABI]), version = ehdr.e_ident[EI_OSABI])
    catch
        error("Invalid OS ABI")
    end
end

function elftype(ehdr::Elf64_Ehdr)
    try
        EHType(ehdr.e_type)
    catch
        error("Invalid ELF type.")
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
