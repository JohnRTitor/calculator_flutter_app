use crate::calculator::{evaluator, history, memory, parser};
use flutter_rust_bridge::frb;

/// Represents the result of a calculation to be returned to Flutter.
#[frb]
pub struct CalcResult {
    pub value: f64,
    pub formatted: String,
    pub exact_fraction: Option<String>,
}

/// Evaluates a mathematical expression string from Flutter and returns the result.
/// This is a synchronous Flutter Rust Bridge function.
#[frb(sync)]
pub fn evaluate(expression: String, is_degree: bool, ans_value: f64) -> Result<CalcResult, String> {
    if expression.trim().is_empty() {
        return Ok(CalcResult {
            value: 0.0,
            formatted: "0".to_string(),
            exact_fraction: None,
        });
    }

    let tokens = parser::tokenize(&expression).map_err(|e| e.to_string())?;
    let mut p = parser::Parser::new(&tokens);
    let ast = p.parse().map_err(|e| e.to_string())?;

    let basic_eval = evaluator::BasicEvaluator;
    let calc_val = evaluator::evaluate_expr(&ast, &basic_eval, is_degree, ans_value)
        .map_err(|e| e.to_string())?;

    let val = calc_val.to_float();
    // Check for NaN or Inf
    if val.is_nan() || val.is_infinite() {
        return Err("Result is undefined or too large".to_string());
    }

    let mut exact_fraction = None;
    match calc_val {
        crate::calculator::rational::CalcValue::Rational(r) => {
            if r.den != 1 {
                exact_fraction = Some(format!("{}/{}", r.num, r.den));
            }
        }
        crate::calculator::rational::CalcValue::PiRational(r) => {
            if r.num == 0 {
                exact_fraction = Some("0".to_string());
            } else {
                let num_str = if r.num == 1 {
                    "π".to_string()
                } else if r.num == -1 {
                    "-π".to_string()
                } else {
                    format!("{}π", r.num)
                };
                if r.den == 1 {
                    exact_fraction = Some(num_str);
                } else {
                    exact_fraction = Some(format!("{}/{}", num_str, r.den));
                }
            }
        }
        _ => {}
    }

    Ok(CalcResult {
        value: val,
        formatted: format_result(val, 10),
        exact_fraction,
    })
}

/// Formats a floating-point result into a string, trimming trailing zeros and decimals.
#[frb(sync)]
pub fn format_result(value: f64, max_precision: u32) -> String {
    // Basic formatting logic
    let mut s = format!("{:.1$}", value, max_precision as usize);
    if s.contains('.') {
        s = s.trim_end_matches('0').to_string();
        if s.ends_with('.') {
            s.pop();
        }
    }
    s
}

/// Stores a value in the global calculator memory.
#[frb(sync)]
pub fn memory_store(value: f64) {
    memory::store(value);
}

/// Recalls a value from the global calculator memory.
#[frb(sync)]
pub fn memory_recall() -> Option<f64> {
    memory::recall()
}

/// Adds a value to the global calculator memory.
#[frb(sync)]
pub fn memory_add(value: f64) {
    memory::add(value);
}

/// Subtracts a value from the global calculator memory.
#[frb(sync)]
pub fn memory_subtract(value: f64) {
    memory::subtract(value);
}

/// Clears the global calculator memory.
#[frb(sync)]
pub fn memory_clear() {
    memory::clear();
}

/// Adds a history entry from Flutter.
#[frb(sync)]
pub fn history_add(expression: String, result: String) {
    history::add(expression, result);
}

/// Retrieves all history entries to display in Flutter.
#[frb(sync)]
pub fn history_get_all() -> Vec<history::HistoryEntry> {
    history::get_all()
}

/// Clears all history entries.
#[frb(sync)]
pub fn history_clear() {
    history::clear();
}

/// Deletes a specific history entry.
#[frb(sync)]
pub fn history_delete(index: usize) {
    history::delete(index);
}

