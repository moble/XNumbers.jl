@testset verbose=true "Arithmetic ($T)" for T in [Float16, Float32, Float64]
    a = XNumber{T}(1.2, 1)
    b = XNumber{T}(3.4, 1)
    c = XNumber{T}(5.6, 2)
    @test a+b == XNumber(a.x+b.x, 1)
    @test a+c == c
    @test b+c == c
    @test a+a == 2a
    @test b+b == 2b
    @test c+c == 2c
    for x in (a, b, c)
        for y in (a, b, c)
            @test (x*y).x == x.x*y.x
            @test (x*y).iₓ == x.iₓ+y.iₓ
        end
    end
   
end
