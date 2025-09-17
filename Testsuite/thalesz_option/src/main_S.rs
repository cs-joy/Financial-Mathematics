use std::fmt;

/// StockPriceTree - Generates a trinomial stock price tree model
/// Converts MATLAB's StockPricesNew function to optimized Rust 1.89.0
#[derive(Debug)]
pub struct StockPriceTree {
    tree: Vec<Vec<Option<f64>>>,
    n_steps: usize,
}

impl StockPriceTree {
    /// Generates a trinomial stock price tree
    /// # Arguments
    /// * `s0` - initial stock price (must be positive)
    /// * `n` - number of time steps (must be non-negative)
    /// * `u` - volatility parameter (must be positive)
    /// # Returns
    /// `Result<StockPriceTree, String>` - the stock price tree or error message
    pub fn new(s0: f64, n: usize, u: f64) -> Result<Self, String> {
        // Input validation
        if s0 <= 0.0 {
            return Err(format!("Initial stock price S0 must be positive. Got: {}", s0));
        }
        if u <= 0.0 {
            return Err(format!("Volatility parameter u must be positive. Got: {}", u));
        }

        // Handle edge case: n = 0
        if n == 0 {
            let mut tree = Vec::with_capacity(1);
            tree.push(vec![Some(s0)]);
            return Ok(Self { tree, n_steps: n });
        }

        // Initialize the price tree matrix
        // MATLAB: S=zeros(2*N+1,N+1)
        let rows = 2 * n + 1;
        let cols = n + 1;
        let mut tree = vec![vec![None; cols]; rows];

        // Set initial price at center of first column
        // MATLAB: S(N+1,1)=S0
        tree[n][0] = Some(s0);

        // Precompute exponential factors for performance
        let exp_up = u.exp();
        let exp_down = (-u).exp();

        // Build the binomial tree
        for i in 0..n {
            // Copy previous column values to current column
            // MATLAB: S(:,i+1)=S(:,i)
            for row in 0..rows {
                tree[row][i + 1] = tree[row][i];
            }

            // Calculate upward movement
            // MATLAB: S(N+1-i,i+1)=S(N+2-i,i)*exp(u)
            let up_row = n as isize - 1 - i as isize;
            if up_row >= 0 && up_row < rows as isize {
                let source_row = n as isize - i as isize;
                if source_row >= 0 && source_row < rows as isize {
                    if let Some(price) = tree[source_row as usize][i] {
                        tree[up_row as usize][i + 1] = Some(price * exp_up);
                    }
                }
            }

            // Calculate downward movement
            // MATLAB: S(N+i+1,i+1)=S(N+i,i)*exp(-u)
            let down_row = n as isize + 1 + i as isize;
            if down_row >= 0 && down_row < rows as isize {
                let source_row = n as isize + i as isize;
                if source_row >= 0 && source_row < rows as isize {
                    if let Some(price) = tree[source_row as usize][i] {
                        tree[down_row as usize][i + 1] = Some(price * exp_down);
                    }
                }
            }
        }

        Ok(Self { tree, n_steps: n })
    }

    /// Get a reference to the underlying tree data
    pub fn get_tree(&self) -> &Vec<Vec<Option<f64>>> {
        &self.tree
    }

    /// Get the number of time steps
    pub fn n_steps(&self) -> usize {
        self.n_steps
    }

    /// Get the price at specific row and column
    pub fn get_price(&self, row: usize, col: usize) -> Option<f64> {
        if row < self.tree.len() && col < self.tree[0].len() {
            self.tree[row][col]
        } else {
            None
        }
    }

    /// Print the tree in a readable format
    pub fn print(&self) {
        for col in 0..self.tree[0].len() {
            print!("Time {:2}: ", col);
            for row in 0..self.tree.len() {
                if let Some(price) = self.tree[row][col] {
                    print!("{:8.2} ", price);
                } else {
                    print!("          "); // Space for None values
                }
            }
            println!();
        }
    }
}

