zero(::Type{XNumber{T}}) where T = XNumber{T}(zero(T), zero(T))
one(::Type{XNumber{T}}) where T = XNumber{T}(one(T), zero(T))

nan(::Type{XNumber{T}}) where T = XNumber{T}(T(NaN), 0)
inf(::Type{XNumber{T}}) where T = XNumber{T}(T(Inf), 0)
posinf(::Type{XNumber{T}}) where T = XNumber{T}(T(Inf), 0)
neginf(::Type{XNumber{T}}) where T = XNumber{T}(T(-Inf), 0)

typemax(::Type{XNumber{T}}) where T = XNumber{T}(typemax(T), typemax(Int))
typemin(::Type{XNumber{T}}) where T = XNumber{T}(typemin(T), 0)

floatmin(x::XNumber{T}) where T = XNumber{T}(radix_inverse(x), typemin(Int))
floatmax(x::XNumber{T}) where T = XNumber{T}(prevfloat(radix(x)), typemax(Int))

maxintfloat(::Type{XNumber{T}}) where T = XNumber{T}(maxintfloat(T), typemax(Int))
