@testset verbose=true "Math ($T)" for T in [Float16, Float32, Float64]
    # Significands spread over the normalized range, including some small enough
    # that, for Float16, values with exponent 1 are not integers
    xs = [
        xnumber(sign*T(v), i)
        for v in (nextfloat(T(2)^-6), 0.3, 1, 1.2, 3.4, 97.5)
        for sign in (-1, 1)
        for i in -3:3
    ]
    positives = filter(X -> X.x > 0, xs)

    @testset "log2" begin
        for X in positives
            @test log2(X) ≈ T(log2(BigFloat(X))) rtol=2eps(T)
        end
        @test log2(zero(XNumber{T})) == -Inf
        @test log2(XNumbers.inf(XNumber{T})) == Inf
    end

    @testset "exponent and significand" begin
        for X in xs
            @test exponent(X) == exponent(BigFloat(X))
            @test significand(X) * BigFloat(2)^exponent(X) == BigFloat(X)
        end
        @test_throws DomainError exponent(zero(XNumber{T}))
    end

    @testset "sinpi and friends" begin
        # A Float16 with exponent 1 whose significand has bits worth less than 2
        @test isinteger(BigFloat(XNumber{T}(nextfloat(T(2)^-6), 1))) == (T != Float16)
        for X in xs
            r = rem(BigFloat(X), 2)  # exact, and keeps tiny values tiny
            s, c = sinpi(r), cospi(r)
            if X.iₓ < 0
                # Tiny arguments: sinpi must be accurate relative to its size
                @test BigFloat(sinpi(X)) ≈ s rtol=2eps(T)
            else
                @test BigFloat(sinpi(X)) ≈ s rtol=2eps(T) atol=eps(T)
            end
            @test BigFloat(cospi(X)) ≈ c rtol=2eps(T) atol=eps(T)
            @test sincospi(X) == (sinpi(X), cospi(X))
            @test cispi(X) == Complex(cospi(X), sinpi(X))
        end
        # Huge even and odd multiples
        @test iszero(sinpi(XNumber{T}(T(3), 5)))
        @test isone(cospi(XNumber{T}(T(3), 5)))
        @test isnan(sinpi(XNumbers.nan(XNumber{T})))
        @test sinpi(zero(XNumber{T})) == 0
        @test signbit(sinpi(xnumber(-zero(T))))
    end
end
