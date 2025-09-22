public class AsianOptionPricer {
    
    public static class Result {
        public double V;
        public double P_tot;
        
        public Result(double V, double P_tot) {
            this.V = V;
            this.P_tot = P_tot;
        }
    }
    
    public static Result recursiveAsian(double V, int N, double K, int n, double P_tot, 
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
                double payoff = Math.max(averagePrice - K, 0);
                currentV += newP * payoff;
            } else {
                // Increases n until n = N
                Result recursiveResult = recursiveAsian(currentV, N, K, n + 1, 
                                                       currentP_tot, newP, Q, M, newAllS);
                currentV = recursiveResult.V;
                currentP_tot = recursiveResult.P_tot;
            }
        }
        
        return new Result(currentV, currentP_tot);
    }
    
    public static void main(String[] args) {
        // Parameters from the paper (Table 5.1)
        double S0 = 10;
        double K = 8;
        double r = 0.01;
        double T = 0.062;   // Time to maturity
        double sigma = 0.2;
        double p = 0.25;    // Probability for up/down (p_u = p_d = p)
        
        int N = 11;
        
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
        Result result = recursiveAsian(V, N, K, n, P_tot, P, Q, M, allS);
        
        // Discount the price
        double price = Math.exp(-r * T) * result.V;
        System.out.printf("fair-price: %.4f%n", price);
    }
}
