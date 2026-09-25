module XNumbers

using Requires

export XNumber, xnumber, normalize

# Every zero is stored with `zero_exponent`, which is lower than the exponent of
# any nonzero X-number, and every infinity or NaN with `nonfinite_exponent`,
# which is higher.  Comparing exponents therefore orders magnitudes correctly
# without special cases for these values.  Finite nonzero exponents are expected
# to lie within `±max_exponent`; the margins between these constants keep the
# difference of any two exponents from overflowing an `Int`.
const zero_exponent = typemin(Int) ÷ 4
const nonfinite_exponent = typemax(Int) ÷ 4
const max_exponent = typemax(Int) ÷ 8

struct XNumber{T<:AbstractFloat} <:AbstractFloat
    x::T
    iₓ::Int
    function XNumber{T}(x, iₓ) where {T<:AbstractFloat}
        xT = convert(T, x)
        new{T}(xT, ifelse(iszero(xT), zero_exponent, ifelse(isfinite(xT), iₓ, nonfinite_exponent)))
    end
end
XNumber(x::T, iₓ) where {T<:AbstractFloat} = XNumber{T}(x, iₓ)
XNumber{T}(x::Real) where {T<:AbstractFloat} = xnumber(T(x))
# Needed to take precedence over the method in Base for Rational to AbstractFloat
XNumber{T}(x::Rational) where {T<:AbstractFloat} = xnumber(T(x))
XNumber{T}(X::XNumber{T}) where {T<:AbstractFloat} = X
function XNumber{T}(X::XNumber{S}) where {T<:AbstractFloat, S<:AbstractFloat}
    if iszero(X.x) || !isfinite(X.x)
        XNumber{T}(X.x, 0)
    else
        # Re-express the binary exponent in T's radix, folding the remainder of
        # at most half that radix into a significand in [1, 2)
        l = log2_radix(XNumber{T})
        h = l ÷ 2
        i, r = fldmod(widemul(X.iₓ, log2_radix(X)) + exponent(X.x) + h, l)
        normalize(XNumber{T}(T(significand(X.x)) * T(2)^(Int(r) - h), Int(i)))
    end
end

"""
    xnumber(x)
    xnumber(x, i)

Construct an X-number with the same base type as `x`, and normalize.  If `i` is
not included, it is assumed to be 0.

It is also possible to construct an `XNumber` explicitly as `XNumber{T}(x, i)`,
which bypasses the normalization step.  Use caution if doing so, as most
methods assume that `XNumber`s are normalized.  Zeros, infinities, and NaNs are
always given their special exponents, however `i` is chosen.

"""
function xnumber(f::T, i::Int) where {T<:AbstractFloat}
    X = normalize(XNumber{T}(f, i))
    # One step suffices unless f is very far from 1, as Float16 subnormals are
    while (Y = normalize(X)) !== X
        X = Y
    end
    X
end
xnumber(f::T) where {T<:AbstractFloat} = xnumber(f, 0)


# Radix computations
# See more specialized versions in @require section
log2_radix(::Type{XNumber{Float16}}) = 15
log2_radix(::Type{XNumber{Float32}}) = 120
log2_radix(::Type{XNumber{Float64}}) = 960
log2_radix(::Type{XNumber{T}}) where T = round(Int, 15log2(floatmax(T))/16)

