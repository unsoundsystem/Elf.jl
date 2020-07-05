export EI_CLASS, EI_DATA, EI_VERSION, EI_OSABI, ELFMAG1, ELFMAG2, ELFMAG3, ELFMAG4, elf64_st_type, elf64_r_info, elf64_r_sym

include("./types.jl")

macro enum_export(T, syms...)
    if T isa Symbol
        Ttype = typeof(T)
        esc(quote
            @enum $T $(syms...)
            export $T
            $([:(export $sym) for sym in syms]...)
        end)
    elseif (T.head === :(::) && T isa Expr && length(T.args) == 2 && T.args[1] isa Symbol)
        if eltype(syms) == Expr && length(syms) == 1
            vals = filter(x -> x isa Expr, syms[1].args)
            esc(quote
                @enum $(T.args[1])::$(T.args[2]) $(syms...)
                export $(T.args[1])
                $([:(export $(sym.args[1])) for sym in vals]...)
            end)
        else
            esc(quote
                @enum $(T.args[1])::$(T.args[2]) $(syms...)
                export $(T.args[1])
                $([:(export $sym) for sym in syms]...)
            end)
        end
    end
end

const EI_CLASS = 5
@enum_export EHClass::UInt8 begin
    ELFCLASSNONE = 0
    ELFCLASS32 = 1
    ELFCLASS64 = 2
end

const EI_DATA = 6
@enum_export EHEndian::UInt8 begin
    ELFDATANONE = 0
    ELFDATA2MSB = 1
    ELFDATA2LSB = 2
end

const EI_VERSION = 7
@enum_export EHVersion::UInt8 begin
    EV_NONE = 0
    EV_CURRENT = 1
end

const EI_OSABI = 8
@enum_export EHOsAbi::UInt8 begin
    ELFOSABI_SYSV = 0
    ELFOSABI_HPUX = 1
    ELFOSABI_NETBSD = 2
    ELFOSABI_LINUX = 3
    ELFOSABI_SOLARIS = 6
    ELFOSABI_AIX = 7
    ELFOSABI_IRIX = 8
    ELFOSABI_FREEBSD = 9
    ELFOSABI_TRU64 = 10
    ELFOSABI_MODESTO = 11
    ELFOSABI_OPENBSD = 12
    ELFOSABI_ARM_AEABI = 64
    ELFOSABI_ARM = 97
    ELFOSABI_STANDALONE = 255
end

@enum_export EHType::Elf64_Half begin
    ET_NONE = 0
    ET_REL = 1
    ET_EXEC = 2
    ET_DYN = 3
    ET_CORE = 4
    ET_NUM = 5
    ET_LOOS = 0xfe00
    ET_HIOS = 0xfeff
    ET_LOPROC = 0xff00
    ET_HIPROC = 0xffff
end

