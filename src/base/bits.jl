signbit(x::XNumber{T}) where T = signbit(x.x)
sign(x::XNumber{T}) where T = sign(x.x)
abs(x::XNumber{T}) where T = XNumber{T}(abs(x.x), x.iₓ)
#flipsign(x::XNumber{T}) where T = 
#copysign(x::XNumber{T}, y) where T = 
significand(x::XNumber{T}) where T = significand(x.x)
exponent(x::XNumber{T}) where T = exponent(x.x) + x.iₓ
precision(x::XNumber{T}) where T = precision(x.x)