impl fmt::Display for StockPriceTree {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        for col in 0..self.tree[0].len() {
            write!(f, "Time {:2}: ", col)?;
            for row in 0..self.tree.len() {
                if let Some(price) = self.tree[row][col] {
                    write!(f, "{:8.2} ", price)?;
                } else {
                    write!(f, "          ")?;
                }
            }
            writeln!(f)?;
        }
        Ok(())
    }
}


/// Example usage and testing
fn main() -> Result<(), String> {
    // Test case 1: Normal operation
    println!("=== Test Case 1: Normal Operation ===");
    let tree1 = StockPriceTree::new(100.0, 3, 0.1)?;
    tree1.print();
    
    // Test case 2: Edge Case n=0
    println!("\n=== Test Case 2: Edge Case n=0 ===");
    let tree2 = StockPriceTree::new(50.0, 0, 0.05)?;
    tree2.print();
    
    // Test case 3: Error handling
    println!("\n=== Test Case 3: Error Handling ===");
    match StockPriceTree::new(-100.0, 3, 0.1) {
        Ok(_) => println!("Unexpected success"),
        Err(e) => println!("Caught expected error: {}", e),
    }
    
    match StockPriceTree::new(100.0, 3, -0.1) {
        Ok(_) => println!("Unexpected success"),
        Err(e) => println!("Caught expected error: {}", e),
    }

    // Additional test: Access specific prices
    println!("\n=== Accessing Specific Prices ===");
    let tree3 = StockPriceTree::new(100.0, 2, 0.1)?;
    println!("Price at (2, 1): {:?}", tree3.get_price(2, 1));
    println!("Price at (10, 1): {:?}", tree3.get_price(10, 1)); // Out of bounds

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use approx::assert_relative_eq;

    #[test]
    fn test_normal_operation() {
        let tree = StockPriceTree::new(100.0, 2, 0.1).unwrap();
        let expected_prices = vec![
            vec![None, None, None, None, None, None],
            vec![None, None, None, None, None, None],
            vec![Some(100.0), Some(100.0), Some(100.0), None, None, None],
            vec![None, None, None, None, None, None],
            vec![None, None, None, None, None, None],
            vec![None, None, None, None, None, None],
        ];
        
        // Check specific known values
        assert_relative_eq!(tree.get_price(2, 0).unwrap(), 100.0);
        assert_relative_eq!(tree.get_price(1, 1).unwrap(), 100.0 * 0.1f64.exp());
        assert_relative_eq!(tree.get_price(3, 1).unwrap(), 100.0 * (-0.1f64).exp());
    }

    #[test]
    fn test_edge_case_n_zero() {
        let tree = StockPriceTree::new(50.0, 0, 0.05).unwrap();
        assert_eq!(tree.tree.len(), 1);
        assert_eq!(tree.tree[0].len(), 1);
        assert_relative_eq!(tree.tree[0][0].unwrap(), 50.0);
    }

    #[test]
    fn test_error_handling() {
        assert!(StockPriceTree::new(-100.0, 3, 0.1).is_err());
        assert!(StockPriceTree::new(100.0, 3, -0.1).is_err());
    }

    #[test]
    fn test_tree_structure() {
        let tree = StockPriceTree::new(100.0, 1, 0.1).unwrap();
        // Should have 3 rows (2*1 + 1) and 2 columns (1 + 1)
        assert_eq!(tree.tree.len(), 3);
        assert_eq!(tree.tree[0].len(), 2);
    }
}





/*
 * Output::
=== Test Case 1: Normal Operation ===
Time  0:                                 100.00                               
Time  1:                       110.52   100.00    90.48                     
Time  2:             122.14   110.52   100.00    90.48    81.87           
Time  3:   134.99   122.14   110.52   100.00    90.48    81.87    74.08 

=== Test Case 2: Edge Case n=0 ===
Time  0:    50.00 

=== Test Case 3: Error Handling ===
Caught expected error: Initial stock price S0 must be positive. Got: -100
Caught expected error: Volatility parameter u must be positive. Got: -0.1

=== Accessing Specific Prices ===
Price at (2, 1): Some(100.0)
Price at (10, 1): None
*/
