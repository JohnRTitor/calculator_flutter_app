use crate::modular_math::error::ModError;
use crate::modular_math::mod_arith;
use crate::modular_math::number_theory;
use crate::modular_math::parser::ModExpr;

pub struct ModResult {
    pub value: String,
    pub details: Option<String>,
    pub modulus_used: Option<i128>,
}

#[derive(Debug, Clone, Copy)]
pub enum StructureMode {
    Ring,
    Field,
    Crt,
}

pub fn evaluate_mod_expr(expr: &ModExpr, context_modulus: Option<i128>, mode: StructureMode) -> Result<ModResult, ModError> {
    match mode {
        StructureMode::Field => {
            if let Some(m) = context_modulus {
                if !mod_arith::is_prime(m) {
                    return Err(ModError::NotPrime(format!("{} is not prime. Field mode requires a prime modulus.", m)));
                }
            }
        }
        _ => {}
    }

    let result = eval(expr, context_modulus)?;
    
    // Check if the top-level expression is one of the special ones that return details
    match expr {
        ModExpr::Egcd(a, b) => {
            let val_a = eval(a, context_modulus)?;
            let val_b = eval(b, context_modulus)?;
            let (g, x, y) = number_theory::extended_gcd(val_a, val_b);
            Ok(ModResult {
                value: g.to_string(),
                details: Some(format!("Bézout: {}({}) + {}({}) = {}", val_a, x, val_b, y, g)),
                modulus_used: None,
            })
        }
        ModExpr::Crt(pairs) => {
            let mut eval_pairs = Vec::new();
            for (r_expr, m_expr) in pairs {
                let r = eval(r_expr, context_modulus)?;
                let m = eval(m_expr, context_modulus)?;
                eval_pairs.push((r, m));
            }
            let (sol, m) = number_theory::crt(&eval_pairs)?;
            Ok(ModResult {
                value: sol.to_string(),
                details: Some(format!("Solution modulo {}", m)),
                modulus_used: Some(m),
            })
        }
        _ => {
            let m_used = match expr {
                ModExpr::Modulo(_, m) => Some(eval(m, context_modulus)?),
                ModExpr::PowMod(_, _, m) => Some(eval(m, context_modulus)?),
                ModExpr::Inv(_, m) => Some(eval(m, context_modulus)?),
                _ => context_modulus
            };

            let final_val = if let Some(m) = m_used {
                mod_arith::mod_reduce(result, m)
            } else {
                result
            };

            Ok(ModResult {
                value: final_val.to_string(),
                details: None,
                modulus_used: m_used,
            })
        }
    }
}

fn eval(expr: &ModExpr, context_modulus: Option<i128>) -> Result<i128, ModError> {
    match expr {
        ModExpr::Number(n) => Ok(*n),
        ModExpr::Add(a, b) => {
            let val_a = eval(a, context_modulus)?;
            let val_b = eval(b, context_modulus)?;
            if let Some(m) = context_modulus {
                Ok(mod_arith::mod_add(val_a, val_b, m))
            } else {
                Ok(val_a + val_b)
            }
        }
        ModExpr::Subtract(a, b) => {
            let val_a = eval(a, context_modulus)?;
            let val_b = eval(b, context_modulus)?;
            if let Some(m) = context_modulus {
                Ok(mod_arith::mod_sub(val_a, val_b, m))
            } else {
                Ok(val_a - val_b)
            }
        }
        ModExpr::Multiply(a, b) => {
            let val_a = eval(a, context_modulus)?;
            let val_b = eval(b, context_modulus)?;
            if let Some(m) = context_modulus {
                Ok(mod_arith::mod_mul(val_a, val_b, m))
            } else {
                Ok(val_a * val_b)
            }
        }
        ModExpr::Divide(a, b) => {
            let val_a = eval(a, context_modulus)?;
            let val_b = eval(b, context_modulus)?;
            if val_b == 0 {
                return Err(ModError::DivisionByZero);
            }
            if let Some(m) = context_modulus {
                mod_arith::mod_div(val_a, val_b, m)
            } else {
                if val_a % val_b != 0 {
                    return Err(ModError::InvalidExpression(format!("{} is not divisible by {} without modulus", val_a, val_b)));
                }
                Ok(val_a / val_b)
            }
        }
        ModExpr::Power(a, b) => {
            let val_a = eval(a, context_modulus)?;
            let val_b = eval(b, context_modulus)?;
            if let Some(m) = context_modulus {
                mod_arith::mod_pow(val_a, val_b, m)
            } else {
                if val_b < 0 {
                    return Err(ModError::InvalidExpression("Negative exponent without modulus".to_string()));
                }
                if val_b > std::u32::MAX as i128 {
                    return Err(ModError::Overflow);
                }
                val_a.checked_pow(val_b as u32).ok_or(ModError::Overflow)
            }
        }
        ModExpr::Modulo(a, b) => {
            let val_a = eval(a, context_modulus)?;
            let val_b = eval(b, context_modulus)?;
            if val_b <= 0 {
                return Err(ModError::InvalidModulus("Modulus must be positive".to_string()));
            }
            Ok(mod_arith::mod_reduce(val_a, val_b))
        }
        ModExpr::PowMod(a, b, m) => {
            let val_a = eval(a, context_modulus)?;
            let val_b = eval(b, context_modulus)?;
            let val_m = eval(m, context_modulus)?;
            mod_arith::mod_pow(val_a, val_b, val_m)
        }
        ModExpr::Inv(a, m) => {
            let val_a = eval(a, context_modulus)?;
            let val_m = eval(m, context_modulus)?;
            mod_arith::mod_inv(val_a, val_m)
        }
        ModExpr::Gcd(a, b) => {
            let val_a = eval(a, context_modulus)?;
            let val_b = eval(b, context_modulus)?;
            Ok(number_theory::gcd(val_a, val_b))
        }
        ModExpr::Egcd(a, b) => {
            let val_a = eval(a, context_modulus)?;
            let val_b = eval(b, context_modulus)?;
            let (g, _, _) = number_theory::extended_gcd(val_a, val_b);
            Ok(g)
        }
        ModExpr::Crt(pairs) => {
            let mut eval_pairs = Vec::new();
            for (r_expr, m_expr) in pairs {
                let r = eval(r_expr, context_modulus)?;
                let m = eval(m_expr, context_modulus)?;
                eval_pairs.push((r, m));
            }
            let (sol, _) = number_theory::crt(&eval_pairs)?;
            Ok(sol)
        }
        ModExpr::Negate(a) => {
            let val_a = eval(a, context_modulus)?;
            if let Some(m) = context_modulus {
                Ok(mod_arith::mod_neg(val_a, m))
            } else {
                Ok(-val_a)
            }
        }
    }
}
