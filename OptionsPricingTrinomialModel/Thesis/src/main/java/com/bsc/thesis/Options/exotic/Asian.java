package com.bsc.thesis.Options.exotic;

import com.bsc.thesis.Options.exotic.utils.Utils;

/**
 * @author: Md Zahangir Alam (https://github.com/cs-joy)
 */
public class Asian {

    public static double calculateAsianOption(boolean isCall, double S0, double K, double r, double T, double sigma, double p, int N) {
        double price = 0.0;
        double h = T / N;   // Time step
        double u = sigma * Math.sqrt(h / (2 * p)); // up factor % h/2p->0.0212 h>0.0150
        System.out.printf("u = %.4f%n", u);

        double q0 = 1 - 2 * p;
        double qu = (Math.exp(r * h) - Math.exp(-u) - q0 * (1 - Math.exp(-u))) / (Math.exp(u) - Math.exp(-u));
        double qd = (Math.exp(u) - Math.exp(r * h) - q0 * (Math.exp(u) - 1)) / (Math.exp(u) - Math.exp(-u));

        double tol = 1e-10;
        if (Math.abs(qu + q0 + qd - 1) > tol) {
            throw new RuntimeException("Probabilities do not sum to 1.");
        }

        double[] Q = {qu, q0, qd};   // Risk-neutral probabilities
        double[] M = {u, 0, -u};     // Moves: up, same, down

        // Initialize for recursion
        double V = 0;
        double P_tot = 0;
        int n = 1;   // Start at step 1
        double P = 1;   // Initial probability
        double[] allS = {S0};   // Initial stock price

        // Call recursive function
        Utils.Result result = Utils.recursiveAsian(isCall, V, N, K, n, P_tot, P, Q, M, allS);

        // Discount the price
        price = Math.exp(-r * T) * result.V;

        return price;
    }
}