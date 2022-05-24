@testset verbose=true "Comparisons ($T)" for T in [Float16, Float32, Float64]
    a = XNumber{T}(1.2, 1)
    b = XNumber{T}(3.4, 1)
    c = XNumber{T}(1.2, 2)

    @test a == a
    @test b == b
    @test c == c
    @test a != b
    @test a != c
    @test b != c
    @test b != a
    @test c != a
    @test c != b

    @test a ≤ a
    @test b ≤ b
    @test c ≤ c
    @test a ≤ b
    @test a ≤ c
    @test b ≤ c
    @test a < b
    @test a < c
    @test b < c
    @test a ≥ a
    @test b ≥ b
    @test c ≥ c
    @test b ≥ a
    @test c ≥ a
    @test c ≥ b
    @test b > a
    @test c > a
    @test c > b

    @test isequal(a, a)
    @test isequal(b, b)
    @test isequal(c, c)
    @test !isequal(a, b)
    @test !isequal(a, c)
    @test !isequal(b, c)
    @test !isequal(b, a)
    @test !isequal(c, a)
    @test !isequal(c, b)

    @test isless(a, b)
    @test isless(a, c)
    @test isless(b, c)
    @test !isless(b, a)
    @test !isless(c, a)
    @test !isless(c, b)
end
