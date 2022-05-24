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

    @testset verbose=true "Addition" begin
        for x in xnumbers
            @test (+x).x == x.x
            @test (+x).iₓ == x.iₓ
            @test (x+x).x == 2*(x.x)
            @test (x+x).iₓ == x.iₓ  # Assumes x.x < radix(x)/2
            if x.iₓ == 0
                @test (x + T(1.2)).x == x.x + T(1.2)
                @test (x + T(1.2)).iₓ == x.iₓ
                @test (T(1.2) + x).x == x.x + T(1.2)
                @test (T(1.2) + x).iₓ == x.iₓ
            elseif x.iₓ < 0
                @test (x + T(1.2)).x == T(1.2)
                @test (x + T(1.2)).iₓ == 0
                @test (T(1.2) + x).x == T(1.2)
                @test (T(1.2) + x).iₓ == 0
            else # x.iₓ > 0
                @test (x + T(1.2)).x == x.x
                @test (x + T(1.2)).iₓ == x.iₓ
                @test (T(1.2) + x).x == x.x
                @test (T(1.2) + x).iₓ == x.iₓ
            end
            for y in xnumbers
                if x.iₓ == y.iₓ
                    @test (x+y).x == x.x+y.x
                    @test (x+y).iₓ == x.iₓ
                elseif (!iszero(x.x) && x.iₓ > y.iₓ) || iszero(y.x)
                    @test x+y == x
                    @test y+x == x
                else # x.iₓ < y.iₓ
                    @test x+y == y
                    @test y+x == y
                end
            end
        end
    end

    @testset verbose=true "Subtraction" begin
        for x in xnumbers
            @test (-x).x == -x.x
            @test (-x).iₓ == x.iₓ
            @test (x-x).x == 0*(x.x)
            @test (x-x).iₓ == x.iₓ
            if x.iₓ == 0
                @test (x - T(1.2)).x == x.x - T(1.2)
                @test (x - T(1.2)).iₓ == x.iₓ
                @test (T(1.2) - x).x == T(1.2) - x.x
                @test (T(1.2) - x).iₓ == x.iₓ
            elseif x.iₓ < 0
                @test (x - T(1.2)).x == -T(1.2)
                @test (x - T(1.2)).iₓ == 0
                @test (T(1.2) - x).x == T(1.2)
                @test (T(1.2) - x).iₓ == 0
            else # x.iₓ > 0
                @test (x - T(1.2)).x == x.x
                @test (x - T(1.2)).iₓ == x.iₓ
                @test (T(1.2) - x).x == -x.x
                @test (T(1.2) - x).iₓ == x.iₓ
            end
            for y in xnumbers
                if x.iₓ == y.iₓ
                    @test (x-y).x == x.x-y.x
                    @test (x-y).iₓ == x.iₓ
                elseif (!iszero(x.x) && x.iₓ > y.iₓ) || iszero(y.x)
                    @test x-y == x
                    @test y-x == -x
                else # x.iₓ < y.iₓ
                    @test x-y == -y
                    @test y-x == y
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
            for X in filter(!iszero, xnumbers)
                for g in floats
                    for Y in filter(!iszero, xnumbers)
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
