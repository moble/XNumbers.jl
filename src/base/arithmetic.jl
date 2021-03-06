(+)(X::XNumber) = X
function (+)(X::XNumber{T}, Y::XNumber{S}) where {T, S}
    TS = promote_type(T, S)
    if (!iszero(X.x) && X.iₓ > Y.iₓ) || iszero(Y.x)
        XNumber{TS}(TS(X.x), X.iₓ)
    elseif Y.iₓ > X.iₓ || iszero(X.x)
        XNumber{TS}(TS(Y.x), Y.iₓ)
    else
        XNumber(X.x+Y.x, X.iₓ)
    end
end
function (+)(X::XNumber{T}, Y::S) where {T, S<:Union{Real, AbstractFloat}}
    TS = promote_type(T, S)
    if X.iₓ > 0 || iszero(Y)
        XNumber{TS}(TS(X.x), X.iₓ)
    elseif X.iₓ < 0
        XNumber{TS}(TS(Y), 0)
    else
        XNumber(X.x+Y, 0)
    end
end
(+)(Y::S, X::XNumber{T}) where {T, S<:Union{Real, AbstractFloat}} = X+Y

(-)(X::XNumber{T}) where T = XNumber{T}(-X.x, X.iₓ)
function (-)(X::XNumber{T}, Y::XNumber{S}) where {T, S}
    TS = promote_type(T, S)
    if (!iszero(X.x) && X.iₓ > Y.iₓ) || iszero(Y.x)
        XNumber{TS}(TS(X.x), X.iₓ)
    elseif Y.iₓ > X.iₓ || iszero(X.x)
        XNumber{TS}(-TS(Y.x), Y.iₓ)
    else
        XNumber(X.x-Y.x, X.iₓ)
    end
end
function (-)(X::XNumber{T}, Y::S) where {T, S<:Union{Real, AbstractFloat}}
    TS = promote_type(T, S)
    if X.iₓ > 0 || iszero(Y)
        XNumber{TS}(TS(X.x), X.iₓ)
    elseif X.iₓ < 0
        XNumber{TS}(-TS(Y), 0)
    else
        XNumber(X.x-Y, 0)
    end
end
function (-)(Y::S, X::XNumber{T}) where {T, S<:Union{Real, AbstractFloat}}
    TS = promote_type(T, S)
    if X.iₓ > 0 || iszero(Y)
        XNumber{TS}(-TS(X.x), X.iₓ)
    elseif X.iₓ < 0
        XNumber{TS}(TS(Y), 0)
    else
        XNumber(Y-X.x, 0)
    end
end

(*)(X::XNumber, Y::XNumber) = XNumber(X.x*Y.x, X.iₓ+Y.iₓ)
(*)(X::XNumber, Y::S) where {S<:Union{Real, AbstractFloat}} = XNumber(X.x*Y, X.iₓ)
(*)(Y::S, X::XNumber) where {S<:Union{Real, AbstractFloat}} = XNumber(X.x*Y, X.iₓ)

(/)(X::XNumber, Y::XNumber) = XNumber(X.x/Y.x, X.iₓ-Y.iₓ)
(/)(X::XNumber, Y::S) where {S<:Union{Real, AbstractFloat}} = XNumber(X.x/Y, X.iₓ)
(/)(Y::S, X::XNumber) where {S<:Union{Real, AbstractFloat}} = XNumber(Y/X.x, -X.iₓ)

(\)(X::XNumber, Y::XNumber) = XNumber(Y.x/X.x, Y.iₓ-X.iₓ)
(\)(X::XNumber, Y::S) where {S<:Union{Real, AbstractFloat}} = XNumber(Y/X.x, -X.iₓ)
(\)(X::S, Y::XNumber) where {S<:Union{Real, AbstractFloat}} = XNumber(Y.x/X, Y.iₓ)

(^)(X::XNumber, Y::Int) = XNumber(X.x^Y, Y*X.iₓ)

inv(X::XNumber{T}) where T = XNumber{T}(inv(X.x), -X.iₓ)

function sqrt(X::XNumber{T}) where T
    if iseven(X.iₓ)
        XNumber{T}(sqrt(X.x), X.iₓ ÷ 2)
    elseif X.iₓ > 0
        XNumber(sqrt(X.x) * radix_sqrt(X), X.iₓ ÷ 2)
    else # X.iₓ > 0
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

Follows the routine given in Table 8 of Fukushima (2012).

!!! warning "Use with caution!"

    This routine — translated from Fukushima's Fortran code — does not account
    for the possibility that X or Y may be zero.  It may be better to just use
    the more natural expression `f*X+g*Y`.

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
