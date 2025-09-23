import java.util.function.Function;

public class EUCompoundTri {
    
    public static double euCompoundTri(double S0, double T1, double T2, int N, 
                                     double K1, double K2, double p, double r, double sigma) {
        // Checking input arguments
        if (r < 0 || T1 < 0 || T2 < 0 || K1 < 0 || K2 < 0) {
            throw new IllegalArgumentException("Error: invalid input parameters");
        }
        
        double h = T2 / N;
        double u = sigma * Math.sqrt(h / (2 * p));
        
        // Number of steps for compound and underlying option
        int N1 = (int) Math.round(T1 * N / T2);
        int N2 = N - N1;
        
        // Payoff functions
        Function<Double, Double> payoffUnderlying = x -> Math.max(0, x - K2);
        Function<Double, Double> payoffCompound = x -> Math.max(0, x - K1);
        
        double[][] S = stockPricesNew(S0, N1, u);
        int M = S.length;
        double[][] P = new double[M][N1 + 1]; // Compound option prices
        double[] undPrices = new double[M];
        
        // Calculating underlying asset prices at time T1
        for (int i = 0; i < M; i++) {
            double[][] sTemp = stockPricesNew(S[i][N1], N2, u);
            double[][] undTemp = optionPricesH(sTemp, payoffUnderlying, r, p, h, u);
            undPrices[i] = undTemp[N2][0];
        }
        
        // Calculate final prices, i.e. payoffs, of compound option
        for (int i = 0; i < M; i++) {
            P[i][N1] = payoffCompound.apply(undPrices[i]);
        }
        
        double q0 = 1 - 2 * p;
        double qu = (Math.exp(r * h) - Math.exp(-u)) / (Math.exp(u) - Math.exp(-u)) 
                   - q0 * (1 - Math.exp(-u)) / (Math.exp(u) - Math.exp(-u));
        double qd = (Math.exp(u) - Math.exp(r * h)) / (Math.exp(u) - Math.exp(-u)) 
                   - q0 * (Math.exp(u) - 1) / (Math.exp(u) - Math.exp(-u));
        
        // Recurrence formula to calculate option prices
        for (int j = N1 - 1; j >= 0; j--) {
            for (int i = (N1 - j + 1); i < M - (N1 - j + 1); i++) {
                P[i][j] = Math.exp(-r * h) * (qu * P[i - 1][j + 1] + q0 * P[i][j + 1] + qd * P[i + 1][j + 1]);
            }
        }
        
        // Extract the current price at time 0 (center of the first column)
        return P[N1][0];
    }
    
    private static double[][] stockPricesNew(double S0, int N, double u) {
        int rows = 2 * N + 1;
        double[][] prices = new double[rows][N + 1];
        
        // Initialize first price
        prices[N][0] = S0;
        
        // Build stock price tree
        for (int j = 0; j < N; j++) {
            for (int i = 0; i < rows; i++) {
                if (prices[i][j] != 0) {
                    // Up movement
                    if (i - 1 >= 0) {
                        prices[i - 1][j + 1] = prices[i][j] * Math.exp(u);
                    }
                    // Middle movement
                    prices[i][j + 1] = prices[i][j];
                    // Down movement
                    if (i + 1 < rows) {
                        prices[i + 1][j + 1] = prices[i][j] * Math.exp(-u);
                    }
                }
            }
        }
        
        return prices;
    }
    
    private static double[][] optionPricesH(double[][] stockPrices, 
                                          Function<Double, Double> payoff, 
                                          double r, double p, double h, double u) {
        int N = stockPrices[0].length - 1;
        int M = stockPrices.length;
        double[][] optionPrices = new double[M][N + 1];
        
        double q0 = 1 - 2 * p;
        double qu = (Math.exp(r * h) - Math.exp(-u)) / (Math.exp(u) - Math.exp(-u)) 
                   - q0 * (1 - Math.exp(-u)) / (Math.exp(u) - Math.exp(-u));
        double qd = (Math.exp(u) - Math.exp(r * h)) / (Math.exp(u) - Math.exp(-u)) 
                   - q0 * (Math.exp(u) - 1) / (Math.exp(u) - Math.exp(-u));
        
        // Set final payoffs
        for (int i = 0; i < M; i++) {
            if (stockPrices[i][N] != 0) {
                optionPrices[i][N] = payoff.apply(stockPrices[i][N]);
            }
        }
        
        // Backward induction
        for (int j = N - 1; j >= 0; j--) {
            for (int i = 0; i < M; i++) {
                if (stockPrices[i][j] != 0) {
                    double up = (i - 1 >= 0) ? optionPrices[i - 1][j + 1] : 0;
                    double middle = optionPrices[i][j + 1];
                    double down = (i + 1 < M) ? optionPrices[i + 1][j + 1] : 0;
                    
                    optionPrices[i][j] = Math.exp(-r * h) * (qu * up + q0 * middle + qd * down);
                }
            }
        }
        
        return optionPrices;
    }
    
    public static void main(String[] args) {
        // Parameters
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
