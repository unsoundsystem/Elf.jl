using ELF
function main()
	file = read(ARGS[1])
	ehdr = Elf64_Ehdr(file)

	if !IS_ELF(ehdr)
		println("This is not an ELF file")
		return 1
	end

	x1 = ehdr.e_shoff + ehdr.e_shentsize * ehdr.e_shstrndx
	shstr = Elf64_Shdr(file[x1+1:x1+64])
	x2 = ehdr.e_shoff + ehdr.e_shentsize
	shdr = Elf64_Shdr(file[x2+1:x2+64])
	x3 = shstr.sh_offset + shdr.sh_name
	print_section(file, x3+1, Int(ehdr.e_shnum))
end

main()
