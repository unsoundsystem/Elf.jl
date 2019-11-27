module Elfdump64
include("../src/ELF.jl")
function elfdump(head::Array{UInt8, 1})
	ehdr = Elf64_Ehdr(head)

	if !IS_ELF(ehdr)
		error("This is not an ELF file")
	end

	if ehdr.e_ident[EI_CLASS] != ELFCLASS64
		error("Unknown class.", Int(ehdr.e_ident[EI_CLASS]))
	end

	if ehdr.e_ident[EI_DATA] != ELFDATA2MSB
		error("Unknown endian.", Int(ehdr.e_ident[EI_DATA]))
	end

	shstr = Elf64_Shdr(head, ehdr.e_shoff+ehdr.e_shentsize*ehdr.e_shstrndx)

	#セクション名を一覧表示
	println("Sections:")
	for i in 0:ehdr.e_shnum-1
		shdr = Elf64_Shdr(head, ehdr.e_shoff+ehdr.e_shentsize*i)
		sname = read_name(head, shstr.sh_offset + shdr.sh_name + 1)
		if sname == ".strtab" global str = shdr end
		println("\t[$i]\t$sname")
	end
	println()

	#セグメント一覧
	println("Segments:")
	for i in 0:ehdr.e_phnum-1
		phdr = Elf64_Phdr(head, ehdr.e_phoff + ehdr.e_phentsize * i)
		println("\t[$i]\t")
		for j in 0:ehdr.e_shnum-1
			shdr = Elf64_Shdr(head, ehdr.e_shoff + ehdr.e_shentsize * j)
			size = shdr.sh_type != SHT_NOBITS ? shdr.sh_size : 0
			if shdr.sh_offset < phdr.p_offset continue end
			if shdr.sh_offset + size  > phdr.p_offset + phdr.p_filesz continue end
			println("\t", read_name(head, shstr.sh_offset + shdr.sh_name + 1))
		end
	end
	println()

	# #シンボル名一覧表示
	println("Symbols:")
	for i in 0:ehdr.e_shnum-1
		shdr = Elf64_Shdr(head, ehdr.e_shoff + ehdr.e_shentsize * i);
		if shdr.sh_type != SHT_SYMTAB continue end
		global sym = shdr
		for j in 0:div(sym.sh_size, sym.sh_entsize)-1
			symp = Elf64_Sym(head, sym.sh_offset + sym.sh_entsize * j)
			if symp.st_name == 0 continue end
			println("\t[$j]\t$(ELF64_ST_TYPE(symp.st_info))\t$(symp.st_size)\t$(read_name(head, str.sh_offset + symp.st_name + 1))")
		end
	end

	println("Relocations:")
	for i in 0:ehdr.e_shnum-1
		shdr = Elf64_Shdr(head, ehdr.e_shoff + ehdr.e_shentsize * i)
		if shdr.sh_type != SHT_REL && shdr.sh_type != SHT_RELA continue end
		rel = shdr
		for j in 0:div(rel.sh_size, rel.sh_entsize)-1
			relp = Elf64_Rel(head, rel.sh_offset + rel.sh_entsize * j)
			symp = Elf64_Sym(head, sym.sh_offset + (sym.sh_entsize * ELF64_R_SYM(relp.r_info)))
			if symp.st_name == 0 continue end
			println("\t[$j]\t$(ELF64_R_SYM(relp.r_info))\t$(read_name(head, str.sh_offset + symp.st_name + 1))")
		end
	end
end


function main()
	if isempty(ARGS)
		error("no file specified")
	end
	elfdump(read(ARGS[1]))
end

Base.@ccallable function julia_main(ARGS::Vector{String})::Cint
	main()
end

end # module
