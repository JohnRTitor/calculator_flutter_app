use crate::calculator::error::CalcError;
use serde::{Deserialize, Serialize};
use std::fs;
use std::sync::Mutex;

/// Represents a single calculation in the application history.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct HistoryEntry {
    pub expression: String,
    pub result: String,
}

static HISTORY: Mutex<Vec<HistoryEntry>> = Mutex::new(Vec::new());
static FUNC_HISTORY: Mutex<Vec<HistoryEntry>> = Mutex::new(Vec::new());

/// Adds a new calculation entry to the global history.
pub fn add(expression: String, result: String) {
    if let Ok(mut history) = HISTORY.lock() {
        history.push(HistoryEntry { expression, result });
    }
}

/// Retrieves all stored history entries.
pub fn get_all() -> Vec<HistoryEntry> {
    if let Ok(history) = HISTORY.lock() {
        history.clone()
    } else {
        Vec::new()
    }
}

/// Clears all stored history entries.
pub fn clear() {
    if let Ok(mut history) = HISTORY.lock() {
        history.clear();
    }
}

/// Deletes a specific history entry by its index.
pub fn delete(index: usize) {
    if let Ok(mut history) = HISTORY.lock()
        && index < history.len()
    {
        history.remove(index);
    }
}

/// Saves the global history to a JSON file at the specified path.
pub fn save(path: &str) -> Result<(), CalcError> {
    let history = get_all();
    let json = serde_json::to_string(&history)
        .map_err(|e| CalcError::IoError(format!("Serialization error: {}", e)))?;
    fs::write(path, json).map_err(|e| CalcError::IoError(format!("File write error: {}", e)))?;
    Ok(())
}

/// Loads the global history from a JSON file at the specified path.
pub fn load(path: &str) -> Result<(), CalcError> {
    if !std::path::Path::new(path).exists() {
        return Ok(()); // No history yet
    }
    let json = fs::read_to_string(path)
        .map_err(|e| CalcError::IoError(format!("File read error: {}", e)))?;
    let loaded_history: Vec<HistoryEntry> = serde_json::from_str(&json)
        .map_err(|e| CalcError::IoError(format!("Deserialization error: {}", e)))?;

    if let Ok(mut history) = HISTORY.lock() {
        *history = loaded_history;
    }
    Ok(())
}

/// Adds a new calculation entry to the func history.
pub fn func_history_add(expression: String, result: String) {
    if let Ok(mut history) = FUNC_HISTORY.lock() {
        history.push(HistoryEntry { expression, result });
    }
}

/// Retrieves all stored func history entries.
pub fn func_history_get_all() -> Vec<HistoryEntry> {
    if let Ok(history) = FUNC_HISTORY.lock() {
        history.clone()
    } else {
        Vec::new()
    }
}

/// Clears all stored func history entries.
pub fn func_history_clear() {
    if let Ok(mut history) = FUNC_HISTORY.lock() {
        history.clear();
    }
}

/// Deletes a specific func history entry by its index.
pub fn func_history_delete(index: usize) {
    if let Ok(mut history) = FUNC_HISTORY.lock()
        && index < history.len()
    {
        history.remove(index);
    }
}

/// Saves the func history to a JSON file at the specified path.
pub fn func_history_save(path: &str) -> Result<(), CalcError> {
    let history = func_history_get_all();
    let json = serde_json::to_string(&history)
        .map_err(|e| CalcError::IoError(format!("Serialization error: {}", e)))?;
    fs::write(path, json).map_err(|e| CalcError::IoError(format!("File write error: {}", e)))?;
    Ok(())
}

/// Loads the func history from a JSON file at the specified path.
pub fn func_history_load(path: &str) -> Result<(), CalcError> {
    if !std::path::Path::new(path).exists() {
        return Ok(()); // No history yet
    }
    let json = fs::read_to_string(path)
        .map_err(|e| CalcError::IoError(format!("File read error: {}", e)))?;
    let loaded_history: Vec<HistoryEntry> = serde_json::from_str(&json)
        .map_err(|e| CalcError::IoError(format!("Deserialization error: {}", e)))?;

    if let Ok(mut history) = FUNC_HISTORY.lock() {
        *history = loaded_history;
    }
    Ok(())
}
