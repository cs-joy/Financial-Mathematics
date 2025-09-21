package com.bsc.thesis.Options.exotic;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.*;

public class Asian {
    // Record to store memoization key - path state for Asian options
    private record PathState(int step, double currentPrice, double runningSum, int count) {
        public PathState {
            // Round to avoid floating point precision issues in memoization
            runningSum = Math.round(runningSum * 1e10) / 1e10;
            currentPrice = Math.round(currentPrice * 1e10) / 1e10;
        }
    }

    private final double strike;
    private final double[] probabilities;
    private final double[] moves;
    private final int totalSteps;
    private final boolean isCall;
    private final ConcurrentHashMap<PathState, Double> memo = new ConcurrentHashMap<>();
    private final ForkJoinPool forkJoinPool;

    public Asian(double strike, double[] probabilities, double[] moves,
                             int totalSteps, boolean isCall, int parallelism) {
        this.strike = strike;
        this.probabilities = probabilities;
        this.moves = moves;
        this.totalSteps = totalSteps;
        this.isCall = isCall;
        this.forkJoinPool = new ForkJoinPool(parallelism);
    }

    public static double calculateAsianOption(boolean isCall, double S0, double K, double r, double sigma, double T, int N, double p) {
        double price = 0.0;
        int parallelism = Runtime.getRuntime().availableProcessors();

        // Calculate parameters
        double h = T / N;
        double u = sigma * Math.sqrt(h/(2*p));

        double q0 = 1 - 2 * p;
        double denominator = Math.exp(u) - Math.exp(-u);
        double qu = (Math.exp(r * h) - Math.exp(-u) - q0 * (1 - Math.exp(-u))) / denominator;
        double qd = (Math.exp(u) - Math.exp(r * h) - q0 * (Math.exp(u) - 1)) / denominator;

        // Verify probabilities sum to 1
        double sumProb = qu + q0 + qd;
        double tolerance = 1e-10;
        if (Math.abs(sumProb - 1.0) > tolerance) {
            throw new RuntimeException("Probabilities do not sum to 1. Sum: " + sumProb);
        }

        double[] Q = {qu, q0, qd};   // Risk-neutral probabilities
        double[] M = {u, 0, -u};     // Moves: up, same, down

        System.out.println("Calculating Asian option price...");
        System.out.println("N: " + N + ", Parallelism: " + parallelism);
        System.out.printf("Probabilities: qu=%.6f, q0=%.6f, qd=%.6f%n", qu, q0, qd);

        try {
            Asian pricer = new Asian(K, Q, M, N, isCall, parallelism);

            long startTime = System.currentTimeMillis();

            price = pricer.calculatePrice(S0, r, T);


            long endTime = System.currentTimeMillis();

            System.out.printf("Asian Option Price: %.4f%n", price);
            System.out.printf("Calculation time: %d ms%n", (endTime - startTime));

            pricer.shutdown();

        } catch (Exception e) {
            System.err.println("Error calculating price: " + e.getMessage());
            e.printStackTrace();
        }

        return price;
    }

    public double calculatePrice(double initialPrice, double riskFreeRate, double timeToMaturity) {
        memo.clear();

        // Use ForkJoinTask for parallel computation
        AsianPricingTask mainTask = new AsianPricingTask(1, initialPrice, initialPrice, 1);
        double undiscountedValue = forkJoinPool.invoke(mainTask);

        return Math.exp(-riskFreeRate * timeToMaturity) * undiscountedValue;
    }

    // Recursive task for ForkJoin framework
    private class AsianPricingTask extends RecursiveTask<Double> {
        private final int currentStep;
        private final double currentPrice;
        private final double runningSum;
        private final int count;

        public AsianPricingTask(int currentStep, double currentPrice,
                                double runningSum, int count) {
            this.currentStep = currentStep;
            this.currentPrice = currentPrice;
            this.runningSum = runningSum;
            this.count = count;
        }

        @Override
        protected Double compute() {
            PathState state = new PathState(currentStep, currentPrice, runningSum, count);

            // Check memoization
            Double memoized = memo.get(state);
            if (memoized != null) {
                return memoized;
            }

            if (currentStep == totalSteps) {
                // Base case: at maturity
                double averagePrice = (runningSum + currentPrice) / (count + 1);
                double payoff = 0.0;
                if (isCall) {
                    //System.out.println("i'm here..");
                    payoff = Math.max(averagePrice - strike, 0);
                } else {
                    //System.out.println("im there..");
                    payoff = Math.max(strike-averagePrice, 0);
                }
                memo.put(state, payoff);
                return payoff;
            }

            List<AsianPricingTask> subtasks = new ArrayList<>();
            double value = 0.0;

            for (int i = 0; i < 3; i++) {
                double nextPrice = currentPrice * Math.exp(moves[i]);
                double newRunningSum = runningSum + currentPrice;

                AsianPricingTask subtask = new AsianPricingTask(
                        currentStep + 1,
                        nextPrice,
                        newRunningSum,
                        count + 1
                );

                subtasks.add(subtask);
            }

            // Invoke all tasks and combine results
            invokeAll(subtasks);

            for (int i = 0; i < 3; i++) {
                value += probabilities[i] * subtasks.get(i).join();
            }

            memo.put(state, value);
            return value;
        }
    }

    public void shutdown() {
        forkJoinPool.shutdown();
    }
}
