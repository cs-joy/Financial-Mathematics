package com.bsc.thesis.Options.vanilla;

import java.util.Arrays;

public class AmericanPut {

    public static double[][] americanPut(double[][] S, double K, double r,
                                         int N, double p, double h, double u) {

        double[][] A = new double[2 * N + 1][N + 1];

        // Initialize final column (expiration)
        for (int i = 0; i < 2 * N + 1; i++) {
            A[i][N] = Math.max(K - S[i][N], 0);
        }

        double q0 = 1 - 2 * p;
        double qu = (Math.exp(r * h) - Math.exp(-u)) / (Math.exp(u) - Math.exp(-u))
                - q0 * (1 - Math.exp(-u)) / (Math.exp(u) - Math.exp(-u));
        double qd = (Math.exp(u) - Math.exp(r * h)) / (Math.exp(u) - Math.exp(-u))
                - q0 * (Math.exp(u) - 1) / (Math.exp(u) - Math.exp(-u));

        // Backward induction
        for (int j = N - 1; j >= 0; j--) {
            for (int i = N - j; i <= N + j; i++) {
                double continuationValue = Math.exp(-r * h) *
                        (qu * A[i - 1][j + 1] + q0 * A[i][j + 1] + qd * A[i + 1][j + 1]);

                A[i][j] = Math.max(Math.max(K - S[i][j], 0), continuationValue);
            }
        }

        return A;
    }

    // Helper method to create stock price tree (similar to StockPricesnew)
    public static double[][] createStockTree(double S0, int N, double u) {
        double[][] S = new double[2 * N + 1][N + 1];
        S[N][0] = S0;

        for (int i = 1; i <= N; i++) {
            // Copy previous column
            for (int row = 0; row < 2 * N + 1; row++) {
                if (row < S.length && i - 1 < S[row].length) {
                    S[row][i] = S[row][i - 1];
                }
            }

            // Set up and down movements
            if (N - i >= 0) {
                S[N - i][i] = S[N - i + 1][i - 1] * Math.exp(u);
            }
            if (N + i < 2 * N + 1) {
                S[N + i][i] = S[N + i - 1][i - 1] * Math.exp(-u);
            }
        }

        return S;
    }
/*
    // Example usage
    public static void main(String[] args) {
        double S0 = 100.0;
        double K = 100.0;
        double r = 0.05;
        int N = 100;
        double p = 0.4;
        double T = 1.0;
        double sigma = 0.2;

        double h = T / N;
        double u = sigma * Math.sqrt(h / (2 * p));

        double[][] stockTree = createStockTree(S0, N, u);
        double[][] optionPrices = americanPut(stockTree, K, r, N, p, h, u);

        System.out.printf("American Put Option Price: %.4f%n", optionPrices[N][0]);
    }

 */
}