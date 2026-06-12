use crate::calculator::{evaluator, memory, parser};
use crate::shared::history;
pub use crate::shared::history::HistoryEntry;
use flutter_rust_bridge::frb;

/// Represents the result of a calculation to be returned to Flutter.
#[frb]
pub struct CalcResult {
    pub value: f64,
    pub formatted: String,
    pub exact_fraction: Option<String>,
}

fn perform_evaluation<E: evaluator::Evaluator>(
    expression: String,
    eval: &E,
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

    let calc_val =
        evaluator::evaluate_expr(&ast, eval, is_degree, ans_value).map_err(|e| e.to_string())?;

    let val = calc_val.to_float();
    // Check for NaN or Inf
    if val.is_nan() || val.is_infinite() {
        return Err("Result is undefined or too large".to_string());
    }

    Ok(CalcResult {
        value: val,
        formatted: format_result(val, 10),
        exact_fraction: calc_val.to_exact_fraction_string(),
    })
}

/// Evaluates a mathematical expression string from Flutter and returns the result.
/// This is a synchronous Flutter Rust Bridge function.
#[frb(sync)]
pub fn evaluate(expression: String, is_degree: bool, ans_value: f64) -> Result<CalcResult, String> {
    perform_evaluation(expression, &evaluator::BasicEvaluator, is_degree, ans_value)
}

/// Evaluates a mathematical expression string with variables from Flutter and returns the result.
#[frb(sync)]
pub fn evaluate_with_vars(
    expression: String,
    vars: std::collections::HashMap<String, f64>,
    is_degree: bool,
    ans_value: f64,
) -> Result<CalcResult, String> {
    let func_eval = evaluator::FunctionEvaluator::new(vars);
    perform_evaluation(expression, &func_eval, is_degree, ans_value)
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
    history::BASIC_HISTORY.add(expression, result);
}

/// Retrieves all history entries to display in Flutter.
#[frb(sync)]
pub fn history_get_all() -> Vec<HistoryEntry> {
    history::BASIC_HISTORY.get_all()
}

/// Clears all history entries.
#[frb(sync)]
pub fn history_clear() {
    history::BASIC_HISTORY.clear();
}

/// Deletes a specific history entry.
#[frb(sync)]
pub fn history_delete(index: usize) {
    history::BASIC_HISTORY.delete(index);
}

/// Saves the calculation history to a file path provided by Flutter.
pub fn history_save(path: String) -> Result<(), String> {
    history::BASIC_HISTORY.save(&path).map_err(|e| e.to_string())
}

/// Loads the calculation history from a file path provided by Flutter.
pub fn history_load(path: String) -> Result<(), String> {
    history::BASIC_HISTORY.load(&path).map_err(|e| e.to_string())
}

/// Adds a func history entry from Flutter.
#[frb(sync)]
pub fn func_history_add(expression: String, result: String) {
    history::FUNC_HISTORY.add(expression, result);
}

/// Retrieves all func history entries to display in Flutter.
#[frb(sync)]
pub fn func_history_get_all() -> Vec<HistoryEntry> {
    history::FUNC_HISTORY.get_all()
}

/// Clears all func history entries.
#[frb(sync)]
pub fn func_history_clear() {
    history::FUNC_HISTORY.clear();
}

/// Deletes a specific func history entry.
#[frb(sync)]
pub fn func_history_delete(index: usize) {
    history::FUNC_HISTORY.delete(index);
}

/// Saves the func history to a file path provided by Flutter.
pub fn func_history_save(path: String) -> Result<(), String> {
    history::FUNC_HISTORY.save(&path).map_err(|e| e.to_string())
}

/// Loads the func history from a file path provided by Flutter.
pub fn func_history_load(path: String) -> Result<(), String> {
    history::FUNC_HISTORY.load(&path).map_err(|e| e.to_string())
}

/// Extracts variables from an expression string.
#[frb(sync)]
pub fn extract_variables(expression: String) -> Result<Vec<String>, String> {
    if expression.trim().is_empty() {
        return Ok(Vec::new());
    }

    let mut vars = Vec::new();
    let mut current_var = String::new();

    for c in expression.chars() {
        if c.is_alphabetic() || c == '_' {
            current_var.push(c);
        } else {
            if !current_var.is_empty() {
                if is_variable(&current_var) {
                    vars.push(current_var.clone());
                }
                current_var.clear();
            }
        }
    }
    if !current_var.is_empty() && is_variable(&current_var) {
        vars.push(current_var);
    }

    vars.sort();
    vars.dedup();
    Ok(vars)
}

fn is_variable(ident: &str) -> bool {
    match ident.to_lowercase().as_str() {
        "mod" | "sin" | "cos" | "tan" | "asin" | "acos" | "atan" | "sinh" | "cosh" | "tanh"
        | "asinh" | "acosh" | "atanh" | "log" | "log_" | "ln" | "sqrt" | "pi" | "e" | "ans" => {
            false
        }
        _ => true,
    }
}
