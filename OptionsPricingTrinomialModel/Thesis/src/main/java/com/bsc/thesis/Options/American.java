package com.bsc.thesis.Options;

import java.util.concurrent.ForkJoinPool;
import java.util.stream.IntStream;

public class American {
    private static final ForkJoinPool pool = new ForkJoinPool();

    public static double calculateAmericanPut(double S0, double K, double r, int N,
                                              double p, double h, double u, double sigma) {
        // Create a wrapper class to allow array swapping with final references
        class ArrayHolder {
            double[] current = new double[2 * N + 1];
            double[] next = new double[2 * N + 1];
        }

        final ArrayHolder holder = new ArrayHolder();

        // Initialize option values at maturity
        IntStream.range(0, 2 * N + 1).parallel().forEach(i -> {
            double ST = S0 * Math.exp((N - i) * u);
            holder.next[i] = Math.max(K - ST, 0);
        });

        // Calculate risk-neutral probabilities (all made final)
        final double q0 = 1 - 2 * p;
        final double qu = (Math.exp(r * h) - Math.exp(-u)) / (Math.exp(u) - Math.exp(-u))
                - q0 * (1 - Math.exp(-u)) / (Math.exp(u) - Math.exp(-u));
        final double qd = (Math.exp(u) - Math.exp(r * h)) / (Math.exp(u) - Math.exp(-u))
                - q0 * (Math.exp(u) - 1) / (Math.exp(u) - Math.exp(-u));

        // Vectorized discount factor
        final double discount = Math.exp(-r * h);

        // Backward induction through the tree
        for (int j = N - 1; j >= 0; j--) {
            final int finalJ = j; // Final copy for lambda

            // Create thread-local copies of the arrays
            final double[] localNext = holder.next.clone();
            final double[] localCurrent = holder.current.clone();

            // Parallel processing
            IntStream.range(N - finalJ, N + finalJ + 1).parallel().forEach(i -> {
                double ST = S0 * Math.exp((finalJ - i) * u);
                double exerciseValue = Math.max(K - ST, 0);

                double continuationValue = discount *
                        (qu * localNext[i - 1] + q0 * localNext[i] + qd * localNext[i + 1]);

                localCurrent[i] = Math.max(exerciseValue, continuationValue);
            });

            // Update the holder arrays
            holder.current = localCurrent;

            // Swap arrays for next iteration
            if (j > 0) {  // No need to swap after last iteration
                double[] temp = holder.current;
                holder.current = holder.next;
                holder.next = temp;
            }
        }

        return holder.next[N]; // The option price at t=0 is at the center node
    }
}
