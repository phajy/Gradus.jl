using Test
using Gradus

function test_ctf1(a, angle, rₑ)
    m = KerrMetric(1.0, a)
    d = ThinDisc(0.0, Inf)
    x = SVector(0.0, 100_000, deg2rad(angle), 0.0)
    Gradus.cunningham_transfer_function(
        m,
        x,
        d,
        rₑ,
        ;
        chart = Gradus.chart_for_metric(m, 2 * x[2], closest_approach = 1.005),
        N = 80,
    )
end

function measure_ctf(ctf)
    sum(ctf.f .* ctf.g✶) / length(ctf.f)
end

# test for different angles
# update: 2025-06-18: new root finder
@test measure_ctf(test_ctf1(0.998, 3, 4.0)) ≈ 0.1108266964593416 atol = 1e-3
@test measure_ctf(test_ctf1(0.998, 35, 4.0)) ≈ 0.10510590963059034 atol = 1e-3
@test measure_ctf(test_ctf1(0.998, 74, 4.0)) ≈ 0.05294589711510501 atol = 1e-3
@test measure_ctf(test_ctf1(0.998, 85, 4.0)) ≈ 0.03602870590038378 atol = 1e-3

# different radii
@test measure_ctf(test_ctf1(0.998, 30, 4.0)) ≈ 0.09877331327997838 atol = 1e-3
@test measure_ctf(test_ctf1(0.998, 30, 7.0)) ≈ 0.1202759989850966 atol = 1e-3
@test measure_ctf(test_ctf1(0.998, 30, 10.0)) ≈ 0.12341554326819407 atol = 1e-3
@test measure_ctf(test_ctf1(0.998, 30, 15.0)) ≈ 0.12875961522283233 atol = 1e-3

# large radii
@test measure_ctf(test_ctf1(0.998, 30, 300.0)) ≈ 0.13191798015557799 rtol = 1e-2
@test measure_ctf(test_ctf1(0.998, 30, 800.0)) ≈ 0.1271143314790187 rtol = 1e-2
@test measure_ctf(test_ctf1(0.998, 30, 1000.0)) ≈ 0.12734230932681662 rtol = 1e-2

# ones that have been problematic in the past
# and should not raise any errors or warnings
test_ctf1(-0.6, 88, 784.8253509875607)
test_ctf1(-0.998, 88, 953.9915665264327)
test_ctf1(-0.450, 88, 952.1406350219423)
test_ctf1(0.0, 88, 952.1406350219423)
test_ctf1(0.0, 88, 631.1007589946363)
test_ctf1(0.9, 88, 952.1406350219423)
test_ctf1(0.0, 88, 950.8754196211696)
test_ctf1(0.744, 88, 3.1880132176627862)
test_ctf1(1.0, 88, 1.01)
