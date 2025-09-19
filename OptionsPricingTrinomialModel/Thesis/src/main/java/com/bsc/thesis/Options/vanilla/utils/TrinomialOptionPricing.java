package com.bsc.thesis.Options.vanilla.utils;

import java.util.Arrays;
import java.util.function.DoubleUnaryOperator;

/**
 * TrinomialOptionPricing - Option pricing using trinomial model
 * Converts MATLAB's OptionPricesNew function to optimized Java 21
 */
public class TrinomialOptionPricing {

    /**
     * Prices an option using the trinomial model
     * @param S stock price tree (2D array)
     * @param payoffFunc payoff function
     * @param r risk-free rate
     * @param p probability parameter
     * @param h time step size
     * @param u volatility parameter
     * @return option price
     * @throws IllegalArgumentException for invalid parameters
     */
    public static double priceOption(double[][] S, DoubleUnaryOperator payoffFunc,
                                     double r, double p, double h, double u) {
        // Input validation
        validateInputs(S, r, p, h, u);

        final int M = S.length;
        final int N = S[0].length;

        // Initialize price matrix
        double[][] P = new double[M][N];
        for (double[] row : P) {
            Arrays.fill(row, Double.NaN);
        }

        // Calculate risk-neutral probabilities
        final double expRH = Math.exp(r * h);
        final double expU = Math.exp(u);
        final double expNegU = Math.exp(-u);
        final double denominator = expU - expNegU;

        if (Math.abs(denominator) < 1e-10) {
            throw new IllegalArgumentException("Denominator too small, u parameter may cause numerical instability");
        }

        final double q0 = 1 - 2 * p;
        final double qu = (expRH - expNegU) / denominator - q0 * (1 - expNegU) / denominator;
        final double qd = (expU - expRH) / denominator - q0 * (expU - 1) / denominator;

        // Validate probabilities sum to approximately 1
        validateProbabilities(qu, q0, qd, expRH);

        // Terminal payoff
        for (int i = 0; i < M; i++) {
            if (!Double.isNaN(S[i][N - 1])) {
                P[i][N - 1] = payoffFunc.applyAsDouble(S[i][N - 1]);
            }
        }

        // Backward induction
        final double discountFactor = Math.exp(-r * h);

        for (int j = N - 2; j >= 0; j--) {
            final int minRow = (N - j - 1);
            final int maxRow = M - (N - j - 1) - 1;

            for (int i = minRow; i <= maxRow; i++) {
                if (i > 0 && i < M - 1 &&
                        !Double.isNaN(S[i][j]) &&
                        !Double.isNaN(P[i - 1][j + 1]) &&
                        !Double.isNaN(P[i][j + 1]) &&
                        !Double.isNaN(P[i + 1][j + 1])) {

                    P[i][j] = discountFactor * (
                            qu * P[i - 1][j + 1] +
                                    q0 * P[i][j + 1] +
                                    qd * P[i + 1][j + 1]
                    );
                }
            }
        }

        // The option price is at the root of the tree
        final int rootRow = M / 2;
        if (Double.isNaN(P[rootRow][0])) {
            throw new IllegalStateException("Option price at root is NaN. Check input parameters and tree structure.");
        }

        return P[rootRow][0];
    }

    private static void validateInputs(double[][] S, double r, double p, double h, double u) {
        if (S == null || S.length == 0 || S[0].length == 0) {
            throw new IllegalArgumentException("Stock price tree must not be null or empty");
        }

        if (h <= 0) {
            throw new IllegalArgumentException("Time step h must be positive. Got: " + h);
        }

        if (u <= 0) {
            throw new IllegalArgumentException("Volatility parameter u must be positive. Got: " + u);
        }

        if (p < 0 || p > 0.5) {
            throw new IllegalArgumentException("Probability parameter p must be between 0 and 0.5. Got: " + p);
        }

        if (r < 0) {
            throw new IllegalArgumentException("Risk-free rate r must be non-negative. Got: " + r);
        }

        // Check if S is a proper tree structure
        for (double[] row : S) {
            if (row.length != S[0].length) {
                throw new IllegalArgumentException("Stock price tree must have consistent column lengths");
            }
        }
    }

    private static void validateProbabilities(double qu, double q0, double qd, double expRH) {
        final double sum = qu + q0 + qd;
        final double tolerance = 1e-8;

        if (Math.abs(sum - 1.0) > tolerance) {
            throw new IllegalArgumentException(String.format(
                    "Probabilities don't sum to 1 (sum=%.8f, qu=%.8f, q0=%.8f, qd=%.8f, exp(rh)=%.8f)",
                    sum, qu, q0, qd, expRH
            ));
        }

        if (qu < -tolerance || q0 < -tolerance || qd < -tolerance) {
            throw new IllegalArgumentException(String.format(
                    "Negative probabilities detected (qu=%.8f, q0=%.8f, qd=%.8f)",
                    qu, q0, qd
            ));
        }
    }
}
