var documenterSearchIndex = {"docs":
[{"location":"","page":"Home","title":"Home","text":"CurrentModule = XNumbers","category":"page"},{"location":"#XNumbers","page":"Home","title":"XNumbers","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Documentation for XNumbers: Extended-exponent floating-point numbers.","category":"page"},{"location":"","page":"Home","title":"Home","text":"This package implements \"X-numbers\" as described by Fukushima (2012) — which refined the ideas of Smith et al. (1981).  As Fukushima explained,","category":"page"},{"location":"","page":"Home","title":"Home","text":"...we represent a non-zero arbitrary real number, X, by a pair of an IEEE754 floating point number, x, and a signed integer, i_X.  More specifically speaking, we choose a certain large power of 2 as the radix, B, and regard x and i_X as the significand and the exponent with respect to it.  Namely, we express X as X = x B^i_X. The major difference from Smith et al. (1981) is the choice of the radix...","category":"page"},{"location":"","page":"Home","title":"Home","text":"Note that this does not increase the precision of floating-point operations (the number of digits in the significand), but vastly increases the range of numbers that can be represented.  Therefore, X-numbers are not frequently useful in numerical analysis.  Even the standard Float64 can represent numbers of magnitude roughly 2^-1022 to 2^1024, which is usually sufficient — whereas the roughly 16 digits of precision can frequently be inadequate.  In such cases, it is better to use extended-precision arithmetic, provided by packages like DoubleFloats.jl, Quadmath.jl, ArbNumerics.jl, or the built-in BigFloat type.","category":"page"},{"location":"","page":"Home","title":"Home","text":"Instead, X-numbers are useful in very specific cases, like the computation of Associated Legendre Functions (ALFs) and hence (scalar) spherical harmonics of very high degree.  While the same goals could be partially achieved using certain other types like BigFloat, X-numbers can be implemented far more efficiently — requiring anywhere from 10% to a few times longer than similar computations with the underlying float type.  However, see Xing et al. (2020) for techniques to compute ALFs using standard float types that can be advantageous in some ways.  X-numbers might also find use in Machine Learning, where the precision of a Float64 is unnecessary, but the range of a Float16 may be too restrictive.","category":"page"},{"location":"#Citing","page":"Home","title":"Citing","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"See CITATION.bib for the relevant reference(s).","category":"page"},{"location":"#API","page":"Home","title":"API","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"Modules = [XNumbers]","category":"page"},{"location":"#XNumbers.XNumber-Union{Tuple{T}, Tuple{T, Int64}} where T<:AbstractFloat","page":"Home","title":"XNumbers.XNumber","text":"XNumber(x)\nXNumber(x, i)\n\nConstruct an X-number with the same base type as x, and normalize.  If i is not included, it is assumed to be 0.\n\nIt is also possible to construct an XNumber explicitly as XNumber{T}(x, i), which bypasses the normalization step.  Use caution if doing so, as most methods assume that XNumbers are normalized.\n\n\n\n\n\n","category":"method"},{"location":"#XNumbers.float-Union{Tuple{XNumber{T}}, Tuple{T}} where T","page":"Home","title":"XNumbers.float","text":"float(x)\nFloat32(x)\nFloat64(x)\nFloat128(x)\nDouble64(x)\n\nConvert an X-number x to its underlying float form.\n\nFollows the routine given in Table 6 of Fukushima (2012).\n\n\n\n\n\n","category":"method"},{"location":"#XNumbers.linear_combination-Union{Tuple{T}, Tuple{T, XNumber{T}, T, XNumber{T}}} where T","page":"Home","title":"XNumbers.linear_combination","text":"linear_combination(f, X, g, Y)\n\nCompute fX+gY, where f and g are floating-point numbers, and X and Y are X-numbers.\n\nFollows the routine given in Table 8 of Fukushima (2012).\n\n\n\n\n\n","category":"method"},{"location":"#XNumbers.normalize-Union{Tuple{XNumber{T}}, Tuple{T}} where T","page":"Home","title":"XNumbers.normalize","text":"normalize(x)\n\nNormalize a weakly normalized X-number.\n\nFollows the routine given in Table 7 of Fukushima (2012).\n\n\n\n\n\n","category":"method"}]
}
