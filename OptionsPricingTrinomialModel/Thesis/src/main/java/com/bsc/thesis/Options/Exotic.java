package com.bsc.thesis.Options;

import java.util.concurrent.ForkJoinPool;
import java.util.stream.IntStream;
import java.util.Arrays;
import java.util.Random;

public class Exotic {
    private static final ForkJoinPool pool = new ForkJoinPool();
    private static final Random random = new Random();

    // ==================== ASIAN OPTIONS ====================

    // Asian Option - Arithmetic Average Call (O(N²) using trinomial tree)
    public static double calculateAsianCall(double S0, double K, double r, int N,
                                            double h, double u, double sigma) {
        return calculateAsianOption(S0, K, r, N, h, u, sigma, true);
    }

    public static double calculateAsianPut(double S0, double K, double r, int N,
                                           double h, double u, double sigma) {
        return calculateAsianOption(S0, K, r, N, h, u, sigma, false);
    }

    private static double calculateAsianOption(double S0, double K, double r, int N,
                                               double h, double u, double sigma, boolean isCall) {
        // Calculate risk-neutral probabilities
        double p = Math.exp(-sigma * sigma * h / 2);
        double q0 = 1 - 2 * p;
        double qu = (Math.exp(r * h) - Math.exp(-u)) / (Math.exp(u) - Math.exp(-u))
                - q0 * (1 - Math.exp(-u)) / (Math.exp(u) - Math.exp(-u));
        double qd = (Math.exp(u) - Math.exp(r * h)) / (Math.exp(u) - Math.exp(-u))
                - q0 * (Math.exp(u) - 1) / (Math.exp(u) - Math.exp(-u));

        double discount = Math.exp(-r * h);

        // Use state-space for average price approximation (more efficient than full path storage)
        int avgBins = Math.min(100, N * 2); // Reduced state space
        double[][][] dp = new double[N + 1][2 * N + 1][avgBins];

        // Initialize at maturity
        for (int i = 0; i <= 2 * N; i++) {
            for (int avgBin = 0; avgBin < avgBins; avgBin++) {
                double ST = S0 * Math.exp((N - i) * u);
                double avgPrice = calculateAverageFromBin(avgBin, avgBins, S0, ST, N);

                if (isCall) {
                    dp[N][i][avgBin] = Math.max(avgPrice - K, 0);
                } else {
                    dp[N][i][avgBin] = Math.max(K - avgPrice, 0);
                }
            }
        }

        // Backward induction
        for (int j = N - 1; j >= 0; j--) {
            for (int i = N - j; i <= N + j; i++) {
                for (int avgBin = 0; avgBin < avgBins; avgBin++) {
                    double ST = S0 * Math.exp((j - i) * u);
                    double currentAvg = calculateAverageFromBin(avgBin, avgBins, S0, ST, j);
                    double newAvg = (currentAvg * j + ST) / (j + 1);
                    int newAvgBin = (int) ((newAvg / (S0 * 2)) * avgBins);
                    newAvgBin = Math.max(0, Math.min(avgBins - 1, newAvgBin));

                    double continuationValue = discount * (
                            qu * dp[j + 1][i - 1][newAvgBin] +
                                    q0 * dp[j + 1][i][newAvgBin] +
                                    qd * dp[j + 1][i + 1][newAvgBin]
                    );

                    dp[j][i][avgBin] = continuationValue;
                }
            }
        }

        return dp[0][N][0];
    }

    private static double calculateAverageFromBin(int bin, int totalBins, double S0, double ST, int steps) {
        double minAvg = S0 * 0.5;
        double maxAvg = S0 * 2.0;
        return minAvg + (maxAvg - minAvg) * (bin / (double) totalBins);
    }

    // ==================== CLIQUET OPTIONS ====================

    public static double calculateCliquetOption(double S0, double initialStrike, double localCap,
                                                double localFloor, double globalCap, double globalFloor,
                                                double r, double T, double sigma, int numPeriods) {
        double periodLength = T / numPeriods;
        double[] periodReturns = new double[numPeriods];

        // Monte Carlo simulation for cliquet option
        int numSimulations = 10000;
        double sumPayoffs = 0;

        for (int sim = 0; sim < numSimulations; sim++) {
            double currentPrice = S0;
            double totalReturn = 0;

            for (int period = 0; period < numPeriods; period++) {
                double nextPrice = currentPrice * Math.exp(
                        (r - 0.5 * sigma * sigma) * periodLength +
                                sigma * Math.sqrt(periodLength) * random.nextGaussian()
                );

                double periodReturn = (nextPrice - currentPrice) / currentPrice;
                double cappedReturn = Math.max(localFloor, Math.min(localCap, periodReturn));

                totalReturn += cappedReturn;
                currentPrice = nextPrice;
            }

            double finalReturn = Math.max(globalFloor, Math.min(globalCap, totalReturn));
            sumPayoffs += Math.max(0, finalReturn) * S0; // Payoff in currency terms
        }

        return Math.exp(-r * T) * (sumPayoffs / numSimulations);
    }

