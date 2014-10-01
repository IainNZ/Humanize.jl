using Humanize
using Base.Test

function test_datasize()
    println("test_datasize")

    tests = [300, 3000, 3000000, 3000000000, 3000000000000, 1e26, 3141592]
    results = [:dec => ["450.000 B", "4.500 kB", "4.500 MB", "4.500 GB", "4.500 TB", "150.000 YB", "4.712 MB"],
               :bin => ["630.000 B", "6.152 KiB", "6.008 MiB", "5.867 GiB", "5.730 TiB", "173.708 YiB", "6.292 MiB"],
               :gnu => ["480.000", "4.688K", "4.578M", "4.470G", "4.366T", "132.349Y", "4.794M"]]
    for (style,mult) in [(:dec,1.5), (:bin,2.1), (:gnu, 1.6)]
        for i in 1:length(tests)
            size = tests[i] * mult
            @test datasize(size,style=style,format="%.3f") == results[style][i]
        end
    end
end

test_datasize()