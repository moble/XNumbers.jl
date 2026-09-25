zero(::Type{XNumber{T}}) where T = XNumber{T}(zero(T), 0)
one(::Type{XNumber{T}}) where T = XNumber{T}(one(T), 0)

nan(::Type{XNumber{T}}) where T = XNumber{T}(T(NaN), 0)
inf(::Type{XNumber{T}}) where T = XNumber{T}(T(Inf), 0)
posinf(::Type{XNumber{T}}) where T = XNumber{T}(T(Inf), 0)
neginf(::Type{XNumber{T}}) where T = XNumber{T}(T(-Inf), 0)

typemax(::Type{XNumber{T}}) where T = XNumber{T}(typemax(T), 0)
typemin(::Type{XNumber{T}}) where T = XNumber{T}(typemin(T), 0)

floatmin(XT::Type{XNumber{T}}) where T = XNumber{T}(radix_sqrt_inverse(XT), -max_exponent)
floatmax(XT::Type{XNumber{T}}) where T = XNumber{T}(prevfloat(radix_sqrt(XT)), max_exponent)
floatmin(::XNumber{T}) where T = floatmin(XNumber{T})
floatmax(::XNumber{T}) where T = floatmax(XNumber{T})

maxintfloat(::Type{XNumber{T}}) where T = xnumber(maxintfloat(T))
