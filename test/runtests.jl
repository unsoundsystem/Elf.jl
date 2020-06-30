using Elf
using Test
using Serialization

@testset "Elf.jl" begin
    # Write your tests here.
    bin = deserialize("testbin")
    ehdr = Elf64_Ehdr(bin)
    @test iself(ehdr)
    @test elfclass(ehdr) == ELFCLASS64
    @test endian(ehdr) == ELFDATA2MSB
    @test sections(bin) == deserialize("sections")
    @test segments(bin) == deserialize("segments")
    @test symbols(bin) == deserialize("symbols")
end
