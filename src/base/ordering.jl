@inline (==)(X::XNumber{T}, Y::XNumber{S}) where {T,S} = X.iₓ==Y.iₓ && X.x==Y.x
@inline (!=)(X::XNumber{T}, Y::XNumber{S}) where {T,S} = X.iₓ!=Y.iₓ || X.x!=Y.x

@inline (<)(X::XNumber{T}, Y::XNumber{S}) where {T,S} = X.iₓ<Y.iₓ || (X.iₓ==Y.iₓ && X.x<Y.x)
@inline (<=)(X::XNumber{T}, Y::XNumber{S}) where {T,S} = X.iₓ<Y.iₓ || (X.iₓ==Y.iₓ && X.x<=Y.x)
@inline (>=)(X::XNumber{T}, Y::XNumber{S}) where {T,S} = X.iₓ>Y.iₓ || (X.iₓ==Y.iₓ && X.x>=Y.x)
@inline (>)(X::XNumber{T}, Y::XNumber{S}) where {T,S} = X.iₓ>Y.iₓ || (X.iₓ==Y.iₓ && X.x>Y.x)

@inline isequal(X::XNumber{T}, Y::XNumber{S}) where {T,S} = isequal(X.iₓ, Y.iₓ) && isequal(X.x, Y.x)
@inline isequal(X::XNumber{T}, Y::Number) where T = isequal(X.iₓ, Y)
@inline isequal(Y::Number, X::XNumber{T}) where T = isequal(X.iₓ, Y)

@inline isless(X::XNumber{T}, Y::XNumber{S}) where {T,S} = X.iₓ<Y.iₓ || (X.iₓ==Y.iₓ && isless(X.x, Y.x))
@inline isless(X::XNumber{T}, Y::Number) where T = isless(X.iₓ, Y)
@inline isless(Y::Number, X::XNumber{T}) where T = isless(X.iₓ, Y)
