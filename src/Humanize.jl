#----------------------------------------------------------------------
# Humanize.jl    https://github.com/IainNZ/Humanize.jl
# Based on jmoiron's humanize Python library (MIT licensed):
#  https://github.com/jmoiron/humanize/
# All original code is (c) Iain Dunning and MIT licensed.
#----------------------------------------------------------------------

isdefined(Base, :__precompile__) && __precompile__()

module Humanize

export datasize, timedelta, digitsep

#---------------------------------------------------------------------
const dec_suf = [" B", " kB", " MB", " GB", " TB", " PB", " EB", " ZB", " YB"]
const bin_suf = [" B", " KiB", " MiB", " GiB", " TiB", " PiB", " EiB", " ZiB", " YiB"]
const gnu_suf = ["", "K", "M", "G", "T", "P", "E", "Z", "Y"]
"""
datasize(value::Number; style=:dec, format="%.1f")

Format a number of bytes in a human-friendly format (eg. 10 kB).

style=:dec - default, decimal suffixes (kB, MB), base 10^3
style=:bin - binary suffixes (KiB, MiB), base 2^10
style=:gnu - GNU-style (ls -sh style, K, M), base 2^10
"""
function datasize(value::Number; style=:dec, format="%.1f")
    suffix  = style == :gnu ? gnu_suf : (style == :bin ? bin_suf : dec_suf)
    base    = style == :dec ? 1000.0 : 1024.0
    bytes   = float(value)
    format  = "$format%s"
    fmt_str = @eval (v,s)->@sprintf($format,v,s)
    unit    = base
    s       = suffix[1]
    for (i,s) in enumerate(suffix)
        unit = base ^ (i)
        bytes < unit && break
    end
    return fmt_str(base * bytes / unit, s)
end

#---------------------------------------------------------------------
"""
timedelta(secs::Integer)
timedelta{T<:Integer}(years::T,months::T,days::T,hours::T,mins::T,secs::T)
timedelta(dt_diff::Dates.Millisecond)
timedelta(d_diff::Dates.Day)

Format a time length in a human friendly format.

timedelta(secs::Integer)
    e.g. 3699   -> 'An hour'
timedelta{T<:Integer}(years::T,months::T,days::T,hours::T,mins::T,secs::T)
    e.g. days=1,hours=4,...     -> 'A day'
         hours=4,mins=2,...     -> '4 hours'
         years=1,months=2,...   -> '1 year, 2 months'
timedelta(dt_diff::Dates.Millisecond)
    e.g. DateTime(2014,2,3) - DateTime(2013,3,7) -> '11 months'
timedelta(d_diff::Dates.Day)
    e.g. Date(2014,3,7) - Date(2013,2,4) -> '1 year, 1 month'
"""
function timedelta(secs::Integer)
    mins   = div(  secs, 60); secs   -= 60*mins
    hours  = div(  mins, 60); mins   -= 60*hours
    days   = div( hours, 24); hours  -= 24*days
    months = div(  days, 30); days   -= 30*months
    years  = div(months, 12); months -= 12*years
    
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
# Assume nothing about magnitudes of inputs, so cast to seconds first
timedelta{T<:Integer}(years::T,months::T,days::T,hours::T,mins::T,secs::T) =
    timedelta(((((years*12+months)*30+days)*24+hours)*60+mins)*60+secs)
timedelta(dt_diff::Dates.Millisecond) = timedelta(div(Int(dt_diff),1000))
timedelta(d_diff::Dates.Day) = timedelta(Int(d_diff)*24*3600)


#---------------------------------------------------------------------
"""
digitsep(value::Integer, sep = ",", k = 3)

Convert an integer to a string, separating each 'k' digits by 'sep'.  'k'
defaults to 3, separating by thousands.  The default "," for 'sep' matches the
commonly used digit separator in the US.

digitsep(value::Integer)
    e.g. 12345678 -> "12,345,678"
digitsep(value::Integer, sep = "'")
    e.g. 12345678 -> "12'345'678"
digitsep(value::Integer, sep = "'", k = 4)
    e.g. 12345678 -> "1234'5678"
"""
function digitsep(value::Integer, sep = ",", k = 3)
    value = string(value)
    n = length(value)
    starts = reverse(collect(n:-k:1))
    groups = [value[max(x-k+1, 1):x] for x in starts]
    return join(groups, sep)
end

end