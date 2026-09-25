# Operations with other real numbers, or with X-numbers of other base types,
# promote both arguments to a common X-number type first, via the fallbacks in
# Base.  The methods here therefore only need to handle a single base type.
(+)(X::XNumber) = X
function (+)(X::XNumber{T}, Y::XNumber{T}) where T
    iδ = X.iₓ - Y.iₓ
    if iδ == 0
        XNumber{T}(X.x+Y.x, X.iₓ)
    elseif iδ == 1
        XNumber{T}(X.x+Y.x*radix_inverse(X), X.iₓ)
    elseif iδ == -1
        XNumber{T}(X.x*radix_inverse(X)+Y.x, Y.iₓ)
    elseif iδ > 1
        X
    else # iδ < -1
        Y
    end
end

(-)(X::XNumber{T}) where T = XNumber{T}(-X.x, X.iₓ)
(-)(X::XNumber{T}, Y::XNumber{T}) where T = X + (-Y)

(*)(X::XNumber{T}, Y::XNumber{T}) where T = XNumber{T}(X.x*Y.x, X.iₓ+Y.iₓ)
(/)(X::XNumber{T}, Y::XNumber{T}) where T = XNumber{T}(X.x/Y.x, X.iₓ-Y.iₓ)
(\)(X::XNumber{T}, Y::XNumber{T}) where T = Y / X

(^)(X::XNumber, Y::Int) = XNumber(X.x^Y, Y*X.iₓ)

inv(X::XNumber{T}) where T = XNumber{T}(inv(X.x), -X.iₓ)

function sqrt(X::XNumber{T}) where T
    if iseven(X.iₓ)
        XNumber{T}(sqrt(X.x), X.iₓ ÷ 2)
    elseif X.iₓ > 0
        XNumber(sqrt(X.x) * radix_sqrt(X), X.iₓ ÷ 2)
    else # X.iₓ < 0
        XNumber(sqrt(X.x) / radix_sqrt(X), X.iₓ ÷ 2)
    end
end

function cbrt(X::XNumber{T}) where T
    if rem(X.iₓ, 3) == 2
        XNumber(cbrt(X.x) * radix_cbrt2(X), X.iₓ ÷ 3)
    elseif rem(X.iₓ, 3) == 1
        XNumber(cbrt(X.x) * radix_cbrt(X), X.iₓ ÷ 3)
    elseif rem(X.iₓ, 3) == -2
        XNumber(cbrt(X.x) / radix_cbrt2(X), X.iₓ ÷ 3)
    elseif rem(X.iₓ, 3) == -1
        XNumber(cbrt(X.x) / radix_cbrt(X), X.iₓ ÷ 3)
    else
        XNumber(cbrt(X.x), X.iₓ ÷ 3)
    end
end

"""
    linear_combination(f, X, g, Y)

Compute ``fX+gY``, where ``f`` and ``g`` are floating-point numbers, and ``X``
and ``Y`` are X-numbers.

Follows the routine given in Table 8 of Fukushima (2012).  The result is the
same as the normalized value of the more natural expression `f*X+g*Y`.

"""
function linear_combination(f::T, X::XNumber{T}, g::T, Y::XNumber{T}) where T
    iδ = X.iₓ - Y.iₓ
    normalize(
        if iδ == 0
            XNumber{T}(f*X.x+g*Y.x, X.iₓ)
        elseif iδ == 1
            XNumber{T}(f*X.x+g*(Y.x*radix_inverse(X)), X.iₓ)
        elseif iδ == -1
            XNumber{T}(f*(X.x*radix_inverse(X))+g*Y.x, Y.iₓ)
        elseif iδ > 1
            XNumber{T}(f*X.x, X.iₓ)
        else # iδ < 1
            XNumber{T}(g*Y.x, Y.iₓ)
        end
    )
end
