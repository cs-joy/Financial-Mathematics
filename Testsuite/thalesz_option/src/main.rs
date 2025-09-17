use std::error::Error;
use std::fmt;

type PayoffFn = Box<dyn Fn(f64) -> f64>;

#[derive(Debug)]
pub enum PricingError {
    InvalidInput(String),
    NumericalError(String),
    TreeStructureError(String),
}

impl fmt::Display for PricingError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            PricingError::InvalidInput(msg) => write!(f, "Invalid input: {}", msg),
            PricingError::NumericalError(msg) => write!(f, "Numerical error: {}", msg),
            PricingError::TreeStructureError(msg) => write!(f, "Tree structure error: {}", msg),
        }
    }
}

impl Error for PricingError {}

/// Option pricing using trinomial model
pub struct TrinomialOptionPricing;

impl TrinomialOptionPricing {
    /// Prices an option using the trinomial model
    pub fn price_option(
        s: &[Vec<Option<f64>>],
        payoff_func: PayoffFn,
        r: f64,
        p: f64,
        h: f64,
        u: f64,
    ) -> Result<f64, PricingError> {
        // Input validation
        Self::validate_inputs(s, r, p, h, u)?;
        
        let m = s.len();
        let n = s[0].len();
        
        // Initialize price matrix
        let mut p_matrix = vec![vec![None; n]; m];
        
        // Calculate risk-neutral probabilities
        let exp_rh = (r * h).exp();
        let exp_u = u.exp();
        let exp_neg_u = (-u).exp();
        let denominator = exp_u - exp_neg_u;
        
        if denominator.abs() < 1e-10 {
            return Err(PricingError::NumericalError(
                "Denominator too small, u parameter may cause numerical instability".to_string(),
            ));
        }
        
        let q0 = 1.0 - 2.0 * p;
        let qu = (exp_rh - exp_neg_u) / denominator - q0 * (1.0 - exp_neg_u) / denominator;
        let qd = (exp_u - exp_rh) / denominator - q0 * (exp_u - 1.0) / denominator;
        
        // Validate probabilities
        Self::validate_probabilities(qu, q0, qd, exp_rh)?;
        
        // Terminal payoff
        for i in 0..m {
            if let Some(price) = s[i][n - 1] {
                p_matrix[i][n - 1] = Some(payoff_func(price));
            }
        }
        
        // Backward induction
        let discount_factor = (-r * h).exp();
        
        for j in (0..n - 1).rev() {
            let min_row = n - j - 1;
            let max_row = m - (n - j - 1) - 1;
            
            for i in min_row..=max_row {
                if i > 0 && i < m - 1 {
                    if let (Some(_s_val), Some(_p_up), Some(_p_mid), Some(_p_down)) = (
                        s[i][j],
                        p_matrix[i - 1][j + 1],
                        p_matrix[i][j + 1],
                        p_matrix[i + 1][j + 1],
                    ) {
                        let price = discount_factor * (qu * _p_up + q0 * _p_mid + qd * _p_down);
                        p_matrix[i][j] = Some(price);
                    }
                }
            }
        }
        
        // The option price is at the root of the tree
        let root_row = m / 2;
        p_matrix[root_row][0].ok_or_else(|| {
            PricingError::TreeStructureError("Option price at root is None. Check input parameters.".to_string())
        })
    }
    
    fn validate_inputs(
        s: &[Vec<Option<f64>>],
        r: f64,
        p: f64,
        h: f64,
        u: f64,
    ) -> Result<(), PricingError> {
        if s.is_empty() || s[0].is_empty() {
            return Err(PricingError::InvalidInput(
                "Stock price tree must not be empty".to_string(),
            ));
        }
        
        if h <= 0.0 {
            return Err(PricingError::InvalidInput(format!(
                "Time step h must be positive. Got: {}",
                h
            )));
        }
        
        if u <= 0.0 {
            return Err(PricingError::InvalidInput(format!(
                "Volatility parameter u must be positive. Got: {}",
                u
            )));
        }
        
        if p < 0.0 || p > 0.5 {
            return Err(PricingError::InvalidInput(format!(
                "Probability parameter p must be between 0 and 0.5. Got: {}",
                p
            )));
        }
        
        if r < 0.0 {
            return Err(PricingError::InvalidInput(format!(
                "Risk-free rate r must be non-negative. Got: {}",
                r
            )));
        }
        
        // Check if s is a proper tree structure
        let expected_len = s[0].len();
        for row in s {
            if row.len() != expected_len {
                return Err(PricingError::InvalidInput(
                    "Stock price tree must have consistent column lengths".to_string(),
                ));
            }
        }
        
        Ok(())
    }
    
