package com.bsc.thesis.Options.exotic.utils;

/*
Author: Md Zahangir Alam <https://github.com/cs-joy>
 */

public class Utils {

    /**************** ASIAN OPTION ****************/

    public static class Result {
        public double V;
        public double P_tot;

        public Result(double V, double P_tot) {
            this.V = V;
            this.P_tot = P_tot;
        }
    }


    public static Result recursiveAsian(boolean isCall, double V, int N, double K, int n, double P_tot,
                                              double P, double[] Q, double[] M, double[] allS) {

        double[] allS_prev = allS.clone();
        double S_prev = allS_prev[allS_prev.length - 1];
        double P_prev = P;

        double currentV = V;
        double currentP_tot = P_tot;

        for (int i = 0; i < 3; i++) {
            double[] newAllS = new double[allS_prev.length + 1];
            System.arraycopy(allS_prev, 0, newAllS, 0, allS_prev.length);
            newAllS[allS_prev.length] = S_prev * Math.exp(M[i]);

            double newP = P_prev * Q[i];

            if (n == N) {
                currentP_tot += newP;
                // Calculate the payoff for each path
                double sum = 0;
                for (int j = 1; j < newAllS.length; j++) {
                    sum += newAllS[j];
                }
                double averagePrice = sum / (newAllS.length - 1);
                double payoff;
                if (isCall) {
                    payoff = Math.max(averagePrice - K, 0);
                } else {
                    payoff = Math.max(K - averagePrice, 0);
                }
                currentV += newP * payoff;
            } else {
                // Increases n until n = N
                Result recursiveResult = recursiveAsian(isCall, currentV, N, K, n + 1,
                        currentP_tot, newP, Q, M, newAllS);
                currentV = recursiveResult.V;
                currentP_tot = recursiveResult.P_tot;
            }
        }

        return new Result(currentV, currentP_tot);
    }


    /**************** CLIQUET OPTION ****************/


}
