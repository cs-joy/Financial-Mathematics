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
    private final ConcurrentHashMap<PathState, Double> memo = new ConcurrentHashMap<>();
    private final ForkJoinPool forkJoinPool;

    public Asian(double strike, double[] probabilities, double[] moves,
                             int totalSteps, int parallelism) {
        this.strike = strike;
        this.probabilities = probabilities;
        this.moves = moves;
        this.totalSteps = totalSteps;
        this.forkJoinPool = new ForkJoinPool(parallelism);
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
                double payoff = Math.max(averagePrice - strike, 0);
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
