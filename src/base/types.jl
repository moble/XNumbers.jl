promote_rule(::Type{XNumber{T}}, ::Type{XNumber{S}}) where {T,S} = XNumber{promote_rule(T, S)}
promote_rule(::Type{XNumber{T}}, ::Type{S}) where {T, S<:Real} = XNumber{promote_rule(T, S)}
promote_rule(::Type{XNumber{T}}, ::Type{I}) where {T, I<:Integer} = XNumber{T}
widen(::Type{XNumber{T}}) where T = XNumber{widen(T)}