    // ==================== COMPOUND OPTIONS ====================

    public static double calculateCompoundOption(double S0, double K1, double K2, double r,
                                                 double T1, double T2, double sigma, boolean isCallOnCall) {
        // T1: time to compound option expiration
        // T2: time to underlying option expiration (T2 > T1)

        if (isCallOnCall) {
            // Call on call compound option
            double d1 = (Math.log(S0 / K2) + (r + 0.5 * sigma * sigma) * T2) / (sigma * Math.sqrt(T2));
            double d2 = d1 - sigma * Math.sqrt(T2);
            double underlyingCall = S0 * normalCDF(d1) - K2 * Math.exp(-r * T2) * normalCDF(d2);

            double d1_compound = (Math.log(underlyingCall / K1) + (r + 0.5 * sigma * sigma) * T1) / (sigma * Math.sqrt(T1));
            double d2_compound = d1_compound - sigma * Math.sqrt(T1);

            return underlyingCall * normalCDF(d1_compound) - K1 * Math.exp(-r * T1) * normalCDF(d2_compound);
        } else {
            // Call on put compound option
            double d1 = (Math.log(S0 / K2) + (r + 0.5 * sigma * sigma) * T2) / (sigma * Math.sqrt(T2));
            double d2 = d1 - sigma * Math.sqrt(T2);
            double underlyingPut = K2 * Math.exp(-r * T2) * normalCDF(-d2) - S0 * normalCDF(-d1);

            double d1_compound = (Math.log(underlyingPut / K1) + (r + 0.5 * sigma * sigma) * T1) / (sigma * Math.sqrt(T1));
            double d2_compound = d1_compound - sigma * Math.sqrt(T1);

            return underlyingPut * normalCDF(d1_compound) - K1 * Math.exp(-r * T1) * normalCDF(d2_compound);
        }
    }

    // ==================== LOOKBACK OPTIONS ====================

    public static double calculateLookbackCall(double S0, double r, int N,
                                               double h, double u, double sigma) {
        return calculateLookbackOption(S0, r, N, h, u, sigma, true);
    }

    public static double calculateLookbackPut(double S0, double K, double r, int N,
                                              double h, double u, double sigma) {
        return calculateLookbackOption(S0, r, N, h, u, sigma, false);
    }

    private static double calculateLookbackOption(double S0, double r, int N,
                                                  double h, double u, double sigma, boolean isCall) {
        double p = Math.exp(-sigma * sigma * h / 2);
        double q0 = 1 - 2 * p;
        double qu = (Math.exp(r * h) - Math.exp(-u)) / (Math.exp(u) - Math.exp(-u))
                - q0 * (1 - Math.exp(-u)) / (Math.exp(u) - Math.exp(-u));
        double qd = (Math.exp(u) - Math.exp(r * h)) / (Math.exp(u) - Math.exp(-u))
                - q0 * (Math.exp(u) - 1) / (Math.exp(u) - Math.exp(-u));

        double discount = Math.exp(-r * h);

        // Reduced state space for efficiency
        int maxMinBins = Math.min(50, N * 2);
        double[][][] dp = new double[N + 1][2 * N + 1][maxMinBins];

        // Initialize at maturity
        for (int i = 0; i <= 2 * N; i++) {
            for (int minBin = 0; minBin < maxMinBins; minBin++) {
                double ST = S0 * Math.exp((N - i) * u);
                double minPrice = calculateMinFromBin(minBin, maxMinBins, S0);

                if (isCall) {
                    dp[N][i][minBin] = ST - minPrice; // Floating strike call
                } else {
                    dp[N][i][minBin] = Math.max(minPrice - ST, 0); // Fixed strike put
                }
            }
        }

        // Backward induction
        for (int j = N - 1; j >= 0; j--) {
            for (int i = N - j; i <= N + j; i++) {
                for (int minBin = 0; minBin < maxMinBins; minBin++) {
                    double ST = S0 * Math.exp((j - i) * u);
                    double currentMin = calculateMinFromBin(minBin, maxMinBins, S0);
                    double newMin = Math.min(ST, currentMin);
                    int newMinBin = (int) ((newMin / (S0 * 2)) * maxMinBins);
                    newMinBin = Math.max(0, Math.min(maxMinBins - 1, newMinBin));

                    double continuationValue = discount * (
                            qu * dp[j + 1][i - 1][newMinBin] +
                                    q0 * dp[j + 1][i][newMinBin] +
                                    qd * dp[j + 1][i + 1][newMinBin]
                    );

                    dp[j][i][minBin] = continuationValue;
                }
            }
        }

        return dp[0][N][0];
    }

