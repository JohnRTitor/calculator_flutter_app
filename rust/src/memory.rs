use std::sync::Mutex;

static MEMORY: Mutex<Option<f64>> = Mutex::new(None);

pub fn store(value: f64) {
    if let Ok(mut mem) = MEMORY.lock() {
        *mem = Some(value);
    }
}

pub fn recall() -> Option<f64> {
    if let Ok(mem) = MEMORY.lock() {
        *mem
    } else {
        None
    }
}

pub fn add(value: f64) {
    if let Ok(mut mem) = MEMORY.lock() {
        if let Some(current) = *mem {
            *mem = Some(current + value);
        } else {
            *mem = Some(value);
        }
    }
}

pub fn subtract(value: f64) {
    if let Ok(mut mem) = MEMORY.lock() {
        if let Some(current) = *mem {
            *mem = Some(current - value);
        } else {
            *mem = Some(-value);
        }
    }
}

pub fn clear() {
    if let Ok(mut mem) = MEMORY.lock() {
        *mem = None;
    }
}
