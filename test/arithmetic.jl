@testset verbose=true "Arithmetic ($T)" for T in [Float16, Float32, Float64]
    xnumbers = [
        xnumber(sign*x, i)
        for x in T[
            0, 1, 1.2, 3.4, 5.6,
            1.1*XNumbers.radix_sqrt(XNumber{T}),
            0.9*XNumbers.radix_sqrt_inverse(XNumber{T})
        ]
        for sign in [-1,1]
        for i in -6:6
    ]

    # Sums are checked against exact BigFloat sums.  Terms whose exponents differ
    # by more than one are dropped, which costs a relative error of at most
    # 1/radix, well below eps(T).
    @testset verbose=true "Addition" begin
        for x in xnumbers
            @test (+x).x == x.x
            @test (+x).iₓ == x.iₓ
            @test (x+x).x == 2*(x.x)
            @test (x+x).iₓ == x.iₓ  # Assumes x.x < radix(x)/2
            @test x + zero(x) == x
            @test zero(x) + x == x
            if x.iₓ == 0
                @test x + T(1.2) == XNumber{T}(x.x + T(1.2), x.iₓ)
                @test T(1.2) + x == XNumber{T}(x.x + T(1.2), x.iₓ)
            end
            @test BigFloat(x + T(1.2)) ≈ BigFloat(x) + BigFloat(T(1.2)) rtol=2eps(T)
            @test BigFloat(T(1.2) + x) ≈ BigFloat(x) + BigFloat(T(1.2)) rtol=2eps(T)
            for y in xnumbers
                @test BigFloat(x+y) ≈ BigFloat(x) + BigFloat(y) rtol=2eps(T)
                @test x+y == y+x
                if x.iₓ == y.iₓ
                    @test x+y == XNumber{T}(x.x+y.x, x.iₓ)
                end
            end
        end
    end

    @testset verbose=true "Subtraction" begin
        for x in xnumbers
            @test (-x).x == -x.x
            @test (-x).iₓ == x.iₓ
            @test iszero(x-x)
            @test (x-x).iₓ == XNumbers.zero_exponent
            @test x - zero(x) == x
            @test zero(x) - x == -x
            if x.iₓ == 0
                @test x - T(1.2) == XNumber{T}(x.x - T(1.2), x.iₓ)
                @test T(1.2) - x == XNumber{T}(T(1.2) - x.x, x.iₓ)
            end
            @test BigFloat(x - T(1.2)) ≈ BigFloat(x) - BigFloat(T(1.2)) rtol=2eps(T)
            @test BigFloat(T(1.2) - x) ≈ BigFloat(T(1.2)) - BigFloat(x) rtol=2eps(T)
            for y in xnumbers
                @test BigFloat(x-y) ≈ BigFloat(x) - BigFloat(y) rtol=2eps(T)
                @test x-y == x+(-y)
                if x.iₓ == y.iₓ
                    @test x-y == XNumber{T}(x.x-y.x, x.iₓ)
                end
            end
        end
    end

    @testset verbose=true "Multiplication/division/powers" begin
        for x in filter(!iszero, xnumbers)
            @test inv(x).x == inv(x.x)
            @test inv(x).iₓ == -x.iₓ
            @test (x^2).x == (x.x)^2
            @test (x^2).iₓ == 2*(x.iₓ)
            @test (x^1).x == (x.x)^1
            @test (x^1).iₓ == x.iₓ
            @test (x^-1).x == (x.x)^-1
            @test (x^-1).iₓ == -x.iₓ
            for y in filter(!iszero, xnumbers)
                @test (x*y).x == x.x*y.x
                @test (x*y).iₓ == x.iₓ+y.iₓ
                @test (x/y).x == x.x/y.x
                @test (x/y).iₓ == x.iₓ-y.iₓ
                @test (y\x).x == x.x/y.x
                @test (y\x).iₓ == x.iₓ-y.iₓ
            end
            for y in [-T(1.2), T(1.2)]
                @test (x*y).x == x.x*y
                @test (x*y).iₓ == x.iₓ
                @test (y*x).x == y*x.x
                @test (y*x).iₓ == x.iₓ
                @test (x/y).x == x.x/y
                @test (x/y).iₓ == x.iₓ
                @test (y/x).x == y/x.x
                @test (y/x).iₓ == -x.iₓ
                @test (y\x).x == x.x/y
                @test (y\x).iₓ == x.iₓ
                @test (x\y).x == y/x.x
                @test (x\y).iₓ == -x.iₓ
            end
        end
    end

    @testset verbose=true "Linear combination" begin
        floats = T[-3.4, -1.2, -1, 1, 1.2, 3.4]
        for f in floats
            for X in xnumbers
                for g in floats
                    for Y in xnumbers
                        l = linear_combination(f, X, g, Y)
                        e = normalize(f*X + g*Y)
                        @test l.x ≈ e.x rtol=5eps(T)
                        @test l.iₓ == e.iₓ
                    end
                end
            end
        end
    end

    @testset verbose=true "Roots" begin
        for x in filter(y->y.x≥0, xnumbers)
            X = BigFloat(x)
            xsqrt = BigFloat(sqrt(x))
            Xsqrt = sqrt(X)
            @test xsqrt ≈ Xsqrt rtol=10eps(T)
            xcbrt = BigFloat(cbrt(x))
            Xcbrt = cbrt(X)
            if ≉(xcbrt, Xcbrt, rtol=10eps(T))
                println((x, X, xcbrt, Xcbrt))
            end
            @test xcbrt ≈ Xcbrt rtol=10eps(T)
        end
    end
end
