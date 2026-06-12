use crate::modular_math::{evaluator, parser};
use crate::shared::history;
use flutter_rust_bridge::frb;

/// Represents the result of a modular calculation
#[frb]
pub struct ModularResult {
    pub value: String,
    pub details: Option<String>,
    pub modulus_used: Option<String>,
}

#[frb(sync)]
pub fn modular_evaluate(
    expression: String,
    context_modulus: Option<String>,
    mode: String,
) -> Result<ModularResult, String> {
    if expression.trim().is_empty() {
        return Ok(ModularResult {
            value: "0".to_string(),
            details: None,
            modulus_used: None,
        });
    }

    let tokens = parser::tokenize(&expression).map_err(|e| e.to_string())?;
    let ast = parser::parse(&tokens).map_err(|e| e.to_string())?;

    let modulus_i128 = match context_modulus {
        Some(ref s) if !s.trim().is_empty() => Some(s.parse::<i128>().map_err(|_| "Invalid context modulus".to_string())?),
        _ => None,
    };

    let struct_mode = match mode.to_lowercase().as_str() {
        "field" => evaluator::StructureMode::Field,
        "crt" => evaluator::StructureMode::Crt,
        _ => evaluator::StructureMode::Ring,
    };

    let result = evaluator::evaluate_mod_expr(&ast, modulus_i128, struct_mode).map_err(|e| e.to_string())?;

    Ok(ModularResult {
        value: result.value,
        details: result.details,
        modulus_used: result.modulus_used.map(|m| m.to_string()),
    })
}

/// Adds a history entry from Flutter for modular arithmetic.
#[frb(sync)]
pub fn modular_history_add(expression: String, result: String) {
    history::MOD_HISTORY.add(expression, result);
}

/// Retrieves all modular history entries to display in Flutter.
#[frb(sync)]
pub fn modular_history_get_all() -> Vec<history::HistoryEntry> {
    history::MOD_HISTORY.get_all()
}

/// Clears all modular history entries.
#[frb(sync)]
pub fn modular_history_clear() {
    history::MOD_HISTORY.clear();
}

/// Deletes a specific modular history entry.
#[frb(sync)]
pub fn modular_history_delete(index: usize) {
    history::MOD_HISTORY.delete(index);
}

/// Saves the modular history to a file path provided by Flutter.
pub fn modular_history_save(path: String) -> Result<(), String> {
    history::MOD_HISTORY.save(&path).map_err(|e| e.to_string())
}

/// Loads the modular history from a file path provided by Flutter.
pub fn modular_history_load(path: String) -> Result<(), String> {
    history::MOD_HISTORY.load(&path).map_err(|e| e.to_string())
}
