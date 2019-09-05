using ELF

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

	println("Sections:")
	shdr = Elf64_Shdr(head, ehdr.e_shoff+ehdr.e_shentsize)
	off = shstr.sh_offset + shdr.sh_name + 1
	for i in 0:ehdr.e_shnum
		isnull = false
		while !isnull 
			if head[off] == 0x00
				print("\n")
				isnull = true
			end
			print(Char(head[off]))
			off += 1
		end
	end

	println("Segments:")
	phdr = Elf64_Phdr(head, ehdr.e_phoff + ehdr.e_phentsize * 0)
	for i in 0:ehdr.e_shnum
		phdr = Elf64_Phdr(head, ehdr.e_phoff + ehdr.e_phentsize * i)
		println("\t[$i]\t")
		for j in 0:ehdr.e_shnum
			shdr = Elf64_Shdr(head, ehdr.e_shoff + ehdr.e_shentsize * j)
			size = shdr.sh_type != SHT_NOBITS ? shdr.sh_size : 0
			if shdr.sh_offset < phdr.p_offset continue end
			if shdr.sh_offset + size  > phdr.p_offset + phdr.p_filesz continue end
			isnull = false
			while !isnull 
				if head[off] == 0x00
					print("\n")
					isnull = true
				end
				print(Char(head[off]))
				off += 1
			end
		end
		print("\n")
	end
end

function main()
	elfdump(read("../pointer"))
end

main()