radix(XT::Type{XNumber{T}}) where T = T(2)^(log2_radix(XT))
radix_inverse(XT::Type{XNumber{T}}) where T = T(2)^(-log2_radix(XT))
radix_sqrt(XT::Type{XNumber{T}}) where T = T(2)^(log2_radix(XT)//2)
radix_sqrt_inverse(XT::Type{XNumber{T}}) where T = T(2)^(-log2_radix(XT)//2)
radix_cbrt(XT::Type{XNumber{T}}) where T = T(2)^(log2_radix(XT)//3)
radix_cbrt2(XT::Type{XNumber{T}}) where T = T(2)^(2log2_radix(XT)//3)

log2_radix(::XNumber{T}) where T = log2_radix(XNumber{T})
radix(::XNumber{T}) where T = radix(XNumber{T})
radix_inverse(::XNumber{T}) where T = radix_inverse(XNumber{T})
radix_sqrt(::XNumber{T}) where T = radix_sqrt(XNumber{T})
radix_sqrt_inverse(::XNumber{T}) where T = radix_sqrt_inverse(XNumber{T})
radix_cbrt(::XNumber{T}) where T = radix_cbrt(XNumber{T})
radix_cbrt2(::XNumber{T}) where T = radix_cbrt2(XNumber{T})


"""
    normalize(x)

Normalize a weakly normalized X-number.

Follows the routine `xnorm` given in Table 7 of Fukushima (2012).

"""
function normalize(x::XNumber{T}) where T
    # subroutine xnorm(x,ix)
    # integer ix,IND
    # real*8 x,w,BIG,BIGI,BIGS,BIGSI
    # parameter (IND=960,BIG=2.d0**IND,BIGI=2.d0**(-IND))
    # parameter (BIGS=2.d0**(IND/2),BIGSI=2.d0**(-IND/2))
    # w=abs(x)
    # if(w.ge.BIGS) then
    # x=x*BIGI; ix=ix+1
    # elseif(w.lt.BIGSI) then
    # x=x*BIG; ix=ix-1
    # endif
    # return; end
    if abs(x.x) ≥ radix_sqrt(x)
        XNumber{T}(x.x*radix_inverse(x), x.iₓ+1)
    elseif abs(x.x) < radix_sqrt_inverse(x)
        XNumber{T}(x.x*radix(x), x.iₓ-1)
    else
        x
    end
end

"""
    float(x)
    Float32(x)
    Float64(x)
    Float128(x)
    Double64(x)

Convert an X-number `x` to its underlying float form.

Follows the routine `x2f` given in Table 6 of Fukushima (2012).

"""
Base.float(x::XNumber{T}) where T = T(x)
function (::Type{T})(x::XNumber) where {T<:AbstractFloat}
    if x.iₓ == 0 || iszero(x.x) || !isfinite(x.x)
        T(x.x)
    else
        # Scaling the significand, rather than x.x, keeps the intermediate value
        # in range for any T; the exponent is widened and clamped so that
        # extreme values give 0 or Inf rather than overflowing
        e = widemul(x.iₓ, log2_radix(x)) + exponent(x.x)
        ldexp(T(significand(x.x)), Int(clamp(e, typemin(Int), typemax(Int))))
    end
end


import Base: promote_rule, widen, convert
include("base/types.jl")

#import Base: hash, promote_type, string, show, parse, tryparse, eltype,

import Base: signbit, sign, abs, flipsign, copysign, significand, exponent, precision
import Base: ldexp, decompose
include("base/bits.jl")

import Base: (+), (-), (*), (/), (\), (^), inv, sqrt, cbrt
include("base/arithmetic.jl")
export linear_combination

import Base: (==), (!=), (<), (<=), (>=), (>), isequal, isless
include("base/ordering.jl")

import Base: iszero, isone, isinf, isnan, isfinite, issubnormal, isinteger, isodd, iseven
include("base/qualities.jl")

import Base: zero, one, typemax, typemin, floatmax, floatmin, maxintfloat
include("base/specialvalues.jl")
export nan, inf, posinf, neginf

# import Base: min, max, minmax, minimum, maximum
# import Base: floor, ceil, trunc, round, div, fld, cld
# import Base: rem, mod, rem2pi, mod2pi, divrem, fldmod
# import Base: BigFloat, BigInt
# import Base: Int8, Int16, Int32, Int64, Int128
# import Base: Float64, Float32, Float16

# import Base.Math: modf, fma, muladd
# import Base.Math: log, log1p, log2, log10, exp, expm1, exp2, exp10
# import Base.Math: sin, cos, tan, csc, sec, cot, cis, sincos
# import Base.Math: asin, acos, atan, acsc, asec, acot
# import Base.Math: sinh, cosh, tanh, csch, sech, coth
# import Base.Math: asinh, acosh, atanh, acsch, asech, acoth
import Base.Math: log2
import Base.Math: sinpi, cospi, sincospi, cispi
include("base/math.jl")


function __init__()
    @require Quadmath="be4d8f0f-7fa4-5f49-b795-2f01399ab2dd" begin
        log2_radix(::Type{XNumber{Float128}}) = 16_000
    end
    @require DoubleFloats="497a8b3b-efae-58df-a0af-a86822472b78" begin
        log2_radix(::Type{XNumber{Double64}}) = log2_radix(XNumber{Float64})
    end
end


end