/// Saves the calculation history to a file path provided by Flutter.
pub fn history_save(path: String) -> Result<(), String> {
    history::save(&path).map_err(|e| e.to_string())
}

/// Loads the calculation history from a file path provided by Flutter.
pub fn history_load(path: String) -> Result<(), String> {
    history::load(&path).map_err(|e| e.to_string())
}

/// Adds a func history entry from Flutter.
#[frb(sync)]
pub fn func_history_add(expression: String, result: String) {
    history::func_history_add(expression, result);
}

/// Retrieves all func history entries to display in Flutter.
#[frb(sync)]
pub fn func_history_get_all() -> Vec<history::HistoryEntry> {
    history::func_history_get_all()
}

/// Clears all func history entries.
#[frb(sync)]
pub fn func_history_clear() {
    history::func_history_clear();
}

/// Deletes a specific func history entry.
#[frb(sync)]
pub fn func_history_delete(index: usize) {
    history::func_history_delete(index);
}

/// Saves the func history to a file path provided by Flutter.
pub fn func_history_save(path: String) -> Result<(), String> {
    history::func_history_save(&path).map_err(|e| e.to_string())
}

/// Loads the func history from a file path provided by Flutter.
pub fn func_history_load(path: String) -> Result<(), String> {
    history::func_history_load(&path).map_err(|e| e.to_string())
}

/// Evaluates a mathematical expression string with variables from Flutter and returns the result.
#[frb(sync)]
pub fn evaluate_with_vars(
    expression: String,
    vars: std::collections::HashMap<String, f64>,
    is_degree: bool,
    ans_value: f64,
) -> Result<CalcResult, String> {
    if expression.trim().is_empty() {
        return Ok(CalcResult {
            value: 0.0,
            formatted: "0".to_string(),
            exact_fraction: None,
        });
    }

    let tokens = parser::tokenize(&expression).map_err(|e| e.to_string())?;
    let mut p = parser::Parser::new(&tokens);
    let ast = p.parse().map_err(|e| e.to_string())?;

    let func_eval = evaluator::FunctionEvaluator::new(vars);
    let calc_val = evaluator::evaluate_expr(&ast, &func_eval, is_degree, ans_value)
        .map_err(|e| e.to_string())?;

    let val = calc_val.to_float();
    if val.is_nan() || val.is_infinite() {
        return Err("Result is undefined or too large".to_string());
    }

    let mut exact_fraction = None;
    match calc_val {
        crate::calculator::rational::CalcValue::Rational(r) => {
            if r.den != 1 {
                exact_fraction = Some(format!("{}/{}", r.num, r.den));
            }
        }
        crate::calculator::rational::CalcValue::PiRational(r) => {
            if r.num == 0 {
                exact_fraction = Some("0".to_string());
            } else {
                let num_str = if r.num == 1 {
                    "π".to_string()
                } else if r.num == -1 {
                    "-π".to_string()
                } else {
                    format!("{}π", r.num)
                };
                if r.den == 1 {
                    exact_fraction = Some(num_str);
                } else {
                    exact_fraction = Some(format!("{}/{}", num_str, r.den));
                }
            }
        }
        _ => {}
    }

    Ok(CalcResult {
        value: val,
        formatted: format_result(val, 10),
        exact_fraction,
    })
}

/// Extracts variables from an expression string.
#[frb(sync)]
pub fn extract_variables(expression: String) -> Result<Vec<String>, String> {
    if expression.trim().is_empty() {
        return Ok(Vec::new());
    }
    let tokens = parser::tokenize(&expression).map_err(|e| e.to_string())?;
    let mut p = parser::Parser::new(&tokens);
    let ast = p.parse().map_err(|e| e.to_string())?;
    let mut vars: Vec<String> = evaluator::extract_variables(&ast).into_iter().collect();
    vars.sort(); // Sort variables alphabetically for consistent UI
    Ok(vars)
}