    private static double calculateMinFromBin(int bin, int totalBins, double S0) {
        return S0 * 0.5 + (S0 * 1.5) * (bin / (double) totalBins);
    }

    // ==================== BERMUDAN OPTIONS ====================

    public static double calculateBermudanPut(double S0, double K, double r, int N,
                                              double h, double u, double sigma, int[] exerciseDates) {
        return calculateBermudanOption(S0, K, r, N, h, u, sigma, exerciseDates, false);
    }

    public static double calculateBermudanCall(double S0, double K, double r, int N,
                                               double h, double u, double sigma, int[] exerciseDates) {
        return calculateBermudanOption(S0, K, r, N, h, u, sigma, exerciseDates, true);
    }

    private static double calculateBermudanOption(double S0, double K, double r, int N,
                                                  double h, double u, double sigma,
                                                  int[] exerciseDates, boolean isCall) {
        double p = Math.exp(-sigma * sigma * h / 2);
        double q0 = 1 - 2 * p;
        double qu = (Math.exp(r * h) - Math.exp(-u)) / (Math.exp(u) - Math.exp(-u))
                - q0 * (1 - Math.exp(-u)) / (Math.exp(u) - Math.exp(-u));
        double qd = (Math.exp(u) - Math.exp(r * h)) / (Math.exp(u) - Math.exp(-u))
                - q0 * (Math.exp(u) - 1) / (Math.exp(u) - Math.exp(-u));

        double discount = Math.exp(-r * h);
        double[] optionValues = new double[2 * N + 1];

        // Initialize option values at maturity
        double[] finalOptionValues1 = optionValues;
        IntStream.range(0, 2 * N + 1).parallel().forEach(i -> {
            double ST = S0 * Math.exp((N - i) * u);
            if (isCall) {
                finalOptionValues1[i] = Math.max(ST - K, 0);
            } else {
                finalOptionValues1[i] = Math.max(K - ST, 0);
            }
        });

        // Backward induction
        for (int j = N - 1; j >= 0; j--) {
            double[] newValues = new double[2 * N + 1];
            boolean isExerciseDate = contains(exerciseDates, j);

            double[] finalOptionValues = optionValues;
            int finalJ = j;
            IntStream.range(N - j, N + j + 1).parallel().forEach(i -> {
                double ST = S0 * Math.exp((finalJ - i) * u);

                double exerciseValue;
                if (isCall) {
                    exerciseValue = Math.max(ST - K, 0);
                } else {
                    exerciseValue = Math.max(K - ST, 0);
                }

                double continuationValue = discount *
                        (qu * finalOptionValues[i - 1] + q0 * finalOptionValues[i] + qd * finalOptionValues[i + 1]);

                // At exercise dates, choose maximum of exercise and continuation
                if (isExerciseDate) {
                    newValues[i] = Math.max(exerciseValue, continuationValue);
                } else {
                    newValues[i] = continuationValue;
                }
            });

            optionValues = newValues;
        }

        return optionValues[N];
    }

    private static boolean contains(int[] array, int value) {
        for (int num : array) {
            if (num == value) return true;
        }
        return false;
    }

    // ==================== BARRIER OPTIONS ====================

    public static double calculateBarrierDownOutCall(double S0, double K, double barrier,
                                                     double r, int N, double h, double u, double sigma) {
        return calculateBarrierOption(S0, K, barrier, r, N, h, u, sigma, true, true, false);
    }

    public static double calculateBarrierUpOutPut(double S0, double K, double barrier,
                                                  double r, int N, double h, double u, double sigma) {
        return calculateBarrierOption(S0, K, barrier, r, N, h, u, sigma, false, false, true);
    }

    public static double calculateBarrierDownInCall(double S0, double K, double barrier,
                                                    double r, int N, double h, double u, double sigma) {
        // Down-In = Vanilla - Down-Out
        double vanilla = European.calculateEuropeanCallTrinomial(S0, K, r, N, h, u, sigma);
        double downOut = calculateBarrierDownOutCall(S0, K, barrier, r, N, h, u, sigma);
        return vanilla - downOut;
    }