# for e_machine in Ehdr
@enum_export EHMachine::Elf64_Half begin
    EM_NONE = 0
    EM_M32 = 1
    EM_SPARC = 2
    EM_386 = 3
    EM_68K = 4
    EM_88K = 5
    EM_IAMCU = 6
    EM_860 = 7
    EM_MIPS = 8
    EM_S370 = 9
    EM_MIPS_RS3_LE = 10
    EM_PARISC = 15
    EM_VPP500 = 17
    EM_SPARC32PLUS = 18
    EM_960 = 19
    EM_PPC = 20
    EM_PPC64 = 21
    EM_S390 = 22
    EM_SPU = 23
    EM_V800 = 36
    EM_FR20 = 37
    EM_RH32 = 38
    EM_RCE = 39
    EM_ARM = 40
    EM_FAKE_ALPHA = 41
    EM_SH = 42
    EM_SPARCV9 = 43
    EM_TRICORE = 44
    EM_ARC = 45
    EM_H8_300 = 46
    EM_H8_300H = 47
    EM_H8S = 48
    EM_H8_500 = 49
    EM_IA_64 = 50
    EM_MIPS_X = 51
    EM_COLDFIRE = 52
    EM_68HC12 = 53
    EM_MMA = 54
    EM_PCP = 55
    EM_NCPU = 56
    EM_NDR1 = 57
    EM_STARCORE = 58
    EM_ME16 = 59
    EM_ST100 = 60
    EM_TINYJ = 61
    EM_X86_64 = 62
    EM_PDSP = 63
    EM_PDP10 = 64
    EM_PDP11 = 65
    EM_FX66 = 66
    EM_ST9PLUS = 67
    EM_ST7 = 68
    EM_68HC16 = 69
    EM_68HC11 = 70
    EM_68HC08 = 71
    EM_68HC05 = 72
    EM_SVX = 73
    EM_ST19 = 74
    EM_VAX = 75
    EM_CRIS = 76
    EM_JAVELIN = 77
    EM_FIREPATH = 78
    EM_ZSP = 79
    EM_MMIX = 80
    EM_HUANY = 81
    EM_PRISM = 82
    EM_AVR = 83
    EM_FR30 = 84
    EM_D10V = 85
    EM_D30V = 86
    EM_V850 = 87
    EM_M32R = 88
    EM_MN10300 = 89
    EM_MN10200 = 90
    EM_PJ = 91
    EM_OPENRISC = 92
    EM_ARC_COMPACT = 93
    EM_XTENSA = 94
    EM_VIDEOCORE = 95
    EM_TMM_GPP = 96
    EM_NS32K = 97
    EM_TPC = 98
    EM_SNP1K = 99
    EM_ST200 = 100
    EM_IP2K = 101
    EM_MAX = 102
    EM_CR = 103
    EM_F2MC16 = 104
    EM_MSP430 = 105
    EM_BLACKFIN = 106
    EM_SE_C33 = 107
    EM_SEP = 108
    EM_ARCA = 109
    EM_UNICORE = 110
    EM_EXCESS = 111
    EM_DXP = 112
    EM_ALTERA_NIOS2 = 113
    EM_CRX = 114
    EM_XGATE = 115
    EM_C166 = 116
    EM_M16C = 117
    EM_DSPIC30F = 118
    EM_CE = 119
    EM_M32C = 120
    EM_TSK3000 = 131
    EM_RS08 = 132
    EM_SHARC = 133
    EM_ECOG2 = 134
    EM_SCORE7 = 135
    EM_DSP24 = 136
    EM_VIDEOCORE3 = 137
    EM_LATTICEMICO32 = 138
    EM_SE_C17 = 139
    EM_TI_C6000 = 140
    EM_TI_C2000 = 141
    EM_TI_C5500 = 142
    EM_TI_ARP32 = 143
    EM_TI_PRU = 144
    EM_MMDSP_PLUS = 160
    EM_CYPRESS_M8C = 161
    EM_R32C = 162
    EM_TRIMEDIA = 163
    EM_QDSP6 = 164
    EM_8051 = 165
    EM_STXP7X = 166
    EM_NDS32 = 167
    EM_ECOG1X = 168
    EM_MAXQ30 = 169
    EM_XIMO16 = 170
    EM_MANIK = 171
    EM_CRAYNV2 = 172
    EM_RX = 173
    EM_METAG = 174
    EM_MCST_ELBRUS = 175
    EM_ECOG16 = 176
    EM_CR16 = 177
    EM_ETPU = 178
    EM_SLE9X = 179
    EM_L10M = 180
    EM_K10M = 181
    EM_AARCH64 = 183
    EM_AVR32 = 185
    EM_STM8 = 186
    EM_TILE64 = 187
    EM_TILEPRO = 188
    EM_MICROBLAZE = 189
    EM_CUDA = 190
    EM_TILEGX = 191
    EM_CLOUDSHIELD = 192
    EM_COREA_1ST = 193
    EM_COREA_2ND = 194
    EM_ARC_COMPACT2 = 195
    EM_OPEN8 = 196
    EM_RL78 = 197
    EM_VIDEOCORE5 = 198
    EM_78KOR = 199
    EM_56800EX = 200
    EM_BA1 = 201
    EM_BA2 = 202
    EM_XCORE = 203
    EM_MCHP_PIC = 204
    EM_KM32 = 210
    EM_KMX32 = 211
    EM_EMX16 = 212
    EM_EMX8 = 213
    EM_KVARC = 214
    EM_CDP = 215
    EM_COGE = 216
    EM_COOL = 217
    EM_NORC = 218
    EM_CSR_KALIMBA = 219
    EM_Z80 = 220
    EM_VISIUM = 221
    EM_FT32 = 222
    EM_MOXIE = 223
    EM_AMDGPU = 224
    EM_RISCV = 243
    EM_BPF = 247
    EM_CSKY = 252
