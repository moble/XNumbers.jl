promote_rule(::Type{XNumber{T}}, ::Type{XNumber{S}}) where {T,S} = XNumber{promote_type(T, S)}
promote_rule(::Type{XNumber{T}}, ::Type{S}) where {T, S<:Real} = XNumber{promote_type(T, S)}
promote_rule(::Type{XNumber{T}}, ::Type{I}) where {T, I<:Integer} = XNumber{T}
# BigFloat claims promotion with every Real, so both directions must be given
promote_rule(::Type{XNumber{T}}, ::Type{BigFloat}) where T = XNumber{BigFloat}
promote_rule(::Type{BigFloat}, ::Type{XNumber{T}}) where T = XNumber{BigFloat}
widen(::Type{XNumber{T}}) where T = XNumber{widen(T)}
