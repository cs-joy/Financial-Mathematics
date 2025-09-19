package com.bsc.thesis.Options;

import java.util.concurrent.ForkJoinPool;
import java.util.stream.IntStream;

public class European_Unused {
    private static final ForkJoinPool pool = new ForkJoinPool();

    // Implementation using trinomial tree (O(N²) time complexity)
    public static double calculateEuropeanCallTrinomial(double S0, double K, double r, int N,
                                                        double h, double u, double sigma) {
        return calculateEuropeanOptionTrinomial(S0, K, r, N, h, u, sigma, true);
    }

    public static double calculateEuropeanPutTrinomial(double S0, double K, double r, int N,
                                                       double h, double u, double sigma) {
        return calculateEuropeanOptionTrinomial(S0, K, r, N, h, u, sigma, false);
    }

    private static double calculateEuropeanOptionTrinomial(double S0, double K, double r, int N,
                                                           double h, double u, double sigma, boolean isCall) {
        // Calculate risk-neutral probabilities
        double p = Math.exp(-sigma * sigma * h / 2);
        double q0 = 1 - 2 * p;
        double qu = (Math.exp(r * h) - Math.exp(-u)) / (Math.exp(u) - Math.exp(-u))
                - q0 * (1 - Math.exp(-u)) / (Math.exp(u) - Math.exp(-u));
        double qd = (Math.exp(u) - Math.exp(r * h)) / (Math.exp(u) - Math.exp(-u))
                - q0 * (Math.exp(u) - 1) / (Math.exp(u) - Math.exp(-u));

        double discount = Math.exp(-r * h);

        // Use a wrapper class to handle the array in lambda expressions
        class ArrayHolder {
            double[] values;
            ArrayHolder(double[] values) { this.values = values; }
        }
        ArrayHolder holder = new ArrayHolder(new double[2 * N + 1]);

        // Initialize option values at maturity
        IntStream.range(0, 2 * N + 1).parallel().forEach(i -> {
            double ST = S0 * Math.exp((N - i) * u);
            if (isCall) {
                holder.values[i] = Math.max(ST - K, 0);
            } else {
                holder.values[i] = Math.max(K - ST, 0);
            }
        });

        // Backward induction
        for (int j = N - 1; j >= 0; j--) {
            double[] newValues = new double[2 * N + 1];
            final double[] currentValues = holder.values; // Final reference for lambda

            IntStream.range(N - j, N + j + 1).parallel().forEach(i -> {
                double continuationValue = discount *
                        (qu * currentValues[i - 1] + q0 * currentValues[i] + qd * currentValues[i + 1]);
                newValues[i] = continuationValue;
            });

            holder.values = newValues;
        }

        return holder.values[N];
    }

    // Cumulative distribution function for standard normal distribution
    private static double normalCDF(double x) {
        return 0.5 * (1 + erf(x / Math.sqrt(2)));
    }

    // Error function approximation
    private static double erf(double x) {
        // Abramowitz and Stegun approximation
        double a1 = 0.254829592;
        double a2 = -0.284496736;
        double a3 = 1.421413741;
        double a4 = -1.453152027;
        double a5 = 1.061405429;
        double p = 0.3275911;

        int sign = (x < 0) ? -1 : 1;
        x = Math.abs(x);

        double t = 1.0 / (1.0 + p * x);
        double y = 1.0 - (((((a5 * t + a4) * t) + a3) * t + a2) * t + a1) * t * Math.exp(-x * x);

        return sign * y;
    }
}