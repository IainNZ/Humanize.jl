#----------------------------------------------------------------------
# Humanize.jl    https://github.com/IainNZ/Humanize.jl
# Based on jmoiron's humanize Python library (MIT licensed):
#  https://github.com/jmoiron/humanize/
# All original code is (c) Iain Dunning and MIT licensed.
#----------------------------------------------------------------------

module Humanize

export datasize

#----------------------------------------------------------------------

const dec_suf = [" B", " kB", " MB", " GB", " TB", " PB", " EB", " ZB", " YB"]
const bin_suf = [" B", " KiB", " MiB", " GiB", " TiB", " PiB", " EiB", " ZiB", " YiB"]
const gnu_suf = ["", "K", "M", "G", "T", "P", "E", "Z", "Y"]

function datasize(value::Number; style=:dec, format="%.1f")
    """
    Format a number of bytes in a human-friendly format (eg. 10 kB).
    style=:dec - default, decimal suffixes (kB, MB), base 10^3
    style=:bin - binary suffixes (KiB, MiB), base 2^10
    style=:gnu - GNU-style (ls -sh style, K, M), base 2^10
    """

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

#----------------------------------------------------------------------


end