module ELF
using Base

export Elf64_Ehdr, Elf64_Shdr, Elf64_Phdr, Elf64_Rel, Elf64_Rela, Elf64_Sym, IS_ELF, print_section, EI_CLASS, ELFCLASS64, EI_DATA, ELFDATA2MSB, SHT_NOBITS, SHT_SYMTAB, ELF64_ST_TYPE, SHT_REL, SHT_RELA, ELF64_R_SYM, read_name

const EI_CLASS = 5
const ELFCLASS64 = UInt8(2)
const EI_DATA = 6
const ELFDATA2MSB = 1
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

struct Elf64_Ehdr
	e_ident::Vector{UInt8}
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
	
	function Elf64_Ehdr(head::Vector{UInt8})
		new(head[1:16],
		    convert(UInt16, head[17:18]),
		    convert(UInt16, head[19:20]),
		    convert(UInt32, head[21:24]),
		    convert(UInt64, head[25:32]),
		    convert(UInt64, head[33:40]),
		    convert(UInt64, head[41:48]),
		    convert(UInt32, head[49:52]),
		    convert(UInt16, head[53:54]),
		    convert(UInt16, head[55:56]),
		    convert(UInt16, head[57:58]),
		    convert(UInt16, head[59:60]),
		    convert(UInt16, head[61:62]),
		    convert(UInt16, head[63:64]))
	end
end

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

	function Elf64_Shdr(head::Vector{UInt8}, off::UInt)
		N = head[off+1:off+64]
		new(convert(UInt32, N[1:4]),
		    convert(UInt32, N[5:8]),
		    convert(UInt64, N[9:16]),
		    convert(UInt64, N[17:24]),
		    convert(UInt64, N[25:32]),
		    convert(UInt64, N[33:40]),
		    convert(UInt32, N[41:44]),
		    convert(UInt32, N[45:48]),
		    convert(UInt64, N[49:56]),
		    convert(UInt64, N[57:64]))
	end
end

struct Elf64_Phdr
	p_type::Elf64_Word
	p_flags::Elf64_Word
	p_offset::Elf64_Off
	p_vaddr::Elf64_Addr
	p_paddr::Elf64_Addr
	p_filesz::Elf64_Xword
	p_memsz::Elf64_Xword
	p_align::Elf64_Xword

	function Elf64_Phdr(head::Vector{UInt8}, off::UInt)
		N = head[off+1:off+64]
		new(convert(UInt32, N[1:4]),
		    convert(UInt32, N[5:8]),
		    convert(UInt64, N[9:16]),
		    convert(UInt64, N[17:24]),
		    convert(UInt64, N[25:32]),
		    convert(UInt32, N[33:36]),
		    convert(UInt32, N[37:40]),
		    convert(UInt32, N[41:44]))
	end
end

struct Elf64_Sym
	st_name::Elf64_Word
	st_info::UInt8
	st_other::UInt8
	st_shndx::Elf64_Section
	st_value::Elf64_Addr
	st_size::Elf64_Xword

	function Elf64_Sym(head::Vector{UInt8}, off::UInt)
		N = head[off+1:off+24]
		new(convert(UInt32, N[1:4]),
		    N[6],
		    N[5],
		    convert(UInt16, N[7:8]),
		    convert(UInt64, N[9:16]),
		    convert(UInt64, N[17:24]))
	end
end

struct Elf64_Rel
	r_offset::Elf64_Addr
	r_info::Elf64_Xword
	
	function Elf64_Rel(head::Vector{UInt8}, off::UInt)
		N = head[off+1:off+16]
		new(convert(UInt64, N[1:8]),
		    convert(UInt64, N[9:16]))
	end
end

struct Elf64_Rela
	r_offset::Elf64_Addr
	r_info::Elf64_Xword
	r_addend::Elf64_Sxword
	function Elf64_Rela(head::Vector{UInt8}, off::UInt)
		N = head[off+1:off:24]
		new(byte_array2uint64(N[1:8]),
		    byte_array2uint64(N[9:16]),
		    Int64(byte_array2uint64(N[17:24])))
	end
end


function IS_ELF(ehdr::Elf64_Ehdr)
	return (ehdr.e_ident[EIMAG1] == ELFMAG1 &&
		ehdr.e_ident[EIMAG2] == ELFMAG2 &&
		ehdr.e_ident[EIMAG3] == ELFMAG3 &&
		ehdr.e_ident[EIMAG4] == ELFMAG4)
end

ELF64_ST_TYPE(val) = val & 0xf

ELF64_R_SYM(i) = i >>> 32

function convert(T::Type{UInt32}, N::Vector{UInt8})
	while length(N) % 4 != 0
		prepend!(N, 0x00)
	end
	return reinterpret(UInt32, N)[1]
end

# function byte_array2uint32(N::Vector{UInt8})	#UInt8 array to UInt32
	# while length(N) % 4 != 0
		# prepend!(N, 0x00)
	# end
	# return convert(UInt32, reinterpret(UInt32, N)[1])
# end
function convert(T::Type{UInt64}, N::Vector{UInt8})
	while length(N) % 8 != 0
		prepend!(N, 0x00)
	end
	return reinterpret(UInt64, N)[1]
end

# function byte_array2uint64(N::Vector{UInt8})	#UInt8 array to UInt64
	# while length(N) % 8 != 0
		# prepend!(N, 0x00)
	# end
	# return convert(UInt64, reinterpret(UInt64, N)[1])
# end
function convert(T::Type{UInt16}, N::Vector{UInt8})
	while length(N) % 2 != 0
		prepend!(N, 0x00)
	end
	return reinterpret(UInt16, N)[1]
end

# function byte_array2uint16(N::Vector{UInt8})	#UInt8 array to UInt16
	# while length(N) % 2 != 0
		# prepend!(N, 0x00)
	# end
	# return convert(UInt16, reinterpret(UInt16, N)[1])
# end

function read_name(head::Vector{UInt8}, off::UInt)
	isnull = false
	sname = ""
	while !isnull
		if head[off] == 0x00
			isnull = true
			continue
		end
		sname *= Char(head[off])
		off += 1
	end
	return sname
end

end # module
