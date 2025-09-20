package com.bsc.thesis.Options.vanilla;

import java.util.concurrent.Executors;
import java.util.concurrent.Phaser;

import static com.bsc.thesis.Options.vanilla.utils.StockPricesTree.generateStockPrices;
import static com.bsc.thesis.Options.vanilla.utils.TrinomialOptionPricing.americanPut;

public class American {
    /**
     * Computes the price of an American put option using the trinomial model
     * @param S trinomial tree prices of the underlying stock
     * @param K strike price
     * @param r risk-free interest rate
     * @param N number of steps
     * @param p probability that stock price goes up
     * @param h length of each time step
     * @param u price change when stock price goes up
     * @return american put price<//2D array representing American put option prices
     */

    public static double K;
    // constructor
    public American(double K) {
        American.K = K;
    }

    public static double calculateAmericanOptions(double S0, int maxT, double r, double p, double sigma) throws InterruptedException {
            double[] A = new double[maxT + 1];
            Phaser phaser = new Phaser(1); // Synchronization barrier

            try (var executor = Executors.newVirtualThreadPerTaskExecutor()) {
                for (int t = 1; t <= maxT; t++) {
                    int currentT = t;
                    phaser.register();

                    executor.submit(() -> {
                        try {
                            double h = 1.0; // since T and N the same so when h = T/N, it always gives 1.0
                            double u = sigma * Math.sqrt(h / 2 / p);

                            double[][] S = generateStockPrices(S0, currentT, u);
                            double[][] AA = americanPut(S, K, r, currentT, p, h, u);

                            A[currentT] = AA[currentT][0];
                            //System.out.printf("T=%d: American Put Price = %.6f%n", currentT, A[currentT]);
                        } finally {
                            phaser.arriveAndDeregister();
                        }
                    });
                }

                // Wait for all tasks to complete
                phaser.arriveAndAwaitAdvance();
            }

            // return option price
            return A[maxT];
    }
}