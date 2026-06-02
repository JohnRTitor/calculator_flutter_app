use crate::{error::CalcError, evaluator, history, memory, parser};
use flutter_rust_bridge::frb;

#[frb]
pub struct CalcResult {
    pub value: f64,
    pub formatted: String,
}

#[frb(sync)]
pub fn evaluate(expression: String) -> Result<CalcResult, String> {
    if expression.trim().is_empty() {
        return Ok(CalcResult { value: 0.0, formatted: "0".to_string() });
    }

    let tokens = parser::tokenize(&expression).map_err(|e| e.to_string())?;
    let mut p = parser::Parser::new(&tokens);
    let ast = p.parse().map_err(|e| e.to_string())?;
    let val = evaluator::evaluate_expr(&ast).map_err(|e| e.to_string())?;
    
    // Check for NaN or Inf
    if val.is_nan() || val.is_infinite() {
        return Err("Result is undefined or too large".to_string());
    }

    Ok(CalcResult {
        value: val,
        formatted: format_result(val, 10),
    })
}

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

#[frb(sync)]
pub fn memory_store(value: f64) {
    memory::store(value);
}

#[frb(sync)]
pub fn memory_recall() -> Option<f64> {
    memory::recall()
}

#[frb(sync)]
pub fn memory_add(value: f64) {
    memory::add(value);
}

#[frb(sync)]
pub fn memory_subtract(value: f64) {
    memory::subtract(value);
}

#[frb(sync)]
pub fn memory_clear() {
    memory::clear();
}

#[frb(sync)]
pub fn history_add(expression: String, result: String) {
    history::add(expression, result);
}

#[frb(sync)]
pub fn history_get_all() -> Vec<history::HistoryEntry> {
    history::get_all()
}

#[frb(sync)]
pub fn history_clear() {
    history::clear();
}

#[frb(sync)]
pub fn history_delete(index: usize) {
    history::delete(index);
}

pub fn history_save(path: String) -> Result<(), String> {
    history::save(&path).map_err(|e| e.to_string())
}

pub fn history_load(path: String) -> Result<(), String> {
    history::load(&path).map_err(|e| e.to_string())
}
