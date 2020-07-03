export Elf64_Ehdr,
    Elf64_Shdr,
    Elf64_Phdr,
    Elf64_Rel,
    Elf64_Rela,
    Elf64_Sym,
    ELF64_ST_TYPE,
    ELF64_R_SYM,
    Elf64_Chdr,
    Elf64_Dyn

const Elf64_Word = UInt32
const Elf64_Sword = Int32
const Elf64_Xword = UInt64
const Elf64_Sxword = Int64
const Elf64_Half = UInt16
const Elf64_Addr = UInt64
const Elf64_Off = UInt64
const Elf64_Section = UInt16
const Elf64_Versym = Elf64_Half

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
Elf64_Ehdr(bin::Vector{UInt8}, off::UInt) = pointer(bin, off) |> Ptr{Elf64_Ehdr} |> unsafe_load


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

st_info_bind(st_info::UInt8) = st_info >>> 4
st_info_type(st_info::UInt8) = st_info & 0xf
st_info_info(bind::UInt8, type::UInt8) = ((bind << 4) + (type & 0xf))

st_visibility(st_other::UInt8) = st_other & 0x3

struct Elf64_SymInfo
    si_boundto::Elf64_Half
    si_flags::Elf64_Half
end

Elf64_SymInfo(bin::Vector{UInt8}, off::UInt8) =
    pointer(bin, off + 1) |> Ptr{Elf64_SymInfo} |> unsafe_load

"""
    Elf64_Rel

A type represents 64bit ELF relocasion table entry (SHT_REL).
"""
struct Elf64_Rel
    r_offset::Elf64_Addr
    r_info::Elf64_Xword
end

Elf64_Rel(bin::Vector{UInt8}, off::UInt) =
    pointer(bin, off + 1) |> Ptr{Elf64_Rel} |> unsafe_load

"""
    Elf64_Rela

A type represents 64bit ELF relocasion table entry (SHT_RELA).
"""
struct Elf64_Rela
    r_offset::Elf64_Addr
    r_info::Elf64_Xword
    r_addend::Elf64_Sxword
end

Elf64_Rela(bin::Vector{UInt8}, off::UInt) =
    pointer(bin, off + 1) |> Ptr{Elf64_Rela} |> unsafe_load


# struct SymbolTable64
    # syms::Vector{Union{Elf64_Rel, Elf64_Rela}}

    # function SymbolTable64(relsec::Elf64_Shdr)
        # for i=
# end

struct Elf64_Chdr
    ch_type::Elf64_Word # Compression format.
    ch_size::Elf64_Word # Uncompressed size.
    ch_addralign::Elf64_Xword # Uncompressed data alignment.
end

Elf64_Chdr(bin::Vector{UInt8}, off::UInt) = pointer(bin, off + 1) |> Ptr{Elf64_Chdr} |> unsafe_load

struct Elf64_Dyn
    d_tag::Elf64_Xword
    d_val_or_ptr::UInt64
end

Elf64_Dyn(bin::Vector{UInt8}, off::UInt) = pointer(bin, off + 1) |> Ptr{Elf64_Dyn} |> unsafe_load
