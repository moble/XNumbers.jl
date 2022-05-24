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
