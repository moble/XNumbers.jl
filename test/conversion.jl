@testset verbose=true "Conversion ($T)" for T in [Float16, Float32, Float64]
    for i in vcat(rand(-1000:1000, 20), [-2,-1,0,1,2])
        x = XNumber{T}(1, i)
        X = 1 * (BigFloat(2)^XNumbers.log2_radix(x)) ^ i
        if ≉(BigFloat(x), X, atol=100eps(BigFloat))
            println((i, BigFloat(x), X))
        end
        @test BigFloat(x) ≈ X atol=100eps(BigFloat)
    end
end

@testset verbose=true "Construction ($T)" for T in [Float16, Float32, Float64]
    # Every float within T's range should survive a round trip, and xnumber
    # should step the exponent by one radix, not by log2(radix)
    for f in T[1, -1.2, floatmax(T), -floatmax(T), floatmin(T), nextfloat(zero(T)), -nextfloat(zero(T))]
        X = xnumber(f)
        @test T(X) == f
        @test abs(X.iₓ) ≤ 2
        # Fully normalized, even for subnormal f
        @test XNumbers.radix_sqrt_inverse(X) ≤ abs(X.x) < XNumbers.radix_sqrt(X)
    end
    @test xnumber(T(1.1)*XNumbers.radix_sqrt(XNumber{T})).iₓ == 1
    @test xnumber(T(0.9)*XNumbers.radix_sqrt_inverse(XNumber{T})).iₓ == -1
    @test XNumber{T}(floatmax(T)) == xnumber(floatmax(T))
    @test XNumber{T}(3) == xnumber(T(3))

    # Zeros and non-finite values always carry their special exponents
    for z in (xnumber(zero(T)), xnumber(-zero(T), 5), XNumber{T}(0, -3), zero(XNumber{T}))
        @test z.iₓ == XNumbers.zero_exponent
        @test iszero(T(z))
    end
    @test signbit(T(xnumber(-zero(T))))
    for v in (T(Inf), T(-Inf), T(NaN))
        @test xnumber(v).iₓ == XNumbers.nonfinite_exponent
        @test isequal(T(xnumber(v)), v)
    end
    @test XNumbers.inf(XNumber{T}) == xnumber(T(Inf))
    @test isequal(XNumbers.nan(XNumber{T}), xnumber(T(NaN)))

    # Results that become zero or infinite are canonical too
    X = xnumber(T(1.2), 3)
    @test (X - X).iₓ == XNumbers.zero_exponent
    @test (X * 0).iₓ == XNumbers.zero_exponent
    @test (zero(X) * zero(X)).iₓ == XNumbers.zero_exponent
    @test (zero(X)^3).iₓ == XNumbers.zero_exponent
    @test sqrt(zero(X)).iₓ == XNumbers.zero_exponent
    @test cbrt(zero(X)).iₓ == XNumbers.zero_exponent
    @test inv(zero(X)) == XNumbers.inf(XNumber{T})

    # Conversion of extreme exponents saturates rather than overflowing
    @test Float64(floatmax(XNumber{T})) == Inf
    @test Float64(floatmin(XNumber{T})) == 0
end
