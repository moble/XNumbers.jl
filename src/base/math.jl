# The exponent is widened so that it cannot overflow; for a zero it is finite,
# and log2(X.x) = -Inf still dominates.
log2(X::XNumber{T}) where T = log2(X.x) + T(widemul(X.iₓ, log2_radix(X)))

# A value of type T that differs from X by an even integer, and so has the same
# sinpi and cospi.  Only meaningful for X with a nonnegative exponent.  A finite
# X with a positive exponent is an even integer unless its significand has bits
# worth less than 2, which can only happen when the exponent is 1, since
# precision(T) is far smaller than log2_radix for every supported T.
function reduce_mod_2(X::XNumber{T}) where T
    if X.iₓ == 0 || !isfinite(X.x)
        X.x
    elseif X.iₓ == 1 && exponent(X.x) + log2_radix(X) < precision(T)
        rem(X.x, 2radix_inverse(X)) * radix(X)
    else
        copysign(zero(T), X.x)
    end
end

# For a negative exponent, |X| < radix^(-1/2), so the relative size of the
# neglected terms in sinpi(X) ≈ πX and cospi(X) ≈ 1 is below 1/radix, which is
# well below eps(T).
sinpi(X::XNumber{T}) where T = X.iₓ < 0 ? normalize(X * T(π)) : xnumber(sinpi(reduce_mod_2(X)))
cospi(X::XNumber{T}) where T = X.iₓ < 0 ? one(XNumber{T}) : xnumber(cospi(reduce_mod_2(X)))
sincospi(X::XNumber) = (sinpi(X), cospi(X))
cispi(X::XNumber) = Complex(cospi(X), sinpi(X))
