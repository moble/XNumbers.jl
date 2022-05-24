@testset verbose=true "Comparisons ($T)" for T in [Float16, Float32, Float64]
    a = XNumber{T}(1.2, 0)
    b = XNumber{T}(3.4, 0)
    c = XNumber{T}(1.2, 1)
    d = XNumber{T}(3.4, 1)
    e = XNumber{T}(1.2, 2)
    xnumbers = [a, b, c, d, e]

    for x in xnumbers
        @test x == x
        for y in xnumbers
            if x !== y
                @test x != y
            end
        end
    end
    @test a == T(1.2)
    @test b == T(3.4)
    @test c != T(1.2)
    @test d != T(3.4)
    @test e != T(1.2)

    for (i,x) in enumerate(xnumbers)
        @test x ≤ x
        @test x ≥ x
        if x.iₓ == 0
            @test x > x.x-T(0.1)
            @test x ≥ x.x-T(0.1)
            @test x ≥ x.x
            @test x ≤ x.x
            @test x ≤ x.x+T(0.1)
            @test x < x.x+T(0.1)
            @test x.x-T(0.1) < x
            @test x.x-T(0.1) ≤ x
            @test x.x ≤ x
            @test x.x ≥ x
            @test x.x+T(0.1) ≥ x
            @test x.x+T(0.1) > x
        elseif x.iₓ > 0
            @test x > x.x
            @test x ≥ x.x
            @test x.x < x
            @test x.x ≤ x
        end
        for y in xnumbers[i+1:end]
            @test x ≤ y
            @test y ≥ x
            @test x < y
            @test y > x
        end
    end

    for x in xnumbers
        @test isequal(x, x)
        if x.iₓ == 0
            @test isequal(x, x.x)
            @test isequal(x.x, x)
        else
            @test !isequal(x, x.x)
            @test !isequal(x.x, x)
        end
        for y in xnumbers
            if x !== y
                @test !isequal(x, y)
            end
        end
    end

    for (i,x) in enumerate(xnumbers)
        @test !isless(x, x)
        if x.iₓ == 0
            @test !isless(x, x.x-T(0.1))
            @test !isless(x, x.x-T(0.1))
            @test !isless(x, x.x)
            @test !isless(x, x.x)
            @test isless(x, x.x+T(0.1))
            @test isless(x, x.x+T(0.1))
            @test isless(x.x-T(0.1), x)
            @test isless(x.x-T(0.1), x)
            @test !isless(x.x, x)
            @test !isless(x.x, x)
            @test !isless(x.x+T(0.1), x)
            @test !isless(x.x+T(0.1), x)
        elseif x.iₓ > 0
            @test !isless(x, x.x)
            @test !isless(x, x.x)
            @test isless(x.x, x)
        end
        for y in xnumbers[i+1:end]
            @test isless(x, y)
            @test !isless(y, x)
        end
    end

end
