signbit(x::XNumber{T}) where T = signbit(x.x)
sign(x::XNumber{T}) where T = sign(x.x)
abs(x::XNumber{T}) where T = XNumber{T}(abs(x.x), x.iₓ)
#flipsign(x::XNumber{T}) where T = 
#copysign(x::XNumber{T}, y) where T = 
significand(x::XNumber{T}) where T = significand(x.x)
exponent(x::XNumber{T}) where T = Base.checked_add(exponent(x.x), Base.checked_mul(x.iₓ, log2_radix(x)))
precision(x::XNumber{T}) where T = precision(x.x)

# These let the generic methods in Base for comparing floats with rationals, and
# for hashing reals, work exactly for X-numbers
function ldexp(x::XNumber{T}, n::Integer) where T
    # Scale the significand by at most half the radix, then renormalize
    l = log2_radix(x)
    h = l ÷ 2
    q, r = fldmod(n + h, l)
    normalize(XNumber{T}(ldexp(x.x, Int(r) - h), x.iₓ + Int(q)))
end
function decompose(x::XNumber{T}) where T
    n, p, d = decompose(x.x)
    if iszero(x.x) || !isfinite(x.x)
        n, p, d
    else
        n, Base.checked_add(p, Base.checked_mul(x.iₓ, log2_radix(x))), d
    end
end