end

const EI_NIDENT = 16
const EIMAG1 = 1
const ELFMAG1 = 0x7f
const EIMAG2 = 2
const ELFMAG2 = UInt8('E')
const EIMAG3 = 3
const ELFMAG3 = UInt8('L')
const EIMAG4 = 4
const ELFMAG4 = UInt8('F')

# for sh_name in Shdr
@enum_export SHName::UInt32 begin
    SHN_UNDEF = 0
    SHN_LORESERVE = 0xff00
    # SHN_LOPROC = 0xff00
    # SHN_BEFORE = 0xff00
    SHN_AFTER = 0xff01
    SHN_HIPROC = 0xff1f
    SHN_LOOS = 0xff20
    SHN_HIOS = 0xff3f
    SHN_ABS = 0xfff1
    SHN_COMMON = 0xfff2
    SHN_XINDEX = 0xffff
    # SHN_HIRESERVE = 0xffff
end

# for sh_type in Shdr
@enum_export SHType::UInt32 begin
    SHT_NULL = 0
    SHT_PROGBITS = 1
    SHT_SYMTAB = 2
    SHT_STRTAB = 3
    SHT_RELA = 4
    SHT_HASH = 5
    SHT_DYNAMIC = 6
    SHT_NOTE = 7
    SHT_NOBITS = 8
    SHT_REL = 9
    SHT_SHLIB = 10
    SHT_DYNSYM = 11
    SHT_INIT_ARRAY = 14
    SHT_FINI_ARRAY = 15
    SHT_PREINIT_ARRAY = 16
    SHT_GROUP = 17
    SHT_SYMTAB_SHNDX = 18
    SHT_NUM = 19
    SHT_LOOS = 0x60000000
    SHT_GNU_ATTRIBUTES = 0x6ffffff5
    SHT_GNU_HASH = 0x6ffffff6
    SHT_GNU_LIBLIST = 0x6ffffff7
    SHT_CHECKSUM = 0x6ffffff8
    SHT_LOSUNW = 0x6ffffffa
    # SHT_SUNW_move = 0x6ffffffa
    SHT_SUNW_COMDAT = 0x6ffffffb
    SHT_SUNW_syminfo = 0x6ffffffc
    SHT_GNU_verdef = 0x6ffffffd
    SHT_GNU_verneed = 0x6ffffffe
    SHT_GNU_versym = 0x6fffffff
    # SHT_HISUNW = 0x6fffffff
    # SHT_HIOS = 0x6fffffff
    SHT_LOPROC = 0x70000000
    SHT_HIPROC = 0x7fffffff
    SHT_LOUSER = 0x80000000
    SHT_HIUSER = 0x8fffffff
end

# for sh_flags in Shdr
@enum_export SHFlags::UInt32 begin
    SHF_WRITE = (1 << 0)
    SHF_ALLOC = (1 << 1)
    SHF_EXECINSTR = (1 << 2)
    SHF_MERGE = (1 << 4)
    SHF_STRINGS = (1 << 5)
    SHF_INFO_LINK = (1 << 6)
    SHF_LINK_ORDER = (1 << 7)
    SHF_OS_NONCONFORMING = (1 << 8)
    SHF_GROUP = (1 << 9)
    SHF_TLS = (1 << 10)
    SHF_COMPRESSED = (1 << 11)
    SHF_MASKOS = 0x0ff00000
    SHF_MASKPROC = 0xf0000000
    SHF_ORDERED = (1 << 30)
    SHF_EXCLUDE = (1 << 31)
