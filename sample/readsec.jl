#!/bin/julia
using ELF
function readsec(head::Array{UInt8, 1})
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

	# .shstrtabのセクションヘッダを取得
	# e_shoff: ファイル内のセクション・ヘッダ・テーブルの位置
	# e_shentsize: セクションヘッダのサイズ
	# e_shstrndx: .shstrtabのセクション番号（セクション・ヘッダ・テーブル内のオフセット）
	shstr = Elf64_Shdr(head, ehdr.e_shoff + ehdr.e_shentsize * ehdr.e_shstrndx)

	println("Sections:")
	# e_shnum: セクションヘッダの個数
	for i in 0:ehdr.e_shnum-1
		shdr = Elf64_Shdr(head, ehdr.e_shoff + ehdr.e_shentsize * i)
		sname = unsafe_string(pointer(head, shstr.sh_offset + shdr.sh_name + 1))
		println("\t[$i]\t$sname")
	end
end
	
function main()
	if !isempty(ARGS)
		readsec(read(ARGS[1]))
	else
		error("no file specified")
	end

	println()

	run(`readelf -S $(ARGS[1])`)

	return 0
end

main()

