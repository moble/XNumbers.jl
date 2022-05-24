@inline (==)(X::XNumber{T}, Y::XNumber{S}) where {T,S} = X.iₓ==Y.iₓ && X.x==Y.x
@inline (!=)(X::XNumber{T}, Y::XNumber{S}) where {T,S} = X.iₓ!=Y.iₓ || X.x!=Y.x

@inline (<)(X::XNumber{T}, Y::XNumber{S}) where {T,S} = X.iₓ<Y.iₓ || (X.iₓ==Y.iₓ && X.x<Y.x)
@inline (<=)(X::XNumber{T}, Y::XNumber{S}) where {T,S} = X.iₓ<Y.iₓ || (X.iₓ==Y.iₓ && X.x<=Y.x)
@inline (>=)(X::XNumber{T}, Y::XNumber{S}) where {T,S} = X.iₓ>Y.iₓ || (X.iₓ==Y.iₓ && X.x>=Y.x)
@inline (>)(X::XNumber{T}, Y::XNumber{S}) where {T,S} = X.iₓ>Y.iₓ || (X.iₓ==Y.iₓ && X.x>Y.x)

@inline isequal(X::XNumber{T}, Y::XNumber{S}) where {T,S} = isequal(X.iₓ, Y.iₓ) && isequal(X.x, Y.x)
@inline isequal(X::XNumber{T}, Y::Real) where T = X.iₓ==0 && isequal(X.x, Y)
@inline isequal(Y::Real, X::XNumber{T}) where T = X.iₓ==0 && isequal(X.x, Y)

@inline isless(X::XNumber{T}, Y::XNumber{S}) where {T,S} = X.iₓ<Y.iₓ || (X.iₓ==Y.iₓ && isless(X.x, Y.x))
@inline isless(X::XNumber{T}, Y::Real) where T = X.iₓ<0 || (X.iₓ==0 && isless(X.x, Y))
@inline isless(Y::Real, X::XNumber{T}) where T = X.iₓ>0 || (X.iₓ==0 && isless(Y, X.x))
