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

	x1 = ehdr.e_shoff + ehdr.e_shentsize * ehdr.e_shstrndx
	shstr = Elf64_Shdr(head[x1+1:x1+64])

	println("Sections:")
	x2 = ehdr.e_shoff + ehdr.e_shentsize
	shdr = Elf64_Shdr(head[x2+1:x2+64])
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

	# print_section(head, x3+1, Int(ehdr.e_shnum))

	println("Segments:")
	# for i in 0:ehdr.e_shnum
		# x4 = ehdr.e_phoff + ehdr.e_phentsize * i
		# phdr = Elf64_Phdr(head[x4+1:x4+56])
		# println("\t[$i]\t")
		# for j in 0:ehdr.e_shnum
			# x5 = ehdr.e_shoff + ehdr.e_shentsize * j
			# shdr = Elf64_Shdr(head[x5+1:x5:64])
			# size = shdr.sh_type != SHT_NOBITS ? shdr.sh_size : 0
			# if shdr.sh_offset < phdr.p_offset continue end
			# if shdr.shoffset + size  > phdr.p_offset + phdr.p_filez continue end
			# sname = 
end

function main()
	elfdump(read("../pointer"))
end

main()
