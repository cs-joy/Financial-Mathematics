package com.bsc.thesis.Options.exotic;

import java.util.function.DoubleUnaryOperator;

import static com.bsc.thesis.Options.vanilla.utils.StockPricesTree.generateStockPrices;
import static com.bsc.thesis.Options.vanilla.utils.TrinomialOptionPricing.priceOption;

public class Compound {
    public static double calculateCompoundOption(boolean isCall, boolean onCall, double S0, double K1, double K2, double T1, double T2, double r, double sigma, double p, int N) {

        return euCompoundTri(isCall, onCall, S0, T1, T2, N, K1, K2, p, r, sigma);
    }

    public static double euCompoundTri(boolean isCall, boolean onCall, double S0, double T1, double T2, int N,
                                       double K1, double K2, double p, double r, double sigma) {
        // Checking input parameters
        if (r < 0 || T1 < 0 || T2 < 0 || K1 < 0 || K2 < 0) {
            throw new IllegalArgumentException("Error: invalid input parameters");
        }

        double h = T2 / N;
        double u = sigma * Math.sqrt(h / (2 * p));

        // Number of steps for compound and underlying option
        int N1 = (int) Math.round(T1 * N / T2);
        int N2 = N - N1;

        // payoff function
        DoubleUnaryOperator payoffUnderlying;
        DoubleUnaryOperator payoffCompound;
        if(isCall) {
            if(onCall) {
                payoffUnderlying = x -> Math.max(0, x - K2); // Call on Call (CoC)
            } else {
                payoffUnderlying = x -> Math.max(0, K2 - x); // Call on Put (CoP)
            }
            payoffCompound = x -> Math.max(0, x - K1); // Compound option payoff (Call)
        } else {
            if(onCall) {
                payoffUnderlying = x -> Math.max(0, x - K2); // Put on Call (PoC)
            } else {
                payoffUnderlying = x -> Math.max(0, K2 - x); // Put on Put (PoP)
            }
            payoffCompound = x -> Math.max(0, K1 - x); // Compound option payoff (Put)
        }

        // Build stock price tree for compound option period (T1)
        double[][] S1 = generateStockPrices(S0, N1, u);
        int M = S1.length; // Number of rows in the tree

        double[][] P = new double[M][N1 + 1]; // Compound option prices
        double[] undPrices = new double[M];

        // For each node at time T1, calculate the underlying option price
        for (int i = 0; i < M; i++) {
            double stockPriceAtT1 = S1[i][N1];
            if (stockPriceAtT1 > 0) {
                // Build tree for underlying option from T1 to T2
                double[][] S2 = generateStockPrices(stockPriceAtT1, N2, u);
                double underlyingOptionPrice = priceOption(S2, payoffUnderlying, r, p, h, u);
                undPrices[i] = underlyingOptionPrice;
            }
        }

        // Calculate compound option payoffs at T1
        for (int i = 0; i < M; i++) {
            if (undPrices[i] > 0) {
                P[i][N1] = payoffCompound.applyAsDouble(undPrices[i]);
            }
        }

        // Calculate risk-neutral probabilities
        double q0 = 1 - 2 * p;
        double expRh = Math.exp(r * h);
        double expU = Math.exp(u);
        double expMinusU = Math.exp(-u);

        double qu = (expRh - expMinusU) / (expU - expMinusU) - q0 * (1 - expMinusU) / (expU - expMinusU);
        double qd = (expU - expRh) / (expU - expMinusU) - q0 * (expU - 1) / (expU - expMinusU);

        // Backward induction for compound option
        for (int j = N1 - 1; j >= 0; j--) {
            for (int i = 0; i < M; i++) {
                if (S1[i][j] > 0) {
                    // Get prices from next time step (up, middle, down)
                    double upPrice = 0, middlePrice = 0, downPrice = 0;

                    // Up node (i-1, j+1)
                    if (i > 0 && P[i-1][j+1] > 0) {
                        upPrice = P[i-1][j+1];
                    }

                    // Middle node (i, j+1)
                    if (P[i][j+1] > 0) {
                        middlePrice = P[i][j+1];
                    }

                    // Down node (i+1, j+1)
                    if (i < M-1 && P[i+1][j+1] > 0) {
                        downPrice = P[i+1][j+1];
                    }

                    // Only calculate if we have valid next-step prices
                    if (upPrice > 0 || middlePrice > 0 || downPrice > 0) {
                        P[i][j] = Math.exp(-r * h) * (qu * upPrice + q0 * middlePrice + qd * downPrice);
                    }
                }
            }
        }

        // Return the root node price (center of first column)
        return P[N1][0];
    }
}