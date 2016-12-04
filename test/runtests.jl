using Humanize
using Base.Test

function test_datasize()
    println("test_datasize")

    tests = [300, 3000, 3000000, 3000000000, 3000000000000, 1e26, 3141592]
    results = Dict( :dec => ["450.000 B", "4.500 kB", "4.500 MB", "4.500 GB", "4.500 TB", "150.000 YB", "4.712 MB"],
                    :bin => ["630.000 B", "6.152 KiB", "6.008 MiB", "5.867 GiB", "5.730 TiB", "173.708 YiB", "6.292 MiB"],
                    :gnu => ["480.000", "4.688K", "4.578M", "4.470G", "4.366T", "132.349Y", "4.794M"])
    for (style,mult) in [(:dec,1.5), (:bin,2.1), (:gnu, 1.6)]
        println("  $style")
        for i in 1:length(tests)
            size = tests[i] * mult
            @test datasize(size,style=style,format="%.3f") == results[style][i]
        end
    end
end


function test_timedelta()
    println("test_timedelta")

    test = [(0,0,0,0,0,0), "a moment",
            (0,0,0,0,0,1), "a second",
            (0,0,0,0,0,30), "30 seconds",
            (0,0,0,0,1,30), "a minute",
            (0,0,0,0,2,0), "2 minutes",
            (0,0,0,1,30,30), "an hour",
            (0,0,0,23,50,50), "23 hours",
            (0,0,1,0,0,0), "a day",
            (0,0,500,0,0,0), "1 year, 4 months",
            (0,0,365*2+35,0,0,0), "2 years",
            (0,0,10000,0,0,0), "27 years",
            (0,0,365+30,0,0,0), "1 year, 1 month",
            (0,0,365+4,0,0,0), "a year",
            (0,0,35,0,0,0), "a month",
            (0,0,65,0,0,0), "2 months",
            (0,0,9,0,0,0), "9 days",
            (0,0,365,0,0,0), "a year"]
    n_test = div(length(test),2)

    #timedelta(years::Int,months::Int,days::Int,hours::Int,mins::Int,secs::Int)
    println("  direct")
    for i in 1:n_test
        @test timedelta(test[2i-1]...) == test[2i]
    end
    #timedelta(dt_diff::Dates.Millisecond)
    println("  DateTime diff")
    for i in 1:n_test
        offset = test[2i-1]
        base_datetime = Dates.DateTime(2014,1,1,0,0,0)
        new_datetime  = Dates.Year(offset[1]) + base_datetime
        new_datetime += Dates.Month(offset[2])
        new_datetime += Dates.Day(offset[3])
        new_datetime += Dates.Hour(offset[4])
        new_datetime += Dates.Minute(offset[5])
        new_datetime += Dates.Second(offset[6])
        @test timedelta(new_datetime-base_datetime) == test[2i]
    end
    #timedelta(d_diff::Dates.Day)
    println("  Date diff")
    for i in 1:n_test
        offset = test[2i-1]
        sum(offset[1:3]) == 0 && continue
        base_date = Dates.Date(2014,1,1)
        new_date  = Dates.Year(offset[1]) + base_date
        new_date += Dates.Month(offset[2])
        new_date += Dates.Day(offset[3])
        @test timedelta(new_date-base_date) == test[2i]
    end
end


function test_digitsep()
    println("test_digitsep")

    test = (
            (1, "1"),
            (12, "12"),
            (123, "123"),
            (1234, "1,234"),
            (12345, "12,345"),
            (123456, "123,456"),
            (1234567, "1,234,567"),
            (12345678, "12,345,678")
            )

    n_test = length(test)

    #digitsep(value::Integer)
    println("  direct")
    for t in test
        @test digitsep(t[1]) == t[2]
    end

end

function test_nicenumbers()
    println("test_nicenumbers")

    # Integers
    @test nicenumber(1) == "1"
    @test nicenumber(-11111) == "-11111"
    @test nicenumber(-1e4) == "-10000"
    @test nicenumber(+1e6) == "1⋅10⁶"
    @test nicenumber(-1e6) == "-1⋅10⁶"
    @test nicenumber(-5e+60) == "-5⋅10⁶⁰"
    # Floating point
    @test nicenumber(3e-4) == "3⋅10⁻⁴"
    @test nicenumber(1.289e2) == "128.9"
    @test nicenumber(1.22e1) == "12.2"
    @test nicenumber(0.22e1) == "2.2"
    @test nicenumber(1.12345678) == "1.123"
    @test nicenumber(198.12345678) == "198.123"
    @test nicenumber(1988.12345678) == "1.988⋅10³"
    @test nicenumber(0.00000198812345678) == "1.988⋅10⁻⁶"

    # General tests
    @test "1"                  |> nicenumber == "1"
    @test "01"                 |> nicenumber == "1"
    @test "010"                |> nicenumber == "10"
    @test "100000000"          |> nicenumber == "1⋅10⁸"
    @test "1e20"               |> nicenumber == "1⋅10²⁰"
    @test "1e2"                |> nicenumber == "100"
    @test "+1"                 |> nicenumber == "1"
    @test "+01"                |> nicenumber == "1"
    @test "+010"               |> nicenumber == "10"
    @test "+100000000"         |> nicenumber == "1⋅10⁸"
    @test "+1e20"              |> nicenumber == "1⋅10²⁰"
    @test "+1e+2"              |> nicenumber == "100"
    @test "-1"                 |> nicenumber == "-1"
    @test "-01"                |> nicenumber == "-1"
    @test "-010"               |> nicenumber == "-10"
    @test "-100000000"         |> nicenumber == "-1⋅10⁸"
    @test "-1e20"              |> nicenumber == "-1⋅10²⁰"
    @test "-1e-2"              |> nicenumber == "-0.01"
    @test "+1.42"              |> nicenumber == "1.42"
    @test "-01.42"             |> nicenumber == "-1.42"
    @test "+010.42"            |> nicenumber == "10.42"
    @test "-100000.42"         |> nicenumber == "-1.000⋅10⁵"
    @test "2.42e-20"           |> nicenumber == "2.42⋅10⁻²⁰"
    @test "-0.000000242"       |> nicenumber == "-2.42⋅10⁻⁷"
    @test "+0.000000242"       |> nicenumber == "2.42⋅10⁻⁷"

    @test "ρ ≃ 0.4 ± 2e-5"     |> nicenumber == "ρ ≃ 0.4 ± 2⋅10⁻⁵"
    @test "ρ ≃ 00.04 ± 2e-3"   |> nicenumber == "ρ ≃ 0.04 ± 0.002"
    @test "γ=4.05e-20, β=5e-3" |> nicenumber == "γ=4.05⋅10⁻²⁰, β=0.005"
    @test "∫σ dx = 0.00004"    |> nicenumber == "∫σ dx = 4⋅10⁻⁵"

    # Escaping sequences.
    num = Float64(π)
    @test nicenumber("$num") == "3.142"
end

test_datasize()
test_timedelta()
test_digitsep()
test_nicenumbers()
