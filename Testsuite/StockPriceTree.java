import java.util.Arrays;

/**
 * StockPriceTree - Generates a binomial stock price tree model
 * Converts MATLAB's StockPricesNew function to optimized Java 21
 */
public class StockPriceTree {
    
    /**
     * Generates a binomial stock price tree
     * @param S0 initial stock price (must be positive)
     * @param N number of time steps (must be non-negative)
     * @param u volatility parameter (must be positive)
     * @return 2D array representing the stock price tree
     * @throws IllegalArgumentException for invalid parameters
     */
    public static double[][] generateStockPrices(double S0, int N, double u) {
        // Input validation with detailed error messages
        if (S0 <= 0) {
            throw new IllegalArgumentException("Initial stock price S0 must be positive. Got: " + S0);
        }
        if (N < 0) {
            throw new IllegalArgumentException("Number of steps N must be non-negative. Got: " + N);
        }
        if (u <= 0) {
            throw new IllegalArgumentException("Volatility parameter u must be positive. Got: " + u);
        }
        
        // Handle edge case: N = 0
        if (N == 0) {
            return new double[][]{{S0}};
        }
        
        // Initialize the price tree matrix
        // MATLAB: S=zeros(2*N+1,N+1)
        double[][] stockTree = new double[2 * N + 1][N + 1];
        
        // Initialize all values to NaN to identify unused cells
        for (double[] row : stockTree) {
            Arrays.fill(row, Double.NaN);
        }
        
        // Set initial price at center of first column
        // MATLAB: S(N+1,1)=S0
        stockTree[N][0] = S0;
        
        // Precompute exponential factors for performance
        final double expUp = Math.exp(u);
        final double expDown = Math.exp(-u);
        
        // Build the binomial tree
        for (int i = 0; i < N; i++) {
            // Copy previous column values to current column
            // MATLAB: S(:,i+1)=S(:,i)
            for (int row = 0; row < stockTree.length; row++) {
                if (!Double.isNaN(stockTree[row][i])) {
                    stockTree[row][i + 1] = stockTree[row][i];
                }
            }
            
            // Calculate upward movement
            // MATLAB: S(N+1-i,i+1)=S(N+2-i,i)*exp(u)
            int upRow = N - 1 - i;
            if (upRow >= 0 && upRow < stockTree.length) {
                int sourceRow = N - i;
                if (sourceRow >= 0 && sourceRow < stockTree.length && 
                    !Double.isNaN(stockTree[sourceRow][i])) {
                    stockTree[upRow][i + 1] = stockTree[sourceRow][i] * expUp;
                }
            }
            
            // Calculate downward movement
            // MATLAB: S(N+i+1,i+1)=S(N+i,i)*exp(-u)
            int downRow = N + 1 + i;
            if (downRow >= 0 && downRow < stockTree.length) {
                int sourceRow = N + i;
                if (sourceRow >= 0 && sourceRow < stockTree.length && 
                    !Double.isNaN(stockTree[sourceRow][i])) {
                    stockTree[downRow][i + 1] = stockTree[sourceRow][i] * expDown;
                }
            }
        }
        
        return stockTree;
    }
    
    /**
     * Utility method to print the stock price tree in a readable format
     */
    public static void printTree(double[][] tree) {
        for (int col = 0; col < tree[0].length; col++) {
            System.out.printf("Time %d: ", col);
            for (int row = 0; row < tree.length; row++) {
                if (!Double.isNaN(tree[row][col])) {
                    System.out.printf("%8.2f ", tree[row][col]);
                } else {
                    System.out.printf("         "); // Space for NaN values
                }
            }
            System.out.println();
        }
    }
    
    /**
     * Example usage and testing
     */
    public static void main(String[] args) {
        try {
            // Test case 1: Normal operation
            System.out.println("=== Test Case 1: Normal Operation ===");
            double[][] tree1 = generateStockPrices(100.0, 3, 0.1);
            printTree(tree1);
            
            System.out.println("\n=== Test Case 2: Edge Case N=0 ===");
            double[][] tree2 = generateStockPrices(50.0, 0, 0.05);
            printTree(tree2);
            
            // Test case 3: Error handling
            System.out.println("\n=== Test Case 3: Error Handling ===");
            try {
                generateStockPrices(-100.0, 3, 0.1);
            } catch (IllegalArgumentException e) {
                System.out.println("Caught expected error: " + e.getMessage());
            }
            
        } catch (Exception e) {
            System.err.println("Unexpected error: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