    fn validate_probabilities(qu: f64, q0: f64, qd: f64, exp_rh: f64) -> Result<(), PricingError> {
        let sum = qu + q0 + qd;
        let tolerance = 1e-8;
        
        if (sum - 1.0).abs() > tolerance {
            return Err(PricingError::NumericalError(format!(
                "Probabilities don't sum to 1 (sum={:.8}, qu={:.8}, q0={:.8}, qd={:.8}, exp(rh)={:.8})",
                sum, qu, q0, qd, exp_rh
            )));
        }
        
        if qu < -tolerance || q0 < -tolerance || qd < -tolerance {
            return Err(PricingError::NumericalError(format!(
                "Negative probabilities detected (qu={:.8}, q0={:.8}, qd={:.8})",
                qu, q0, qd
            )));
        }
        
        Ok(())
    }
    
    // Example payoff functions
    pub fn call_payoff(strike: f64) -> PayoffFn {
        Box::new(move |price| (price - strike).max(0.0))
    }
    
    pub fn put_payoff(strike: f64) -> PayoffFn {
        Box::new(move |price| (strike - price).max(0.0))
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use approx::assert_relative_eq;

    #[test]
    fn test_option_pricing() -> Result<(), Box<dyn Error>> {
        // Create a simple test tree
        let tree = vec![
            vec![None, None, Some(110.0)],
            vec![None, Some(105.0), Some(100.0)],
            vec![Some(100.0), Some(95.0), Some(90.0)],
            vec![None, Some(85.0), Some(80.0)],
            vec![None, None, Some(70.0)],
        ];
        
        let call_price = TrinomialOptionPricing::price_option(
            &tree,
            TrinomialOptionPricing::call_payoff(100.0),
            0.05,
            0.3,
            0.25,
            0.1,
        )?;
        
        assert!(call_price >= 0.0);
        Ok(())
    }
    
    #[test]
    fn test_error_handling() {
        let empty_tree: Vec<Vec<Option<f64>>> = vec![];
        assert!(TrinomialOptionPricing::price_option(
            &empty_tree,
            TrinomialOptionPricing::call_payoff(100.0),
            0.05,
            0.3,
            0.25,
            0.1,
        ).is_err());
    }
}

fn main() -> Result<(), Box<dyn Error>> {
    // Example usage
    let tree = vec![
        vec![None, None, None, Some(133.0)],
        vec![None, None, Some(121.0), Some(110.0)],
        vec![None, Some(110.0), Some(100.0), Some(90.9)],
        vec![Some(100.0), Some(90.9), Some(82.6), Some(75.1)],
        vec![None, Some(82.6), Some(75.1), Some(68.3)],
        vec![None, None, Some(68.3), Some(62.1)],
        vec![None, None, None, Some(56.4)],
    ];
    
    let call_price = TrinomialOptionPricing::price_option(
        &tree,
        TrinomialOptionPricing::call_payoff(100.0),
        0.05,
        0.3,
        0.25,
        0.1,
    )?;
    
    println!("Call option price: {:.4}", call_price);
    
    let put_price = TrinomialOptionPricing::price_option(
        &tree,
        TrinomialOptionPricing::put_payoff(100.0),
        0.05,
        0.3,
        0.25,
        0.1,
    )?;
    
    println!("Put option price: {:.4}", put_price);
    
    Ok(())
} 




/* Output:
Call option price: 2.7354
Put option price: 18.0319
*/
