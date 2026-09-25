# For normalized X-numbers, a larger exponent means a larger magnitude, so when
# the exponents differ the sign of the larger-magnitude number decides the
# order.  Zeros and non-finite values have extreme exponents, so they need no
# special cases, except that NaN must be compared as a float to stay unordered.
# As in arithmetic.jl, comparisons with other types go through promotion.
@inline (==)(X::XNumber{T}, Y::XNumber{T}) where T = X.iₓ==Y.iₓ && X.x==Y.x

@inline function (<)(X::XNumber{T}, Y::XNumber{T}) where T
    if X.iₓ == Y.iₓ || isnan(X.x) || isnan(Y.x)
        X.x < Y.x
    elseif X.iₓ > Y.iₓ
        X.x < 0
    else
        Y.x > 0
    end
end
@inline (<=)(X::XNumber{T}, Y::XNumber{T}) where T = X < Y || X == Y

@inline isequal(X::XNumber{T}, Y::XNumber{T}) where T = isequal(X.iₓ, Y.iₓ) && isequal(X.x, Y.x)

@inline function isless(X::XNumber{T}, Y::XNumber{T}) where T
    if X.iₓ == Y.iₓ || isnan(X.x) || isnan(Y.x)
        isless(X.x, Y.x)
    elseif X.iₓ > Y.iₓ
        isless(X.x, zero(X.x))
    else
        isless(zero(Y.x), Y.x)
    end
end
