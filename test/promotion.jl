@testset verbose=true "Promotion" begin
    types = [Float16, Float32, Float64]
    sample(T) = [
        xnumber(sign*T(v), i)
        for v in (0, 0.3, 1.2, 97.5) for sign in (-1, 1) for i in -2:2
    ]

    @testset "promote_type" begin
        @test promote_type(XNumber{Float16}, XNumber{Float64}) == XNumber{Float64}
        @test promote_type(XNumber{Float16}, Float64) == XNumber{Float64}
        @test promote_type(XNumber{Float64}, Float16) == XNumber{Float64}
        @test promote_type(XNumber{Float32}, Int) == XNumber{Float32}
        @test promote_type(XNumber{Float64}, BigFloat) == XNumber{BigFloat}
        @test promote_type(BigFloat, XNumber{Float64}) == XNumber{BigFloat}
    end

    @testset "Conversion $T → $S" for T in types, S in types
        for X in sample(T)
            Y = XNumber{S}(X)
            if precision(S) ≥ precision(T)
                @test BigFloat(Y) == BigFloat(X)
                @test XNumber{T}(Y) === X
            else
                @test BigFloat(Y) ≈ BigFloat(X) rtol=eps(S)
            end
            @test XNumbers.radix_sqrt_inverse(Y) ≤ abs(Y.x) < XNumbers.radix_sqrt(Y) || iszero(Y)
        end
    end

    @testset "Mixed arithmetic $T with $S" for T in types, S in types
        U = promote_type(T, S)
        for X in sample(T), Y in sample(S)
            for (op, bop) in ((+, +), (-, -), (*, *))
                Z = op(X, Y)
                @test Z isa XNumber{U}
                @test BigFloat(Z) ≈ bop(BigFloat(X), BigFloat(Y)) rtol=2eps(U)
            end
            if !iszero(Y)
                @test BigFloat(X / Y) ≈ BigFloat(X) / BigFloat(Y) rtol=2eps(U)
                @test BigFloat(Y \ X) ≈ BigFloat(X) / BigFloat(Y) rtol=2eps(U)
            end
        end
        # Plain reals of type S, including values outside the range of T
        for X in sample(T), y in S[0, -1.2, floatmax(S), floatmin(S)]
            @test BigFloat(X + y) ≈ BigFloat(X) + BigFloat(y) rtol=2eps(U)
            @test BigFloat(y - X) ≈ BigFloat(y) - BigFloat(X) rtol=2eps(U)
            @test BigFloat(X * y) ≈ BigFloat(X) * BigFloat(y) rtol=2eps(U)
            @test BigFloat(y * X) ≈ BigFloat(X) * BigFloat(y) rtol=2eps(U)
        end
    end

    @testset "Mixed comparisons $T with $S" for T in types, S in types
        for X in sample(T), Y in sample(S)
            x, y = BigFloat(X), BigFloat(Y)
            @test (X == Y) == (x == y)
            @test (X < Y) == (x < y)
            @test (X ≤ Y) == (x ≤ y)
            @test (X > Y) == (x > y)
            @test isless(X, Y) == isless(x, y) || (iszero(x) && iszero(y))
            # A plain float, possibly saturated, since S(Y) may be out of range
            f = S(Y)
            @test (X == f) == (x == BigFloat(f))
            @test (f < X) == (BigFloat(f) < x)
        end
    end

    @testset "Comparisons with plain reals are exact" begin
        X = xnumber(Float16(1.2))
        @test X == Float16(1.2)
        @test X != 1.2
        @test X > 1.2
        @test 1.2 < X
        @test !isequal(X, 1.2)
        @test !isequal(xnumber(-0.0), 0.0)
        @test isequal(xnumber(-0.0), -0.0)
        @test isless(xnumber(-0.0), 0.0)
        @test xnumber(Float16(0.5)) == 1//2
        @test xnumber(1/3) != 1//3
        @test xnumber(1/3) < 1//3 && 1//3 > xnumber(1/3)
        @test XNumber{Float64}(1.0, -2) < 1//10^100
        @test XNumber{Float64}(1.0, 2) > big(10)^500//3
        @test cmp(xnumber(-0.5), -1//2) == 0
        # Values that compare equal must hash equally
        @test hash(xnumber(1.2)) == hash(1.2)
        @test hash(xnumber(Float16(0.5))) == hash(1//2)
        @test hash(XNumber{Float16}(Float16(1), 5)) == hash(big(2)^75)
        @test XNumber{Float16}(Float16(1), 70) > floatmax(Float64)
    end

    @testset "ldexp" begin
        for T in types, X in sample(T), n in (-2000, -961, -17, -1, 0, 1, 17, 480, 961, 2000)
            @test BigFloat(ldexp(X, n)) == ldexp(BigFloat(X), n)
        end
    end

    @testset "Other reals" begin
        X = xnumber(1.2, 3)
        @test X * 2 === XNumber{Float64}(2.4, 3)
        @test 2 * X === X * 2
        @test X + true == X
        @test X * (1//2) == XNumber{Float64}(0.6, 3)
        @test xnumber(1.0) + big(2.0) == 3
        @test (xnumber(1.0) + big(2.0)) isa XNumber{BigFloat}
    end
end
