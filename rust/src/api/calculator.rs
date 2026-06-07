use crate::calculator::{evaluator, history, memory, parser};
use flutter_rust_bridge::frb;

#[frb]
pub struct CalcResult {
    pub value: f64,
    pub formatted: String,
    pub exact_fraction: Option<String>,
}

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
    let calc_val =
        evaluator::evaluate_expr(&ast, is_degree, ans_value).map_err(|e| e.to_string())?;

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