end

# if sh_flags = SHF_COMPRESSED
@enum_export CHType::UInt32 begin
    ELFCOMPRESS_ZLIB = 1
    ELFCOMPRESS_LOOS = 0x60000000
    ELFCOMPRESS_HIOS = 0x6fffffff
    ELFCOMPRESS_LOPROC = 0x70000000
    ELFCOMPRESS_HIPROC = 0x7fffffff
end

# for si_boundto
@enum_export SymInfoBT::UInt16 begin
    SYMINFO_BT_SELF = 0xffff
    SYMINFO_BT_PARENT = 0xfffe
    SYMINFO_BT_LOWRESERVE = 0xff00
end

# for si_flags
@enum_export SymInfoFlags::UInt16 begin
    SYMINFO_FLG_DIRECT = 0x0001
    SYMINFO_FLG_PASSTHRU = 0x0002
    SYMINFO_FLG_COPY = 0x0004
    SYMINFO_FLG_LAZYLOAD = 0x0008
end

@enum_export SymInfoVersion::UInt8 begin
    SYMINFO_NONE
    SYMINFO_CURRENT
end

# for st_info
@enum_export STBind::UInt8 begin
    STB_LOCAL = 0 #  Local symbol
    STB_GLOBAL = 1 #  Global symbol
    STB_WEAK = 2 #  Weak symbol
    STB_NUM = 3 #  Number of defined types.
    # STB_LOOS = 10 #  Start of OS-specific
    STB_GNU_UNIQUE = 10 #  Unique symbol.
    STB_HIOS = 12 #  End of OS-specific
    STB_LOPROC = 13 #  Start of processor-specific
    STB_HIPROC = 15 #  End of processor-specific
end

# for st_info

@enum_export STType::UInt8 begin
    STT_NOTYPE = 0 #  Symbol type is unspecified
    STT_OBJECT = 1 #  Symbol is a data object
    STT_FUNC = 2 #  Symbol is a code object
    STT_SECTION = 3 #  Symbol associated with a section
    STT_FILE = 4 #  Symbol's name is file name
    STT_COMMON = 5 #  Symbol is a common data object
    STT_TLS = 6 #  Symbol is thread-local data object
    STT_NUM = 7 #  Number of defined types.
    # STT_LOOS = 10 #  Start of OS-specific
    STT_GNU_IFUNC = 10 #  Symbol is indirect code object
    STT_HIOS = 12 #  End of OS-specific
    STT_LOPROC = 13 #  Start of processor-specific
    STT_HIPROC = 15 #  End of processor-specific
end

# for st_other
@enum_export STVisibility::UInt8 begin
    STV_DEFAULT = 0 #  Default symbol visibility rules
    STV_INTERNAL = 1 #  Processor specific hidden class
    STV_HIDDEN = 2 #  Sym unavailable in other modules
    STV_PROTECTED = 3 #  Not preemptible, not exported
end

elf32_r_sym(val) = val >>> 8
elf32_r_type(val) = val & 0xff
elf32_r_info(sym, type) = (sym << 8) + (type & 0xff)

elf64_st_type(val) = STType(UInt8(val & 0xf))
elf64_r_sym(i) = i >>> 32
elf64_r_info(sym, type) = (Elf64_Xword(sym) << 32) + type

