use std::sync::Mutex;

static MEMORY: Mutex<Option<f64>> = Mutex::new(None);

/// Stores a value in the global calculator memory.
pub fn store(value: f64) {
    if let Ok(mut mem) = MEMORY.lock() {
        *mem = Some(value);
    }
}

/// Recalls the currently stored value from the global calculator memory.
/// Returns `None` if memory is empty.
pub fn recall() -> Option<f64> {
    if let Ok(mem) = MEMORY.lock() {
        *mem
    } else {
        None
    }
}

/// Adds a value to the currently stored memory value.
pub fn add(value: f64) {
    if let Ok(mut mem) = MEMORY.lock() {
        if let Some(current) = *mem {
            *mem = Some(current + value);
        } else {
            *mem = Some(value);
        }
    }
}

/// Subtracts a value from the currently stored memory value.
pub fn subtract(value: f64) {
    if let Ok(mut mem) = MEMORY.lock() {
        if let Some(current) = *mem {
            *mem = Some(current - value);
        } else {
            *mem = Some(-value);
        }
    }
}

/// Clears the global calculator memory.
pub fn clear() {
    if let Ok(mut mem) = MEMORY.lock() {
        *mem = None;
    }
}
