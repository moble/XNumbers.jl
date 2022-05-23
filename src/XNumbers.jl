module XNumbers

using Requires

struct XNumber{T<:AbstractFloat} <:AbstractFloat
    x::T
    iₓ::Int
end
XNumber{T}(x::T) where T = XNumber{T}(x, 0)


# Radix computations
# See more specialized versions in @require section
log2_radix(::Type{XNumber{Float32}}) = 120
log2_radix(::Type{XNumber{Float64}}) = 960
log2_radix(::Type{XNumber{T}}) where T = round(Int, 15log2(floatmax(T))/16)

radix(XT::Type{XNumber{T}}) where T = 2^T(log2_radix(XT))
radix_inverse(XT::Type{XNumber{T}}) where T = 2^T(-log2_radix(XT))
radix_sqrt(XT::Type{XNumber{T}}) where T = 2^T(log2_radix(XT)÷2)
radix_sqrt_inverse(XT::Type{XNumber{T}}) where T = 2^T(-log2_radix(XT)÷2)
radix_cbrt(XT::Type{XNumber{T}}) where T = 2^(T(log2_radix(XT))/3)
radix_cbrt2(XT::Type{XNumber{T}}) where T = 2^(2T(log2_radix(XT))/3)

log2_radix(::XNumber{T}) where T = log2_radix(XNumber{T})
radix(::XNumber{T}) where T = radix(XNumber{T})
radix_inverse(::XNumber{T}) where T = radix_inverse(XNumber{T})
radix_sqrt(::XNumber{T}) where T = radix_sqrt(XNumber{T})
radix_sqrt_inverse(::XNumber{T}) where T = radix_sqrt_inverse(XNumber{T})
radix_cbrt(::XNumber{T}) where T = radix_cbrt(XNumber{T})
radix_cbrt2(::XNumber{T}) where T = radix_cbrt2(XNumber{T})


"""
    XNumber(x)
    XNumber(x, i)

Construct an X-number with the same base type as `x`, and normalize.  If `i` is
not included, it is assumed to be 0.

It is also possible to construct an `XNumber` explicitly as `XNumber{T}(x, i)`,
which bypasses the normalization step.  Use caution if doing so, as most
methods assume that `XNumber`s are normalized.

"""
function XNumber(f::T, i::Int) where T
    if abs(f) ≥ radix_sqrt(XNumber{T})
        XNumber{T}(f*radix_inverse(XNumber{T}), i+log2_radix(XNumber{T}))
    elseif abs(f) < radix_sqrt_inverse(XNumber{T})
        XNumber{T}(f*radix(XNumber{T}), i-log2_radix(XNumber{T}))
    else
        XNumber{T}(f, i)
    end
end
XNumber(f::T) where T = XNumber(f, 0)


"""
    float(x)
    Float32(x)
    Float64(x)
    Float128(x)
    Double64(x)

Convert an X-number `x` to its underlying float form.

Follows the routine given in Table 6 of Fukushima (2012).

"""
float(x::XNumber{T}) where T = T(x)
function (::Type{T})(x::XNumber{T}) where T
    if x.iₓ == 0
        x.x
    elseif x.iₓ > 0
        x.x * radix(x)
    else # x.iₓ < 0
        x.x * radix_inverse(x)
    end
end


"""
    normalize(x)

Normalize a weakly normalized X-number.

Follows the routine given in Table 7 of Fukushima (2012).

"""
function normalize(x::XNumber{T}) where T
    if abs(x.x) ≥ radix_sqrt(x)
        XNumber{T}(x.x*radix_inverse(x), x.iₓ+1)
    elseif abs(x.x) < radix_sqrt_inverse(x)
        XNumber{T}(x.x*radix(x), x.iₓ-1)
    else
        x
    end
end


import Base: promote_rule, widen, convert
include("base/types.jl")

#import Base: hash, promote_type, string, show, parse, tryparse, eltype,

import Base: signbit, sign, abs, flipsign, copysign, significand, exponent, precision,
include("base/bits.jl")

import Base: (+), (-), (*), (/), (\), (^), inv, sqrt, cbrt
include("base/arithmetic.jl")
export linear_combination

import Base: (==), (!=), (<), (<=), (>=), (>), isequal, isless
include("base/ordering.jl")

import Base: iszero, isone, isinf, isnan, isinf, isfinite, issubnormal, isinteger, isodd, iseven
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
