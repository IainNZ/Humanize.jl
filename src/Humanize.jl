# Humanize.jl
# https://github.com/IainNZ/Humanize.jl
# Based on jmoiron's humanize Python library (MIT licensed):
#  https://github.com/jmoiron/humanize/
# All original code is (c) Iain Dunning and MIT licensed.

__precompile__()

module Humanize

import Dates
import Printf: @sprintf

const SUFFIXES = Dict(
    :dec => [" B", " kB", " MB", " GB", " TB", " PB", " EB", " ZB", " YB"],
    :bin => [" B", " KiB", " MiB", " GiB", " TiB", " PiB", " EiB", " ZiB", " YiB"],
    :gnu => ["", "K", "M", "G", "T", "P", "E", "Z", "Y"]
)
const BASES = Dict(:dec => 1000, :bin => 1024, :gnu => 1024)

"""
    datasize(value::Number; style=:dec, format="%.1f")

Format a number of bytes in a human-friendly format (eg. 10 kB).

    style=:dec - default, decimal suffixes (kB, MB), base 10^3
    style=:bin - binary suffixes (KiB, MiB), base 2^10
    style=:gnu - GNU-style (ls -sh style, K, M), base 2^10
"""
function datasize(value::Number; style=:dec, format="%.1f")::String
    suffix = SUFFIXES[style]
    base = float(BASES[style])
    bytes = float(value)
    unit = base
    biggest_suffix = suffix[1]
    for power in 1:length(suffix)
        unit = base^power
        biggest_suffix = suffix[power]
        bytes < unit && break
    end
    value = base * bytes / unit
    format = "$format%s"
    return @eval @sprintf($format, $value, $biggest_suffix)
end


"""
    timedelta(seconds::Integer)
    timedelta(seconds::Dates.Second)
    timedelta(Δdt::Dates.Millisecond)
    timedelta(Δdate::Dates.Day)

Turns a date/datetime difference into a abbreviated human-friendly form.

    timedelta(70)  # "a minute"
    timedelta(DateTime(2014,2,3,12,11,10) - 
                DateTime(2013,3,7,13,1,20))  # "11 months"
    timedelta(Date(2014,3,7) - Date(2013,2,4))  # "1 year, 1 month"
"""
function timedelta(seconds::Integer)
    secs   = seconds
    mins   = div(secs, 60); secs -= 60 * mins
    hours  = div(mins, 60); mins -= 60 * hours
    days   = div(hours, 24); hours -= 24 * days
    months = div(days, 30); days -= 30 * months
    years  = div(months, 12); months -= 12 * years
    
    if years == 0
        if days == 0 && months == 0
            hours >= 1 && return hours == 1 ? "an hour"  : "$hours hours"
            mins  >= 1 && return mins  == 1 ? "a minute" : "$mins minutes"
            secs  >= 1 && return secs  == 1 ? "a second" : "$secs seconds"
            return "a moment"
        end
        months == 0 && return days == 1 ? "a day" : "$days days"
        return months == 1 ? "a month" : "$months months"
    elseif years == 1
        months == 0 && return "a year"
        months == 1 && return "1 year, 1 month"
        return "1 year, $months months"
    else
        return "$years years"
    end
end
timedelta(seconds::Dates.Second) = timedelta(seconds.value)
timedelta(Δdt::Dates.Millisecond) = timedelta(convert(Dates.Second, Δdt))
timedelta(Δdate::Dates.Day) = timedelta(convert(Dates.Second, Δdate))


"""
    digitsep(value::Integer; separator=",", per_separator=3)

Convert an integer to a string, separating each `per_separator` digits by
`separator`.

    digitsep(12345678)  # "12,345,678"
    digitsep(12345678, seperator= "'")  # "12'345'678"
    digitsep(12345678, seperator= "-", per_separator=4)  # "1234-5678"
"""
function digitsep(value::Integer; seperator=",", per_separator=3)
    isnegative = value < zero(value)
    value = string(abs(value))  # Stringify, no seperators.
    # Figure out last character index of each group of digits.
    group_ends = reverse(collect(length(value):-per_separator:1))
    groups = [value[max(end_index - per_separator + 1, 1):end_index]
              for end_index in group_ends]
    return (isnegative ? "-" : "") * join(groups, seperator)
end

end  # module Humanize.
