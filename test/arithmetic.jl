@testset verbose=true "Arithmetic ($T)" for T in [Float16, Float32, Float64]
    a = XNumber{T}(1.2, 1)
    b = XNumber{T}(3.4, 1)
    c = XNumber{T}(5.6, 2)

    @test a+b == XNumber(a.x+b.x, 1)
    @test b+a == XNumber(a.x+b.x, 1)
    @test a+c == c
    @test b+c == c
    @test c+a == c
    @test c+b == c
    @test a+a == 2a
    @test b+b == 2b
    @test c+c == 2c

    @test a-b == XNumber(a.x-b.x, 1)
    @test b-a == XNumber(b.x-a.x, 1)
    @test a-c == -c
    @test b-c == -c
    @test c-a == c
    @test c-b == c
    @test a-a == 0*a
    @test b-b == 0*b
    @test c-c == 0*c

    for x in (a, b, c)
        @test inv(x).x == inv(x.x)
        @test inv(x).iₓ == -x.iₓ
        @test (x^2).x == (x.x)^2
        @test (x^2).iₓ == 2*(x.iₓ)
        @test (x^1).x == (x.x)^1
        @test (x^1).iₓ == x.iₓ
        @test (x^-1).x == (x.x)^-1
        @test (x^-1).iₓ == -x.iₓ
        for y in (a, b, c)
            @test (x*y).x == x.x*y.x
            @test (x*y).iₓ == x.iₓ+y.iₓ
            @test (x/y).x == x.x/y.x
            @test (x/y).iₓ == x.iₓ-y.iₓ
            @test (y\x).x == x.x/y.x
            @test (y\x).iₓ == x.iₓ-y.iₓ
        end
    end
   
end