# for p_type
@enum_export PType::UInt32 begin
    PT_NULL = 0 #   Program header table entry unused
    PT_LOAD = 1 #   Loadable program segment
    PT_DYNAMIC = 2 #   Dynamic linking information
    PT_INTERP = 3 #   Program interpreter
    PT_NOTE = 4 #   Auxiliary information
    PT_SHLIB = 5 #   Reserved
    PT_PHDR = 6 #   Entry for header table itself
    PT_TLS = 7 #   Thread-local storage segment
    PT_NUM = 8 #   Number of defined types
    PT_LOOS = 0x60000000 #  Start of OS-specific
    PT_GNU_EH_FRAME = 0x6474e550 #  GCC .eh_frame_hdr segment
    PT_GNU_STACK = 0x6474e551 #  Indicates stack executability
    PT_GNU_RELRO = 0x6474e552 #  Read-only after relocation
    PT_LOSUNW = 0x6ffffffa #
    # PT_SUNWBSS = 0x6ffffffa #  Sun Specific segment
    PT_SUNWSTACK = 0x6ffffffb #  Stack segment
    PT_HISUNW = 0x6fffffff #
    # PT_HIOS = 0x6fffffff #  End of OS-specific
    PT_LOPROC = 0x70000000 #  Start of processor-specific
    PT_HIPROC = 0x7fffffff #  End of processor-specific
end

# for p_flags
@enum_export PFlags::UInt32 begin
    PF_X = 1
    PF_W = 2
    PF_R = 4
    PF_MASKOS = 0x0ff00000
    PF_MASKPROC = 0xf0000000
end

