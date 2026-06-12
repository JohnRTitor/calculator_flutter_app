use crate::calculator::error::CalcError;
use flutter_rust_bridge::frb;
use serde::{Deserialize, Serialize};
use std::fs;
use std::sync::Mutex;

/// Represents a single calculation in the application history.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct HistoryEntry {
    pub expression: String,
    pub result: String,
}

#[macro_export]
macro_rules! history_bridge {
    ($add:ident, $get_all:ident, $clear:ident, $delete:ident, $save:ident, $load:ident, $history:expr) => {
        #[flutter_rust_bridge::frb(sync)]
        pub fn $add(expression: String, result: String) {
            $history.add(expression, result);
        }
        #[flutter_rust_bridge::frb(sync)]
        pub fn $get_all() -> Vec<crate::shared::history::HistoryEntry> {
            $history.get_all()
        }
        #[flutter_rust_bridge::frb(sync)]
        pub fn $clear() {
            $history.clear();
        }
        #[flutter_rust_bridge::frb(sync)]
        pub fn $delete(index: usize) {
            $history.delete(index);
        }
        pub fn $save(path: String) -> Result<(), String> {
            $history.save(&path).map_err(|e| e.to_string())
        }
        pub fn $load(path: String) -> Result<(), String> {
            $history.load(&path).map_err(|e| e.to_string())
        }
    };
}

pub struct HistoryManager {
    history: Mutex<Vec<HistoryEntry>>,
}

impl HistoryManager {
    pub const fn new() -> Self {
        Self {
            history: Mutex::new(Vec::new()),
        }
    }

    pub fn add(&self, expression: String, result: String) {
        if let Ok(mut history) = self.history.lock() {
            history.push(HistoryEntry { expression, result });
        }
    }

    pub fn get_all(&self) -> Vec<HistoryEntry> {
        if let Ok(history) = self.history.lock() {
            history.clone()
        } else {
            Vec::new()
        }
    }

    pub fn clear(&self) {
        if let Ok(mut history) = self.history.lock() {
            history.clear();
        }
    }

    pub fn delete(&self, index: usize) {
        if let Ok(mut history) = self.history.lock() {
            if index < history.len() {
                history.remove(index);
            }
        }
    }

    pub fn save(&self, path: &str) -> Result<(), CalcError> {
        let history = self.get_all();
        let json = serde_json::to_string(&history)
            .map_err(|e| CalcError::IoError(format!("Serialization error: {}", e)))?;
        fs::write(path, json)
            .map_err(|e| CalcError::IoError(format!("File write error: {}", e)))?;
        Ok(())
    }

    pub fn load(&self, path: &str) -> Result<(), CalcError> {
        if !std::path::Path::new(path).exists() {
            return Ok(());
        }
        let json = fs::read_to_string(path)
            .map_err(|e| CalcError::IoError(format!("File read error: {}", e)))?;
        let loaded_history: Vec<HistoryEntry> = serde_json::from_str(&json)
            .map_err(|e| CalcError::IoError(format!("Deserialization error: {}", e)))?;

        if let Ok(mut history) = self.history.lock() {
            *history = loaded_history;
        }
        Ok(())
    }
}

// Global instances for different calculators
pub static BASIC_HISTORY: HistoryManager = HistoryManager::new();
pub static FUNC_HISTORY: HistoryManager = HistoryManager::new();
pub static MOD_HISTORY: HistoryManager = HistoryManager::new();
