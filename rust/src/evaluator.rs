use crate::error::CalcError;
use crate::parser::Expr;

pub fn evaluate_expr(expr: &Expr) -> Result<f64, CalcError> {
    match expr {
        Expr::Number(n) => Ok(*n),
        Expr::Add(l, r) => Ok(evaluate_expr(l)? + evaluate_expr(r)?),
        Expr::Subtract(l, r) => Ok(evaluate_expr(l)? - evaluate_expr(r)?),
        Expr::Multiply(l, r) => Ok(evaluate_expr(l)? * evaluate_expr(r)?),
        Expr::Divide(l, r) => {
            let right = evaluate_expr(r)?;
            if right == 0.0 {
                return Err(CalcError::DivisionByZero);
            }
            Ok(evaluate_expr(l)? / right)
        }
        Expr::Modulo(l, r) => {
            let right = evaluate_expr(r)?;
            if right == 0.0 {
                return Err(CalcError::DivisionByZero);
            }
            // Real modulo like in most calculators
            Ok(evaluate_expr(l)? % right)
        }
        Expr::Power(l, r) => {
            let left = evaluate_expr(l)?;
            let right = evaluate_expr(r)?;
            Ok(left.powf(right))
        }
        Expr::Negate(e) => Ok(-evaluate_expr(e)?),
        Expr::Factorial(e) => {
            let val = evaluate_expr(e)?;
            if val < 0.0 || val.fract() != 0.0 {
                return Err(CalcError::DomainError("Factorial is only defined for non-negative integers".to_string()));
            }
            if val > 170.0 {
                return Err(CalcError::Overflow);
            }
            let mut result = 1.0;
            for i in 2..=(val as u64) {
                result *= i as f64;
            }
            Ok(result)
        }
        Expr::Sin(e) => Ok(evaluate_expr(e)?.sin()),
        Expr::Cos(e) => Ok(evaluate_expr(e)?.cos()),
        Expr::Tan(e) => Ok(evaluate_expr(e)?.tan()),
        Expr::Log(e) => {
            let val = evaluate_expr(e)?;
            if val <= 0.0 {
                return Err(CalcError::DomainError("Log is only defined for positive numbers".to_string()));
            }
            Ok(val.log10())
        }
        Expr::Ln(e) => {
            let val = evaluate_expr(e)?;
            if val <= 0.0 {
                return Err(CalcError::DomainError("Ln is only defined for positive numbers".to_string()));
            }
            Ok(val.ln())
        }
        Expr::Sqrt(e) => {
            let val = evaluate_expr(e)?;
            if val < 0.0 {
                return Err(CalcError::DomainError("Square root is not defined for negative numbers".to_string()));
            }
            Ok(val.sqrt())
        }
    }
}