    private static double calculateBarrierOption(double S0, double K, double barrier,
                                                 double r, int N, double h, double u, double sigma,
                                                 boolean isCall, boolean isDown, boolean isOut) {
        double p = Math.exp(-sigma * sigma * h / 2);
        double q0 = 1 - 2 * p;
        double qu = (Math.exp(r * h) - Math.exp(-u)) / (Math.exp(u) - Math.exp(-u))
                - q0 * (1 - Math.exp(-u)) / (Math.exp(u) - Math.exp(-u));
        double qd = (Math.exp(u) - Math.exp(r * h)) / (Math.exp(u) - Math.exp(-u))
                - q0 * (Math.exp(u) - 1) / (Math.exp(u) - Math.exp(-u));

        double discount = Math.exp(-r * h);
        double[] optionValues = new double[2 * N + 1];

        // Initialize option values at maturity
        double[] finalOptionValues1 = optionValues;
        IntStream.range(0, 2 * N + 1).parallel().forEach(i -> {
            double ST = S0 * Math.exp((N - i) * u);
            boolean isActive = isOptionActive(ST, barrier, isDown, isOut);

            if (isActive) {
                if (isCall) {
                    finalOptionValues1[i] = Math.max(ST - K, 0);
                } else {
                    finalOptionValues1[i] = Math.max(K - ST, 0);
                }
            } else {
                finalOptionValues1[i] = 0;
            }
        });

        // Backward induction
        for (int j = N - 1; j >= 0; j--) {
            double[] newValues = new double[2 * N + 1];

            double[] finalOptionValues = optionValues;
            int finalJ = j;
            IntStream.range(N - j, N + j + 1).parallel().forEach(i -> {
                double ST = S0 * Math.exp((finalJ - i) * u);
                boolean isActive = isOptionActive(ST, barrier, isDown, isOut);

                if (isActive) {
                    double continuationValue = discount *
                            (qu * finalOptionValues[i - 1] + q0 * finalOptionValues[i] + qd * finalOptionValues[i + 1]);
                    newValues[i] = continuationValue;
                } else {
                    newValues[i] = 0;
                }
            });

            optionValues = newValues;
        }

        return optionValues[N];
    }

    private static boolean isOptionActive(double price, double barrier, boolean isDown, boolean isOut) {
        if (isDown) {
            if (isOut) {
                return price > barrier; // Down-and-out: active if above barrier
            } else {
                return price <= barrier; // Down-and-in: active if below barrier
            }
        } else {
            if (isOut) {
                return price < barrier; // Up-and-out: active if below barrier
            } else {
                return price >= barrier; // Up-and-in: active if above barrier
            }
        }
    }

    // ==================== UTILITY FUNCTIONS ====================

    private static double normalCDF(double x) {
        return 0.5 * (1 + erf(x / Math.sqrt(2)));
    }

    private static double erf(double x) {
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

    // Monte Carlo simulation for complex exotic options
    public static double calculateExoticMonteCarlo(double S0, double K, double r, double T,
                                                   double sigma, int numSimulations, String optionType,
                                                   Object... params) {
        double sumPayoffs = 0;

        for (int i = 0; i < numSimulations; i++) {
            double[] path = generatePath(S0, r, T, sigma, (int)(T * 252)); // Daily steps
            double payoff = calculateExoticPayoff(path, K, optionType, params);
            sumPayoffs += payoff;
        }

        return Math.exp(-r * T) * (sumPayoffs / numSimulations);
    }

    private static double[] generatePath(double S0, double r, double T, double sigma, int steps) {
        double[] path = new double[steps];
        path[0] = S0;
        double dt = T / steps;

        for (int i = 1; i < steps; i++) {
            double z = random.nextGaussian();
            path[i] = path[i - 1] * Math.exp((r - 0.5 * sigma * sigma) * dt + sigma * Math.sqrt(dt) * z);
        }

        return path;
    }

    private static double calculateExoticPayoff(double[] path, double K, String optionType, Object... params) {
        switch (optionType) {
            case "Asian":
                double avg = Arrays.stream(path).average().orElse(0);
                return Math.max(avg - K, 0);

            case "Lookback":
                double min = Arrays.stream(path).min().orElse(0);
                return path[path.length - 1] - min;

            case "Barrier":
                double barrier = (Double) params[0];
                boolean knockedOut = Arrays.stream(path).anyMatch(price ->
                        (Boolean) params[1] ? price <= barrier : price >= barrier);
                if (knockedOut == (Boolean) params[2]) return 0;
                return Math.max(path[path.length - 1] - K, 0);

            case "Cliquet":
                // Implement cliquet payoff logic
                return 0;

            default:
                return Math.max(path[path.length - 1] - K, 0);
        }
    }
}