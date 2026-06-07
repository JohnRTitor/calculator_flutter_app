use crate::calculator::error::CalcError;
use crate::calculator::parser::Expr;
use crate::calculator::rational::{CalcValue, Rational};

pub fn evaluate_expr(expr: &Expr, is_degree: bool, ans_value: f64) -> Result<CalcValue, CalcError> {
    match expr {
        Expr::Number(n) => {
            if n.fract() == 0.0 && *n >= (i128::MIN as f64) && *n <= (i128::MAX as f64) {
                Ok(CalcValue::Rational(Rational::new(*n as i128, 1)))
            } else {
                Ok(CalcValue::Float(*n))
            }
        }
        Expr::Pi => Ok(CalcValue::PiRational(Rational::new(1, 1))),
        Expr::E => Ok(CalcValue::Float(std::f64::consts::E)),
        Expr::Ans => {
            if ans_value.fract() == 0.0
                && ans_value >= (i128::MIN as f64)
                && ans_value <= (i128::MAX as f64)
            {
                Ok(CalcValue::Rational(Rational::new(ans_value as i128, 1)))
            } else {
                Ok(CalcValue::Float(ans_value))
            }
        }
        Expr::Add(l, r) => Ok(
            evaluate_expr(l, is_degree, ans_value)?.add(evaluate_expr(r, is_degree, ans_value)?)
        ),
        Expr::Subtract(l, r) => Ok(
            evaluate_expr(l, is_degree, ans_value)?.sub(evaluate_expr(r, is_degree, ans_value)?)
        ),
        Expr::Multiply(l, r) => Ok(
            evaluate_expr(l, is_degree, ans_value)?.mul(evaluate_expr(r, is_degree, ans_value)?)
        ),
        Expr::Divide(l, r) => evaluate_expr(l, is_degree, ans_value)?
            .div(evaluate_expr(r, is_degree, ans_value)?)
            .map_err(|_| CalcError::DivisionByZero),
        Expr::Modulo(l, r) => evaluate_expr(l, is_degree, ans_value)?
            .modulo(evaluate_expr(r, is_degree, ans_value)?)
            .map_err(|_| CalcError::DivisionByZero),
        Expr::Power(l, r) => {
            let left = evaluate_expr(l, is_degree, ans_value)?;
            let right = evaluate_expr(r, is_degree, ans_value)?;
            Ok(left.pow(right))
        }
        Expr::Negate(e) => Ok(evaluate_expr(e, is_degree, ans_value)?.negate()),
        Expr::Factorial(e) => {
            let val = evaluate_expr(e, is_degree, ans_value)?.to_float();
            if val < 0.0 || val.fract() != 0.0 {
                return Err(CalcError::DomainError(
                    "Factorial is only defined for non-negative integers".to_string(),
                ));
            }
            if val > 170.0 {
                return Err(CalcError::Overflow);
            }
            let mut result = 1.0;
            for i in 2..=(val as u64) {
                result *= i as f64;
            }
            Ok(CalcValue::Float(result))
        }
        Expr::Sin(e) => {
            let val = evaluate_expr(e, is_degree, ans_value)?.to_float();
            let mut res = if is_degree {
                val.to_radians().sin()
            } else {
                val.sin()
            };
            if is_degree && val % 180.0 == 0.0 {
                res = 0.0;
            }
            Ok(CalcValue::Float(res))
        }
        Expr::Cos(e) => {
            let val = evaluate_expr(e, is_degree, ans_value)?.to_float();
            let mut res = if is_degree {
                val.to_radians().cos()
            } else {
                val.cos()
            };
            if is_degree && (val - 90.0) % 180.0 == 0.0 {
                res = 0.0;
            }
            Ok(CalcValue::Float(res))
        }
        Expr::Tan(e) => {
            let val = evaluate_expr(e, is_degree, ans_value)?.to_float();
            if is_degree && (val - 90.0) % 180.0 == 0.0 {
                return Err(CalcError::DomainError("Tangent undefined".to_string()));
            }
            let mut res = if is_degree {
                val.to_radians().tan()
            } else {
                val.tan()
            };
            if is_degree && val % 180.0 == 0.0 {
                res = 0.0;
            }
            Ok(CalcValue::Float(res))
        }
        Expr::Asin(e) => {
            let val = evaluate_expr(e, is_degree, ans_value)?.to_float();
            if !(-1.0..=1.0).contains(&val) {
                return Err(CalcError::DomainError(
                    "Asin is only defined for domain [-1, 1]".to_string(),
                ));
            }
            let res = val.asin();
            Ok(CalcValue::Float(if is_degree {
                res.to_degrees()
            } else {
                res
            }))
        }
        Expr::Acos(e) => {
            let val = evaluate_expr(e, is_degree, ans_value)?.to_float();
            if !(-1.0..=1.0).contains(&val) {
                return Err(CalcError::DomainError(
                    "Acos is only defined for domain [-1, 1]".to_string(),
                ));
            }
            let res = val.acos();
            Ok(CalcValue::Float(if is_degree {
                res.to_degrees()
            } else {
                res
            }))
        }
        Expr::Atan(e) => {
            let val = evaluate_expr(e, is_degree, ans_value)?.to_float();
            let res = val.atan();
            Ok(CalcValue::Float(if is_degree {
                res.to_degrees()
            } else {
                res
            }))
        }
        Expr::Sinh(e) => Ok(CalcValue::Float(
            evaluate_expr(e, is_degree, ans_value)?.to_float().sinh(),
        )),
        Expr::Cosh(e) => Ok(CalcValue::Float(
            evaluate_expr(e, is_degree, ans_value)?.to_float().cosh(),
        )),
        Expr::Tanh(e) => Ok(CalcValue::Float(
            evaluate_expr(e, is_degree, ans_value)?.to_float().tanh(),
        )),
        Expr::Asinh(e) => Ok(CalcValue::Float(
            evaluate_expr(e, is_degree, ans_value)?.to_float().asinh(),
        )),
        Expr::Acosh(e) => {
            let val = evaluate_expr(e, is_degree, ans_value)?.to_float();
            if val < 1.0 {
                return Err(CalcError::DomainError(
                    "Acosh is only defined for numbers >= 1".to_string(),
                ));
            }
            Ok(CalcValue::Float(val.acosh()))
        }
        Expr::Atanh(e) => {
            let val = evaluate_expr(e, is_degree, ans_value)?.to_float();
            if val <= -1.0 || val >= 1.0 {
                return Err(CalcError::DomainError(
                    "Atanh is only defined for domain (-1, 1)".to_string(),
                ));
            }
            Ok(CalcValue::Float(val.atanh()))
        }
        Expr::Log(e) => {
            let val = evaluate_expr(e, is_degree, ans_value)?.to_float();
            if val <= 0.0 {
                return Err(CalcError::DomainError(
                    "Log is only defined for positive numbers".to_string(),
                ));
            }
            Ok(CalcValue::Float(val.log10()))
        }
        Expr::Ln(e) => {
            let val = evaluate_expr(e, is_degree, ans_value)?.to_float();
            if val <= 0.0 {
                return Err(CalcError::DomainError(
                    "Ln is only defined for positive numbers".to_string(),
                ));
            }
            Ok(CalcValue::Float(val.ln()))
        }
        Expr::Sqrt(e) => {
            let val = evaluate_expr(e, is_degree, ans_value)?.to_float();
            if val < 0.0 {
                return Err(CalcError::DomainError(
                    "Square root is not defined for negative numbers".to_string(),
                ));
            }
            Ok(CalcValue::Float(val.sqrt()))
        }
    }
}
