module Elf
using Base
using StaticArrays
using DataStructures

export Elf64_Ehdr,
    Elf64_Shdr,
    Elf64_Phdr,
    Elf64_Rel,
    Elf64_Rela,
    Elf64_Sym,
    print_section,
    EI_CLASS,
    ELFCLASS64,
    EI_DATA,
    ELFDATA2MSB,
    SHT_NOBITS,
    SHT_SYMTAB,
    ELF64_ST_TYPE,
    SHT_REL,
    SHT_RELA,
    ELF64_R_SYM,
    read_name,
    iself,
    isclass,
    isendian,
    sections,
    segments,
    symbols

const EI_CLASS = 5
const ELFCLASS64 = UInt8(2)
const EI_DATA = 6
const ELFDATA2MSB = UInt64(1)
const EV_CURRENT = 1
const ELFOSABI_GNU = 4
const ELFOSABI_LINUX = ELFOSABI_GNU
const Elf64_Word = UInt32
const Elf64_Sword = Int32
const Elf64_Xword = UInt64
const Elf64_Sxword = Int64
const Elf64_Half = UInt16
const Elf64_Addr = UInt64
const Elf64_Off = UInt64
const Elf64_Section = UInt16
const Elf64_Versym = Elf64_Half
const EI_NIDENT = 16
const EIMAG1 = 1
const ELFMAG1 = 0x7f
const EIMAG2 = 2
const ELFMAG2 = UInt8('E')
const EIMAG3 = 3
const ELFMAG3 = UInt8('L')
const EIMAG4 = 4
const ELFMAG4 = UInt8('F')
const SHT_NOBITS = 8
const SHT_SYMTAB = 2
const SHT_REL = 9
const SHT_RELA = 4

"""
    Elf64_Ehdr

A type represents 64bit ELF header.
"""
struct Elf64_Ehdr
    e_ident::SVector{16,UInt8}
    e_type::Elf64_Half
    e_machine::Elf64_Half
    e_version::Elf64_Word
    e_entry::Elf64_Addr
    e_phoff::Elf64_Off
    e_shoff::Elf64_Off
    e_flags::Elf64_Word
    e_ehsize::Elf64_Half
    e_phentsize::Elf64_Half
    e_phnum::Elf64_Half
    e_shentsize::Elf64_Half
    e_shnum::Elf64_Half
    e_shstrndx::Elf64_Half
end

Elf64_Ehdr(bin::Vector{UInt8}) = pointer(bin) |> Ptr{Elf64_Ehdr} |> unsafe_load

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

isclass(ehdr::Elf64_Ehdr, magic::UInt8) = ehdr.e_ident[EI_CLASS] == magic

isendian(ehdr::Elf64_Ehdr, endian::UInt64) = ehdr.e_ident[EI_DATA] == endian

"""
    Elf64_Shdr

A type represents 64bit ELF section header.
"""
struct Elf64_Shdr
    sh_name::Elf64_Word
    sh_type::Elf64_Word
    sh_flags::Elf64_Xword
    sh_addr::Elf64_Addr
    sh_offset::Elf64_Off
    sh_size::Elf64_Xword
    sh_link::Elf64_Word
    sh_info::Elf64_Word
    sh_addralign::Elf64_Xword
    sh_entsize::Elf64_Xword
end

Elf64_Shdr(bin::Vector{UInt8}, off::UInt) =
    pointer(bin, off + 1) |> Ptr{Elf64_Shdr} |> unsafe_load

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
    Elf64_Phdr

A type represents 64bit ELF program header.
"""
struct Elf64_Phdr
    p_type::Elf64_Word
    p_flags::Elf64_Word
    p_offset::Elf64_Off
    p_vaddr::Elf64_Addr
    p_paddr::Elf64_Addr
    p_filesz::Elf64_Xword
    p_memsz::Elf64_Xword
    p_align::Elf64_Xword
end

Elf64_Phdr(bin::Vector{UInt8}, off::UInt) =
    pointer(bin, off + 1) |> Ptr{Elf64_Phdr} |> unsafe_load

function segments(bin::Vector{UInt8})
    ehdr = Elf64_Ehdr(bin)
    shstr = Elf64_Shdr(bin, ehdr.e_shoff + ehdr.e_shentsize * ehdr.e_shstrndx)
    segments_info::OrderedDict{String,Elf64_Phdr} = OrderedDict()

    for i = 0:(ehdr.e_phnum - 1)
        phdr = Elf64_Phdr(bin, ehdr.e_phoff + ehdr.e_phentsize * i)
        for j = 0:(ehdr.e_shnum - 1)
            shdr = Elf64_Shdr(bin, ehdr.e_shoff + ehdr.e_shentsize * j)
            size = shdr.sh_type != SHT_NOBITS ? shdr.sh_size : 0
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
    Elf64_Sym

A type represents 64bit ELF Symbol Table entry.
"""
struct Elf64_Sym
    st_name::Elf64_Word
    st_info::UInt8
    st_other::UInt8
    st_shndx::Elf64_Section
    st_value::Elf64_Addr
    st_size::Elf64_Xword
end

Elf64_Sym(bin::Vector{UInt8}, off::UInt) =
    pointer(bin, off + 1) |> Ptr{Elf64_Sym} |> unsafe_load


"""
    symbols(bin::Vector{UInt8}) -> (OrderedDict{String,Elf64_Sym}, OrderedDict{String,Elf64_Rel})

Returns ELF symbols in the file.

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
        if shdr.sh_type != SHT_SYMTAB
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
        if shdr.sh_type != SHT_REL && shdr.sh_type != SHT_RELA
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


"""
    Elf64_Rel

A type represents 64bit ELF relocatable symbol.
"""
struct Elf64_Rel
    r_offset::Elf64_Addr
    r_info::Elf64_Xword
end

Elf64_Rel(bin::Vector{UInt8}, off::UInt) =
    pointer(bin, off + 1) |> Ptr{Elf64_Rel} |> unsafe_load
# struct Elf64_Rela
# r_offset::Elf64_Addr
# r_info::Elf64_Xword
# r_addend::Elf64_Sxword
# function Elf64_Rela(head::Vector{UInt8}, off::UInt)
# N = head[off+1:off:24]
# new(byte_array2uint64(N[1:8]),
# byte_array2uint64(N[9:16]),
# Int64(byte_array2uint64(N[17:24])))
# end
# end

ELF64_ST_TYPE(val) = val & 0xf

ELF64_R_SYM(i) = i >>> 32

end # module