# values for note segmets
@enum_export NoteTypes::UInt32 begin
    NT_PRSTATUS = 1 # Contains copy of prstatus struct
    # NT_PRFPREG = 2 # Contains copy of fpregset struct.
    NT_FPREGSET = 2 # Contains copy of fpregset struct
    NT_PRPSINFO = 3 # Contains copy of prpsinfo struct
    NT_PRXREG = 4 # Contains copy of prxregset struct
    # NT_TASKSTRUCT = 4 # Contains copy of task structure
    NT_PLATFORM = 5 # String from sysinfo(SI_PLATFORM)
    NT_AUXV = 6 # Contains copy of auxv array
    NT_GWINDOWS = 7 # Contains copy of gwindows struct
    NT_ASRS = 8 # Contains copy of asrset struct
    NT_PSTATUS = 10 # Contains copy of pstatus struct
    NT_PSINFO = 13 # Contains copy of psinfo struct
    NT_PRCRED = 14 # Contains copy of prcred struct
    NT_UTSNAME = 15 # Contains copy of utsname struct
    NT_LWPSTATUS = 16 # Contains copy of lwpstatus struct
    NT_LWPSINFO = 17 # Contains copy of lwpinfo struct
    NT_PRFPXREG = 20 # Contains copy of fprxregset struct
    NT_SIGINFO = 0x53494749 # Contains copy of siginfo_t, size might increase
    NT_FILE = 0x46494c45 # Contains information about mapped files
    NT_PRXFPREG = 0x46e62b7f # Contains copy of user_fxsr_struct
    NT_PPC_VMX = 0x100 # PowerPC Altivec/VMX registers
    NT_PPC_SPE = 0x101 # PowerPC SPE/EVR registers
    NT_PPC_VSX = 0x102 # PowerPC VSX registers
    NT_PPC_TAR = 0x103 # Target Address Register
    NT_PPC_PPR = 0x104 # Program Priority Register
    NT_PPC_DSCR = 0x105 # Data Stream Control Register
    NT_PPC_EBB = 0x106 # Event Based Branch Registers
    NT_PPC_PMU = 0x107 # Performance Monitor Registers
    NT_PPC_TM_CGPR = 0x108 # TM checkpointed GPR Registers
    NT_PPC_TM_CFPR = 0x109 # TM checkpointed FPR Registers
    NT_PPC_TM_CVMX = 0x10a # TM checkpointed VMX Registers
    NT_PPC_TM_CVSX = 0x10b # TM checkpointed VSX Registers
    NT_PPC_TM_SPR = 0x10c # TM Special Purpose Registers
    NT_PPC_TM_CTAR = 0x10d # TM checkpointed Target Address Register
    NT_PPC_TM_CPPR = 0x10e # TM checkpointed Program Priority Register
    NT_PPC_TM_CDSCR = 0x10f # TM checkpointed Data Stream Control Register
    NT_PPC_PKEY = 0x110 # Memory Protection Keys registers.
    NT_386_TLS = 0x200 # i386 TLS slots (struct user_desc)
    NT_386_IOPERM = 0x201 # x86 io permission bitmap (1=deny)
    NT_X86_XSTATE = 0x202 # x86 extended state using xsave
    NT_S390_HIGH_GPRS = 0x300 # s390 upper register halves
    NT_S390_TIMER = 0x301 # s390 timer register
    NT_S390_TODCMP = 0x302 # s390 TOD clock comparator register
    NT_S390_TODPREG = 0x303 # s390 TOD programmable register
    NT_S390_CTRS = 0x304 # s390 control registers
    NT_S390_PREFIX = 0x305 # s390 prefix register
    NT_S390_LAST_BREAK = 0x306 # s390 breaking event address
    NT_S390_SYSTEM_CALL = 0x307 # s390 system call restart data
    NT_S390_TDB = 0x308 # s390 transaction diagnostic block
    NT_S390_VXRS_LOW = 0x309 # s390 vector registers 0-15 upper half.
    NT_S390_VXRS_HIGH = 0x30a # s390 vector registers 16-31.
    NT_S390_GS_CB = 0x30b # s390 guarded storage registers.
    NT_S390_GS_BC = 0x30c # s390 guarded storage broadcast control block.
    NT_S390_RI_CB = 0x30d # s390 runtime instrumentation.
    NT_ARM_VFP = 0x400 # ARM VFP/NEON registers
    NT_ARM_TLS = 0x401 # ARM TLS register
    NT_ARM_HW_BREAK = 0x402 # ARM hardware breakpoint registers
    NT_ARM_HW_WATCH = 0x403 # ARM hardware watchpoint registers
    NT_ARM_SYSTEM_CALL = 0x404 # ARM system call number
    NT_ARM_SVE = 0x405 # ARM Scalable Vector Extension registers
    NT_ARM_PAC_MASK = 0x406 # ARM pointer authentication code masks.
    NT_ARM_PACA_KEYS = 0x407 # ARM pointer authentication address keys.
    NT_ARM_PACG_KEYS = 0x408 # ARM pointer authentication generic key.
    NT_VMCOREDD = 0x700 # Vmcore Device Dump Note.
    NT_MIPS_DSP = 0x800 # MIPS DSP ASE registers.
    NT_MIPS_FP_MODE = 0x801 # MIPS floating-point mode.
    # NT_MIPS_MSA = 0x802 # MIPS SIMD registers.
end

const NT_VERSION = 1

