# Print numbers nicely. For example,
# 1988.12345678 gets printed as "1.988⋅10³"

############################
#                          #
#      Default options     #
#                          #
############################

const max_int_len = 5
const max_whole_part_len = 3
const max_decimals = 3

############################
#                          #
#         Unicode          #
#                          #
############################

const supers = [  '⁰'; '¹'; '²'
                ; '³'; '⁴'; '⁵'
                ; '⁶'; '⁷'; '⁸'
                ; '⁹']

const superminus = '⁻'

############################
#                          #
#        Functions         #
#                          #
############################

# Get mantissa and exponent

exponent(x::Number) = floor(Int64,log10(abs(x)))

function mantissa(x::Number)
    for i in 1:abs(exponent(x))
        if sign(exponent(x)) == +1
        x /= 10.0
        else
        x *= 10.0
        end
    end
    return x
end

# Superindex generator

function integer_to_sup(x::Integer)
    str = dec(abs(x))
    L = length(str)
    sups = Array(Char,L)
    for i in 1:L
        c = str[i]
        n = Int64(c) - 48
        sups[i] = supers[n+1]
    end
    result = String(sups)
    if x > 0
        return result
    else
        return "$superminus$result"
    end
end

# Pretty print in scientific notation
function scientific(x::Number; l=:full, hideexp=true)
    m = mantissa(abs(x)) |> string
    # Sign will be added later.
    if l == :full
        mstr = m[1:end]
    elseif l == 0
        mstr = m[1]
    elseif l ≥ 1
        # - 2 because the first number and the point.
        if l > length(m) - 2 # needs padding
            pad = fill('0',l-length(m)+2) |> join
            mstr = string(m,pad)
        else
            mstr = string(m)[1:l+2]
        end
    else
        error("l ∉ [0,∞). Use :full for all places")
    end
    expstr = x |> exponent |> integer_to_sup
    if x < 0
        mstr = string('-',mstr)
    end
    if hideexp && exponent(x) == 0
        return string(mstr)
    else
        return string(mstr,"⋅10",expstr)
    end
end

# Number of significant digits. 1.420 has 4, for
# example. 0.0540 has 3.
function sig_digits(x::AbstractString)
    # remove sign and exponent
    x = replace(x,r"e.*","")
    x = replace(x,"+","")
    x = replace(x,"-","")
    # remove leading zeroes and possible dot
    x = replace(x,r"^0*\.?0*","")
    # remove point so we dont count it as character
    x = replace(x,".","")
    return length(x)
end
sig_digits(x::Number) = x |> string |> sig_digits


"""
    nicenumber(x::Number)

Change `x` by a nice looking number. Returns a string.
"""
function nicenumber(x::Number)
    if isinteger(x) && exponent(x) < max_int_len
        char_size = exponent(x) + 1
        if char_size ≤ max_int_len
            return @sprintf("%d",x)
        else # Scientific notation
            return scientific(x,l=0)
        end
    else # It's a float
        whole = floor(x)
        decimal = x - floor(x)
        whole_part_len = @sprintf("%d",abs(whole)) |> length
        decimal_part_len = sig_digits(x) - whole_part_len
        # Small enough, don't touch it.
        if whole_part_len ≤ max_whole_part_len && round(x,max_decimals) ≠ 0
            if decimal_part_len ≤ max_decimals
                return string(x)
            else #truncate decimals
                return round(x, max_decimals) |> string
            end
        elseif x / 10.0^exponent(x) ≈ round(mantissa(x))
            # Just an "int". Does not need decimals.
            # An example is 5e-5, is just 5⋅10⁻⁵.
            superindex = x |> exponent |> integer_to_sup
            whole = round(x / 10.0^exponent(x))
            return @sprintf("%d⋅10%s",mantissa(x) ,superindex)
        else # Too big and not an pseudoint. To scientific.
            dec_places = min(sig_digits(x)-1, max_decimals)
            return scientific(x,l=dec_places)
        end
    end
end

# This function transforms a string into a nice
# looking one, by changing all his numbers to
# pretty ones.
"""
    nicenumber(str::AbstractString)

Change all the numbers in str by nice looking ones.
"""
function nicenumber(str::AbstractString)
    # Search for numbers in the string, and
    # substitute them.
    num_r = r"[+-]?\d{1,}\.?\d*e?[+-]?\d*"
    # Regex explanation:
    # ±?  num(1,∞)  .?  num(0,∞)  e? ±?  num(0,∞)
    # +     2       .   4254      e  -   20
    # +2.4254e-20 (e.g.)
    result = str # will be overwriten
    for numstr in matchall(num_r,str)
        value = parse(Float64,numstr)
        result = replace(result, numstr, nicenumber(value))
    end
    return result
end
