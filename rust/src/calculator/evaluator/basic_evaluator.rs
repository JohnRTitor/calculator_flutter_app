use crate::calculator::error::CalcError;
use crate::calculator::evaluator::Evaluator;
use crate::calculator::rational::CalcValue;

use flutter_rust_bridge::frb;

/// A basic evaluator that does not support variable resolution.
/// Designed for the standard calculator mode.
#[frb(ignore)]
pub struct BasicEvaluator;

impl Evaluator for BasicEvaluator {
    fn resolve_variable(&self, name: &str) -> Result<CalcValue, CalcError> {
        Err(CalcError::InvalidExpression(format!(
            "Variables are not supported in standard mode: {}",
            name
        )))
    }
}
