const EI_CLASS = 5
const ELFCLASS64 = UInt8(2)
const EI_DATA = 6
const ELFDATA2MSB = 1
const EV_CURRENT = 1
const ELFOSABI_GNU = 4
const ELFOSABI_LINUX = ELFOSABI_GNU
const Elf64_Word = UInt32
const Elf64_Sword = UInt32
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
struct Elf64_Ehdr
	e_ident::Array{UInt8, 1}
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
	
	function Elf64_Ehdr(head::Array{UInt8, 1})
		eid = head[1:16]
		ety = byte_array2uint16(head[17:18])
		ema = byte_array2uint16(head[19:20])
		eve = byte_array2uint32(head[21:24])
		een = byte_array2uint64(head[25:32])
		eph = byte_array2uint64(head[33:40])
		esh = byte_array2uint64(head[41:48])
		efl = byte_array2uint32(head[49:52])
		eeh = byte_array2uint16(head[53:54])
		ephe = byte_array2uint16(head[55:56])
		ephn = byte_array2uint16(head[57:58])
		eshe = byte_array2uint16(head[59:60])
		eshnu = byte_array2uint16(head[61:62])
		eshs = byte_array2uint16(head[63:64])
		new(eid, ety, ema, eve, een, eph, esh,
		    efl, eeh, ephe, ephn, eshe, eshnu, eshs)
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
	function Elf64_Shdr(head::Array{UInt8, 1})
		new(byte_array2uint32(head[1:4]),
		    byte_array2uint32(head[5:8]),
		    byte_array2uint64(head[9:16]),
		    byte_array2uint64(head[17:24]),
		    byte_array2uint64(head[25:32]),
		    byte_array2uint64(head[33:40]),
		    byte_array2uint32(head[41:44]),
		    byte_array2uint32(head[45:48]),
		    byte_array2uint64(head[49:56]),
		    byte_array2uint64(head[57:64]))
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
end

struct Elf64_Sym
	st_name::Elf64_Word
	st_info::Cuchar
	st_other::Cuchar
	st_shndx::Elf64_Section
	st_value::Elf64_Addr
	st_size::Elf64_Xword
end

struct Elf64_Rel
	r_offset::Elf64_Addr
	r_info::Elf64_Xword
end

struct Elf64_Rela
	r_offset::Elf64_Addr
	r_info::Elf64_Xword
	r_addend::Elf64_Sxword
end

function IS_ELF(ehdr::Elf64_Ehdr)
	return (ehdr.e_ident[EIMAG1] == ELFMAG1 &&
		ehdr.e_ident[EIMAG2] == ELFMAG2 &&
		ehdr.e_ident[EIMAG3] == ELFMAG3 &&
		ehdr.e_ident[EIMAG4] == ELFMAG4)
end

function uint_convert(n::UInt32)	#UInt32をUInt8の配列に変える
	N::Array{UInt8, 1} = []
	for i in 0:3
		push!(N, convert(UInt8, (n >>> 8i) & 0xff))
	end
	return N[end:-1:1]
end

function uint_convert(n::UInt64)	#UInt64をUInt8の配列に変える
	N::Array{UInt8, 1} = []
	for i in 0:7
		push!(N, convert(UInt8, (n >>> 8i) & 0xff))
	end
	return N[end:-1:1]
end

function uint_convert(n::UInt16)	#UInt16をUInt8の配列に変える
	N::Array{UInt8, 1} = []
	push!(N, convert(UInt8, n & 0xff))
	push!(N, convert(UInt8, (n >>> 8) & 0xff))
	return N[end:-1:1]
end

function byte_array2uint32(A::Array{UInt8, 1})	#UInt8の配列をUInt32に変える
	N = A #[end:-1:1]
	while length(N) % 4 != 0
		prepend!(N, 0x00)
	end
	return convert(UInt32, reinterpret(UInt32, N)[1])
end

function byte_array2uint64(A::Array{UInt8, 1})	#UInt8の配列をUInt64に変える
	N = A #[end:-1:1]
	while length(N) % 8 != 0
		prepend!(N, 0x00)
	end
	return convert(UInt64, reinterpret(UInt64, N)[1])
end

function byte_array2uint16(A::Array{UInt8, 1})	#UInt8の配列をUInt16に変える
	N = A #[end:-1:1]
	while length(N) % 2 != 0
		prepend!(N, 0x00)
	end
	return convert(UInt16, reinterpret(UInt16, N)[1])
end

function print_section(A::Array{UInt8, 1}, off, num::Int64)
	for i in 0:num
		isnull = false
		while !isnull
			if A[off] == 0x00
				print("\n")
				isnull = true
			end
			print(Char(A[off]))
			off += 1
		end
	end
end

function main()
	file = read(ARGS[1])
	ehdr = Elf64_Ehdr(file)
	x = ehdr.e_shoff+ehdr.e_shentsize*ehdr.e_shstrndx
	shstr = Elf64_Shdr(file[x+1:x+64])
	x1 = ehdr.e_shoff+ehdr.e_shentsize
	shdr = Elf64_Shdr(file[x1+1:x1+64])
	x2 = shstr.sh_offset + shdr.sh_name
	print_section(file, x2+1, Int(ehdr.e_shnum))
end

main()
