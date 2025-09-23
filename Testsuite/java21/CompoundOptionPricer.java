import java.util.function.DoubleUnaryOperator;

public class CompoundOptionPricer {
    
    public static double euCompoundTri(double S0, double T1, double T2, int N, 
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
        
        // Payoff functions
        DoubleUnaryOperator payoffUnderlying = x -> Math.max(0, x - K2);
        DoubleUnaryOperator payoffCompound = x -> Math.max(0, x - K1);
        
        // Build stock price tree for compound option period (T1)
        double[][] S1 = buildTrinomialTree(S0, N1, u);
        int M = S1.length; // Number of rows in the tree
        
        double[][] P = new double[M][N1 + 1]; // Compound option prices
        double[] undPrices = new double[M];
        
        // For each node at time T1, calculate the underlying option price
        for (int i = 0; i < M; i++) {
            double stockPriceAtT1 = S1[i][N1];
            if (stockPriceAtT1 > 0) {
                // Build tree for underlying option from T1 to T2
                double[][] S2 = buildTrinomialTree(stockPriceAtT1, N2, u);
                double underlyingOptionPrice = calculateOptionPrice(S2, payoffUnderlying, r, p, h, u);
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
    
    private static double[][] buildTrinomialTree(double S0, int steps, double u) {
        int rows = 2 * steps + 1;
        double[][] tree = new double[rows][steps + 1];
        
        // Initialize root node
        tree[steps][0] = S0;
        
        // Build the tree
        for (int j = 0; j < steps; j++) {
            for (int i = 0; i < rows; i++) {
                double currentPrice = tree[i][j];
                if (currentPrice > 0) {
                    // Up movement
                    if (i > 0) {
                        tree[i-1][j+1] = currentPrice * Math.exp(u);
                    }
                    // Middle movement
                    tree[i][j+1] = currentPrice; // No change
                    // Down movement
                    if (i < rows - 1) {
                        tree[i+1][j+1] = currentPrice * Math.exp(-u);
                    }
                }
            }
        }
        
        return tree;
    }
    
    private static double calculateOptionPrice(double[][] stockTree, 
                                             DoubleUnaryOperator payoff, 
                                             double r, double p, double h, double u) {
        int steps = stockTree[0].length - 1;
        int rows = stockTree.length;
        double[][] optionTree = new double[rows][steps + 1];
        
        // Calculate terminal payoffs
        for (int i = 0; i < rows; i++) {
            double terminalPrice = stockTree[i][steps];
            if (terminalPrice > 0) {
                optionTree[i][steps] = payoff.applyAsDouble(terminalPrice);
            }
        }
        
        // Calculate risk-neutral probabilities
        double q0 = 1 - 2 * p;
        double expRh = Math.exp(r * h);
        double expU = Math.exp(u);
        double expMinusU = Math.exp(-u);
        
        double qu = (expRh - expMinusU) / (expU - expMinusU) - q0 * (1 - expMinusU) / (expU - expMinusU);
        double qd = (expU - expRh) / (expU - expMinusU) - q0 * (expU - 1) / (expU - expMinusU);
        
        // Backward induction
        for (int j = steps - 1; j >= 0; j--) {
            for (int i = 0; i < rows; i++) {
                if (stockTree[i][j] > 0) {
                    double upPrice = 0, middlePrice = 0, downPrice = 0;
                    
                    // Up node
                    if (i > 0 && optionTree[i-1][j+1] > 0) {
                        upPrice = optionTree[i-1][j+1];
                    }
                    
                    // Middle node
                    if (optionTree[i][j+1] > 0) {
                        middlePrice = optionTree[i][j+1];
                    }
                    
                    // Down node
                    if (i < rows - 1 && optionTree[i+1][j+1] > 0) {
                        downPrice = optionTree[i+1][j+1];
                    }
                    
                    // Calculate expected value
                    if (upPrice > 0 || middlePrice > 0 || downPrice > 0) {
                        optionTree[i][j] = Math.exp(-r * h) * (qu * upPrice + q0 * middlePrice + qd * downPrice);
                    }
                }
            }
        }
        
        // Return the root node price
        return optionTree[steps][0];
    }
    
    public static void main(String[] args) {
        double S0 = 500;
        double K1 = 300;
        double K2 = 150;
        double T1 = 5.0 / 12;
        double T2 = 30.0 / 12;
        double r = 0.05;
        double sigma = 0.3;
        double p = 0.3;
        int N = 450;

        double trinomialPrices = euCompoundTri(S0, T1, T2, N, K1, K2, p, r, sigma);
        
        System.out.printf("trinomial_prices = %.4f%n", trinomialPrices);
    }
}
