import Dates
using Test
import Humanize

@testset "Humanize" begin

@testset "datasize" begin
    VALUES = [300, 3000, 3000000, 3000000000, 3000000000000, 1e26, 3141592]
    MULTIPLIERS = Dict(:dec => 1.5, :bin => 2.1, :gnu => 1.6)
    RESULTS = Dict(
        :dec => ["450.000 B", "4.500 kB", "4.500 MB", "4.500 GB", "4.500 TB", "150.000 YB", "4.712 MB"],
        :bin => ["630.000 B", "6.152 KiB", "6.008 MiB", "5.867 GiB", "5.730 TiB", "173.708 YiB", "6.292 MiB"],
        :gnu => ["480.000", "4.688K", "4.578M", "4.470G", "4.366T", "132.349Y", "4.794M"]
    )
    @testset "$style" for style in (:dec, :bin, :gnu)
        for (value, result) in zip(VALUES, RESULTS[style])
            size = value * MULTIPLIERS[style]
            @test Humanize.datasize(size, style=style, format="%.3f") == result
        end
    end
end  # testset datasize.

@testset "timedelta" begin
    # Years, months, days, hours, minutes, seconds, result.
    DATA = [((0, 0, 0, 0, 0, 0), "a moment"),
            ((0, 0, 0, 0, 0, 1), "a second"),
            ((0, 0, 0, 0, 0, 30), "30 seconds"),
            ((0, 0, 0, 0, 1, 30), "a minute"),
            ((0, 0, 0, 0, 2, 0), "2 minutes"),
            ((0, 0, 0, 1, 30, 30), "an hour"),
            ((0, 0, 0, 23, 50, 50), "23 hours"),
            ((0, 0, 1, 0, 0, 0), "a day"),
            ((0, 0, 500, 0, 0, 0), "1 year, 4 months"),
            ((0, 0, 365 * 2 + 35, 0, 0, 0), "2 years"),
            ((0, 0, 10000, 0, 0, 0), "27 years"),
            ((0, 0, 365 + 30, 0, 0, 0), "1 year, 1 month"),
            ((0, 0, 365 + 4, 0, 0, 0), "a year"),
            ((0, 0, 35, 0, 0, 0), "a month"),
            ((0, 0, 65, 0, 0, 0), "2 months"),
            ((0, 0, 9, 0, 0, 0), "9 days"),
            ((0, 0, 365, 0, 0, 0), "a year")]

    @testset "datetime diff $output" for (inputs, output) in DATA
            base_datetime = Dates.DateTime(2014, 1, 1, 0, 0, 0)
        new_datetime = Dates.Year(inputs[1]) + base_datetime
        new_datetime += Dates.Month(inputs[2])
        new_datetime += Dates.Day(inputs[3])
        new_datetime += Dates.Hour(inputs[4])
        new_datetime += Dates.Minute(inputs[5])
        new_datetime += Dates.Second(inputs[6])
        @test Humanize.timedelta(new_datetime - base_datetime) == output
    end

    @testset "date diff $output" for (inputs, output) in DATA
        sum(inputs[1:3]) == 0 && continue  # Hour-scale or less.
        base_date = Dates.Date(2014, 1, 1)
        new_date = Dates.Year(inputs[1]) + base_date
        new_date += Dates.Month(inputs[2])
        new_date += Dates.Day(inputs[3])
        @test Humanize.timedelta(new_date - base_date) == output
    end
end  # testset timedelta.

@testset "digitsep" begin
    DATA = ((1, "1"),
            (12, "12"),
            (123, "123"),
            (1234, "1,234"),
            (12345, "12,345"),
            (123456, "123,456"),
            (1234567, "1,234,567"),
            (12345678, "12,345,678"),
            (-1, "-1"),
            (-12, "-12"),
            (-123, "-123"),
            (-1234, "-1,234"),
            (-12345, "-12,345"),
            (-123456, "-123,456"),
            (-1234567, "-1,234,567"),
            (-12345678, "-12,345,678"))
    @testset "digitsep $output" for (input, output) in DATA
        @test Humanize.digitsep(input) == output
    end
end  # testset digitsep.

end  # testset Humanize.