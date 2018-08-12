Humanize.jl
===========

[![Build Status](https://travis-ci.org/IainNZ/Humanize.jl.svg?branch=master)](https://travis-ci.org/IainNZ/Humanize.jl)

Humanize numbers, including
* data sizes (`3e6 -> 3.0 MB or 2.9 MiB`).
* Date/datetime differences (`Date(2014,2,3) - Date(2013,3,7) -> 1 year, 1 month`)
* Digit separator (`12345678 -> 12,345,678`)

This package is MIT licensed, and is based on [jmoiron's humanize Python library](https://github.com/jmoiron/humanize/).


### Data sizes

```julia
datasize(value::Number; style=:dec, format="%.1f")
```

Style can be
 `:dec` (base 10^3), `:bin` (base 2^10), `:gnu` (base 2^10, like `ls -hs`).

```julia
import Humanize: datasize
datasize(3000000)  # "3.0 MB"
datasize(3000000, style=:bin, format="%.3f")  # "2.861 MiB"
datasize(3000000, style=:gnu, format="%.3f")  # "2.861M"
```

### Date/datetime differences

```julia
timedelta(seconds::Integer)
timedelta(seconds::Dates.Second)
timedelta(Δdt::Dates.Millisecond)
timedelta(Δdate::Dates.Day)
```

Turns a date/datetime difference into a abbreviated human-friendly form.

```julia
import Humanize: timedelta
timedelta(70)  # "a minute"
import Dates: DateTime, Date
timedelta(DateTime(2014,2,3,12,11,10) - 
            DateTime(2013,3,7,13,1,20))  # "11 months"
timedelta(Date(2014,3,7) - Date(2013,2,4))  # "1 year, 1 month"
```

### Digit separator

```julia
digitsep(value::Integer; separator=",", per_separator=3)
```

Convert an integer to a string, separating each `per_separator` digits by
`separator`.

```julia
import Humanize: digitsep
digitsep(12345678)  # "12,345,678"
digitsep(12345678, seperator= "'")  # "12'345'678"
digitsep(12345678, seperator= "-", per_separator=4)  # "1234-5678"
```