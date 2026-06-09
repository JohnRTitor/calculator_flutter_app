use crate::calculator::error::CalcError;
use crate::calculator::rational::{CalcValue, Rational};
use crate::calculator::evaluator::Evaluator;
use std::collections::HashMap;

use flutter_rust_bridge::frb;

/// An evaluator that supports variable resolution from a provided environment.
/// Designed for the function evaluator mode.
#[frb(ignore)]
pub struct FunctionEvaluator {
    pub vars: HashMap<String, f64>,
}

impl FunctionEvaluator {
    pub fn new(vars: HashMap<String, f64>) -> Self {
        Self { vars }
    }
}

impl Evaluator for FunctionEvaluator {
    fn resolve_variable(&self, name: &str) -> Result<CalcValue, CalcError> {
        if let Some(&val) = self.vars.get(name) {
            // Support rational arithmetic internally if the variable is an exact integer
            if val.fract() == 0.0 && val >= (i128::MIN as f64) && val <= (i128::MAX as f64) {
                Ok(CalcValue::Rational(Rational::new(val as i128, 1)))
            } else {
                Ok(CalcValue::Float(val))
            }
        } else {
            Err(CalcError::InvalidExpression(format!("Undefined variable: {}", name)))
        }
    }
}
