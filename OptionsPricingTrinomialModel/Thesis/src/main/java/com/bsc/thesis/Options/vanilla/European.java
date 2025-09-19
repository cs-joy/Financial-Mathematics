package com.bsc.thesis.Options.vanilla;

import com.bsc.thesis.Options.vanilla.utils.StockPricesTree;

import java.util.function.DoubleUnaryOperator;

import static com.bsc.thesis.Options.vanilla.utils.TrinomialOptionPricing.*;

/**
 * @EuropeanOptions
 * @Type
 * 1. Call
 * 2. Put
 * @PricingMethod: Trinomial Tree
 * @author: Md. Zahangir Alam # Joy
 * ******
 * reach me to visit: cs-joy.github.io
 * @version v0.0.1
 */
public class European {
    public static double K;
    public European(double K) {
        European.K = K;
    }

    public static final DoubleUnaryOperator CALL_PAYOFF = (price) -> Math.max(price - K, 0);
    public static final DoubleUnaryOperator PUT_PAYOFF = (price) -> Math.max(K - price, 0);

    public static double calculateEuropeanOptions(boolean isCall, double S0, int N, double u, double r, double p, double h) {
        double callPrice = 0.0;
        double putPrice = 0.0;

        if (isCall) {
            try {
                double[][] stockTree = StockPricesTree.generateStockPrices(S0, N, u);

                callPrice = priceOption(stockTree, CALL_PAYOFF, r, p, h, u);
                System.out.printf("Call option price: %.4f%n", callPrice);
                //return callPrice;
            } catch (Exception e) {
                System.err.println("Error: " + e.getMessage());
                e.printStackTrace();
            }
        } else {
            try {
                double[][] stockTree = StockPricesTree.generateStockPrices(S0, N, u);

                putPrice = priceOption(stockTree, PUT_PAYOFF, r, p, h, u);
                System.out.printf("Put option price: %.4f%n", putPrice);
                //putPrice;
            } catch (Exception e) {
                System.err.println("Error: " + e.getMessage());
                e.printStackTrace();
            }
        }
        return isCall ? callPrice : putPrice;
    }
}