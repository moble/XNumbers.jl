```@meta
CurrentModule = XNumbers
```

# XNumbers

Documentation for [XNumbers](https://github.com/moble/XNumbers.jl): Extended-exponent floating-point
numbers.

This package implements "X-numbers" as described by [Fukushima
(2012)](https://doi.org/10.1007/s00190-011-0519-2) — which refined the ideas of [Smith et
al. (1981)](https://doi.org/10.1145/355934.355940).  As Fukushima explained,

> ...we represent a non-zero arbitrary real number, ``X``, by a pair of an IEEE754 floating point
> number, ``x``, and a signed integer, ``i_X``.  More specifically speaking, we choose a certain
> large power of 2 as the radix, ``B``, and regard ``x`` and ``i_X`` as the significand and the
> exponent with respect to it.  Namely, we express ``X`` as ``X = x B^{i_X}``. The major difference
> from Smith et al. (1981) is the choice of the radix...

Note that this does not increase the *precision* of floating-point operations (the number of digits
in the significand), but vastly increases the range of numbers that can be represented.  Therefore,
X-numbers are not frequently useful in numerical analysis.  Even the standard `Float64` can
represent numbers of magnitude roughly ``2^{-1022}`` to ``2^{1024}``, which is usually sufficient —
whereas the roughly 16 digits of precision can frequently be inadequate.  In such cases, it is
better to use extended-precision arithmetic, provided by packages like `DoubleFloats.jl`,
`Quadmath.jl`, `ArbNumerics.jl`, or the built-in `BigFloat` type.

Instead, X-numbers are useful in very specific cases, like the computation of Associated Legendre
Functions (ALFs) and hence (scalar) spherical harmonics of very high degree.  While the same goals
could be *partially* achieved using certain other types like `BigFloat`, X-numbers can be
implemented far more efficiently — requiring anywhere from 10% to a few times longer than similar
computations with the underlying float type.  However, see [Xing et
al. (2020)](https://doi.org/10.1007/s00190-019-01331-0) for techniques to compute ALFs using
standard float types that can be advantageous in some ways.  X-numbers might also find use in
Machine Learning, where the precision of a `Float64` is unnecessary, but the range of a `Float16`
may be too restrictive.



## Citing

See [`CITATION.bib`](https://github.com/moble/XNumbers.jl/blob/main/CITATION.bib) for the relevant
reference(s).


## API

```@index
```

```@autodocs
Modules = [XNumbers]
```