@enum_export DTag::UInt32 begin
    DT_NULL = 0 # Marks end of dynamic section
    DT_NEEDED = 1 # Name of needed library
    DT_PLTRELSZ = 2 # Size in bytes of PLT relocs
    DT_PLTGOT = 3 # Processor defined value
    DT_HASH = 4 # Address of symbol hash table
    DT_STRTAB = 5 # Address of string table
    DT_SYMTAB = 6 # Address of symbol table
    DT_RELA = 7 # Address of Rela relocs
    DT_RELASZ = 8 # Total size of Rela relocs
    DT_RELAENT = 9 # Size of one Rela reloc
    DT_STRSZ = 10 # Size of string table
    DT_SYMENT = 11 # Size of one symbol table entry
    DT_INIT = 12 # Address of init function
    DT_FINI = 13 # Address of termination function
    DT_SONAME = 14 # Name of shared object
    DT_RPATH = 15 # Library search path (deprecated)
    DT_SYMBOLIC = 16 # Start symbol search here
    DT_REL = 17 # Address of Rel relocs
    DT_RELSZ = 18 # Total size of Rel relocs
    DT_RELENT = 19 # Size of one Rel reloc
    DT_PLTREL = 20 # Type of reloc in PLT
    DT_DEBUG = 21 # For debugging; unspecified
    DT_TEXTREL = 22 # Reloc might modify .text
    DT_JMPREL = 23 # Address of PLT relocs
    DT_BIND_NOW = 24 # Process relocations of object
    DT_INIT_ARRAY = 25 # Array with addresses of init fct
    DT_FINI_ARRAY = 26 # Array with addresses of fini fct
    DT_INIT_ARRAYSZ = 27 # Size in bytes of DT_INIT_ARRAY
    DT_FINI_ARRAYSZ = 28 # Size in bytes of DT_FINI_ARRAY
    DT_RUNPATH = 29 # Library search path
    DT_FLAGS = 30 # Flags for the object being loaded
    # DT_ENCODING = 32 # Start of encoded range
    DT_PREINIT_ARRAY = 32 # Array with addresses of preinit fct
    DT_PREINIT_ARRAYSZ = 33 # size in bytes of DT_PREINIT_ARRAY
    DT_SYMTAB_SHNDX = 34 # Address of SYMTAB_SHNDX section
    DT_NUM = 35 # Number used
    DT_LOOS = 0x6000000d # Start of OS-specific
    DT_HIOS = 0x6ffff000 # End of OS-specific
    DT_LOPROC = 0x70000000 # Start of processor-specific
    DT_HIPROC = 0x7fffffff # End of processor-specific
    # DT_PROCNUM = DT_MIPS_NUM # Most used by any processor
end

@enum_export DPtr::UInt32 begin
    DT_ADDRRNGLO = 0x6ffffe00
    DT_GNU_HASH = 0x6ffffef5 # GNU-style hash table.
    DT_TLSDESC_PLT = 0x6ffffef6
    DT_TLSDESC_GOT = 0x6ffffef7
    DT_GNU_CONFLICT = 0x6ffffef8 # Start of conflict section
    DT_GNU_LIBLIST = 0x6ffffef9 # Library list
    DT_CONFIG = 0x6ffffefa # Configuration information.
    DT_DEPAUDIT = 0x6ffffefb # Dependency auditing.
    DT_AUDIT = 0x6ffffefc # Object auditing.
    DT_PLTPAD = 0x6ffffefd # PLT padding.
    DT_MOVETAB = 0x6ffffefe # Move table.
    DT_SYMINFO = 0x6ffffeff # Syminfo table.
    # DT_ADDRRNGHI = 0x6ffffeff
    DT_ADDRNUM = 11
end

dt_addrtagidx(tag) = (DT_ADDRRNGHI - (tag)) # Reverse order!

@enum_export DVal::UInt32 begin
    DT_VALRNGLO = 0x6ffffd00
    DT_GNU_PRELINKED = 0x6ffffdf5 # Prelinking timestamp
    DT_GNU_CONFLICTSZ = 0x6ffffdf6 # Size of conflict section
    DT_GNU_LIBLISTSZ = 0x6ffffdf7 # Size of library list
    DT_CHECKSUM = 0x6ffffdf8
    DT_PLTPADSZ = 0x6ffffdf9
    DT_MOVEENT = 0x6ffffdfa
    DT_MOVESZ = 0x6ffffdfb
    DT_FEATURE_1 = 0x6ffffdfc # Feature selection (DTF_*).
    DT_POSFLAG_1 = 0x6ffffdfd # Flags for DT_* entries, effecting the following DT_* entry.
    DT_SYMINSZ = 0x6ffffdfe # Size of syminfo table (in bytes)
    DT_SYMINENT = 0x6ffffdff # Entry size of syminfo
    # DT_VALRNGHI = 0x6ffffdff
    DT_VALNUM = 12

end

dt_valtagidx(tag) = (DT_VALRNGHI - (tag)) # Reverse order!
