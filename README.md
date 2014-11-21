Humanize.jl
===========

[![Build Status](https://travis-ci.org/IainNZ/Humanize.jl.svg)](https://travis-ci.org/IainNZ/Humanize.jl)
[![Coverage Status](https://img.shields.io/coveralls/IainNZ/Humanize.jl.svg)](https://coveralls.io/r/IainNZ/Humanize.jl)
[![Humanize](http://pkg.julialang.org/badges/Humanize_release.svg)](http://pkg.julialang.org/?pkg=Humanize&ver=release)

Humanize numbers, including
* data sizes (`3e6 -> 3.0 MB or 2.9 MiB`).
* Date/datetime differences (`Date(2014,2,3) - Date(2013,3,7) -> 1 year, 1 month`)
* Digit separator (`12345678 -> 12,345,678`)

This package is MIT licensed, and is based on [jmoiron's humanize Python library](https://github.com/jmoiron/humanize/).

**Installation:** `Pkg.add("Humanize")`

## Documentation

### Data sizes

```julia
datasize(value::Number; style=:dec, format="%.1f")
```

Style can be `:dec` (base 10^3), `:bin` (base 2^10), `:gnu` (base 2^10, like `ls -hs`).

```julia
julia> datasize(3000000)
"3.0 MB"
julia> datasize(3000000, style=:bin, format="%.3f")
"2.861 MiB"
julia> datasize(3000000, style=:gnu, format="%.3f")
"2.861M"
```

### Date/datetime differences

```julia
timedelta(secs::Integer)
timedelta{T<:Integer}(years::T,months::T,days::T,hours::T,mins::T,secs::T)
timedelta(dt_diff::Dates.Millisecond)
timedelta(d_diff::Dates.Day)
```

Turns a date/datetime difference into a abbreviated human-friendly form.
Supports the types defined by `Dates.jl` on Julia 0.3, `Base.Dates` on Julia 0.4.

```julia
julia> timedelta(70)
"a minute"
julia> timedelta(0,0,0,23,50,50)
"23 hours"
julia> timedelta(DateTime(2014,2,3,12,11,10) - 
                    DateTime(2013,3,7,13,1,20))
"11 months"
julia> timedelta(Date(2014,3,7) - Date(2013,2,4))
"1 year, 1 month"
```

### Digit separator

```julia
julia> digitsep(12345678)
"12,345,678"
julia> digitsep(12345678, sep = "'")
"12'345'678"
julia> digitsep(12345678, sep = "-", k = 4)
"1234-5678"
```
