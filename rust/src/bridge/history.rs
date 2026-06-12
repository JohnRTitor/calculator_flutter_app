#[flutter_rust_bridge::frb(sync)]
pub fn app_history_add(category: String, preview: String, snapshot: String) {
    crate::shared::history::APP_HISTORY.add(category, preview, snapshot);
}

#[flutter_rust_bridge::frb(sync)]
pub fn app_history_get_all() -> Vec<crate::shared::history::HistoryEntry> {
    crate::shared::history::APP_HISTORY.get_all()
}

#[flutter_rust_bridge::frb(sync)]
pub fn app_history_get_by_category(category: String) -> Vec<crate::shared::history::HistoryEntry> {
    crate::shared::history::APP_HISTORY.get_by_category(&category)
}

#[flutter_rust_bridge::frb(sync)]
pub fn app_history_clear_all() {
    crate::shared::history::APP_HISTORY.clear_all();
}

#[flutter_rust_bridge::frb(sync)]
pub fn app_history_clear_category(category: String) {
    crate::shared::history::APP_HISTORY.clear_category(&category);
}

#[flutter_rust_bridge::frb(sync)]
pub fn app_history_delete(id: String) {
    crate::shared::history::APP_HISTORY.delete(&id);
}

pub fn app_history_save(path: String) -> Result<(), String> {
    crate::shared::history::APP_HISTORY
        .save(&path)
        .map_err(|e| e.to_string())
}

pub fn app_history_load(path: String) -> Result<(), String> {
    crate::shared::history::APP_HISTORY
        .load(&path)
        .map_err(|e| e.to_string())
}
