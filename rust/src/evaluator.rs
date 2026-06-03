use crate::error::CalcError;
use crate::parser::Expr;

pub fn evaluate_expr(expr: &Expr, is_degree: bool, ans_value: f64) -> Result<f64, CalcError> {
    match expr {
        Expr::Number(n) => Ok(*n),
        Expr::Ans => Ok(ans_value),
        Expr::Add(l, r) => Ok(evaluate_expr(l, is_degree, ans_value)? + evaluate_expr(r, is_degree, ans_value)?),
        Expr::Subtract(l, r) => Ok(evaluate_expr(l, is_degree, ans_value)? - evaluate_expr(r, is_degree, ans_value)?),
        Expr::Multiply(l, r) => Ok(evaluate_expr(l, is_degree, ans_value)? * evaluate_expr(r, is_degree, ans_value)?),
        Expr::Divide(l, r) => {
            let right = evaluate_expr(r, is_degree, ans_value)?;
            if right == 0.0 {
                return Err(CalcError::DivisionByZero);
            }
            Ok(evaluate_expr(l, is_degree, ans_value)? / right)
        }
        Expr::Modulo(l, r) => {
            let right = evaluate_expr(r, is_degree, ans_value)?;
            if right == 0.0 {
                return Err(CalcError::DivisionByZero);
            }
            // Real modulo like in most calculators
            Ok(evaluate_expr(l, is_degree, ans_value)? % right)
        }
        Expr::Power(l, r) => {
            let left = evaluate_expr(l, is_degree, ans_value)?;
            let right = evaluate_expr(r, is_degree, ans_value)?;
            Ok(left.powf(right))
        }
        Expr::Negate(e) => Ok(-evaluate_expr(e, is_degree, ans_value)?),
        Expr::Factorial(e) => {
            let val = evaluate_expr(e, is_degree, ans_value)?;
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
        Expr::Sin(e) => {
            let val = evaluate_expr(e, is_degree, ans_value)?;
            Ok(if is_degree { val.to_radians().sin() } else { val.sin() })
        }
        Expr::Cos(e) => {
            let val = evaluate_expr(e, is_degree, ans_value)?;
            let cos_val = if is_degree { val.to_radians().cos() } else { val.cos() };
            Ok(if cos_val.abs() < 1e-12 { 0.0 } else { cos_val })
        }
        Expr::Tan(e) => {
            let val = evaluate_expr(e, is_degree, ans_value)?;
            Ok(if is_degree { val.to_radians().tan() } else { val.tan() })
        }
        Expr::Asin(e) => {
            let val = evaluate_expr(e, is_degree, ans_value)?;
            if !(-1.0..=1.0).contains(&val) {
                return Err(CalcError::DomainError("Asin is only defined for domain [-1, 1]".to_string()));
            }
            let res = val.asin();
            Ok(if is_degree { res.to_degrees() } else { res })
        }
        Expr::Acos(e) => {
            let val = evaluate_expr(e, is_degree, ans_value)?;
            if !(-1.0..=1.0).contains(&val) {
                return Err(CalcError::DomainError("Acos is only defined for domain [-1, 1]".to_string()));
            }
            let res = val.acos();
            Ok(if is_degree { res.to_degrees() } else { res })
        }
        Expr::Atan(e) => {
            let val = evaluate_expr(e, is_degree, ans_value)?;
            let res = val.atan();
            Ok(if is_degree { res.to_degrees() } else { res })
        }
        Expr::Sinh(e) => Ok(evaluate_expr(e, is_degree, ans_value)?.sinh()),
        Expr::Cosh(e) => Ok(evaluate_expr(e, is_degree, ans_value)?.cosh()),
        Expr::Tanh(e) => Ok(evaluate_expr(e, is_degree, ans_value)?.tanh()),
        Expr::Asinh(e) => Ok(evaluate_expr(e, is_degree, ans_value)?.asinh()),
        Expr::Acosh(e) => {
            let val = evaluate_expr(e, is_degree, ans_value)?;
            if val < 1.0 {
                return Err(CalcError::DomainError("Acosh is only defined for numbers >= 1".to_string()));
            }
            Ok(val.acosh())
        }
        Expr::Atanh(e) => {
            let val = evaluate_expr(e, is_degree, ans_value)?;
            if val <= -1.0 || val >= 1.0 {
                return Err(CalcError::DomainError("Atanh is only defined for domain (-1, 1)".to_string()));
            }
            Ok(val.atanh())
        }
        Expr::Log(e) => {
            let val = evaluate_expr(e, is_degree, ans_value)?;
            if val <= 0.0 {
                return Err(CalcError::DomainError("Log is only defined for positive numbers".to_string()));
            }
            Ok(val.log10())
        }
        Expr::Ln(e) => {
            let val = evaluate_expr(e, is_degree, ans_value)?;
            if val <= 0.0 {
                return Err(CalcError::DomainError("Ln is only defined for positive numbers".to_string()));
            }
            Ok(val.ln())
        }
        Expr::Sqrt(e) => {
            let val = evaluate_expr(e, is_degree, ans_value)?;
            if val < 0.0 {
                return Err(CalcError::DomainError("Square root is not defined for negative numbers".to_string()));
            }
            Ok(val.sqrt())
        }
    }
}
