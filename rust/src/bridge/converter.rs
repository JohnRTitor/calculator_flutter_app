use crate::converter::converter;
use flutter_rust_bridge::frb;

/// FFI representation of a physical unit of measurement.
#[frb]
#[derive(Debug, Clone)]
pub struct FfiUnit {
    pub id: String,
    pub name: String,
    pub symbol: String,
    pub multiplier: f64,
    pub offset: f64,
}

/// FFI representation of a category of units.
#[frb]
#[derive(Debug, Clone)]
pub struct FfiConverterCategory {
    pub id: String,
    pub name: String,
    pub icon_name: String,
    pub units: Vec<FfiUnit>,
    pub show_swap_units_toggler: bool,
    pub show_result_section: bool,
}

/// Retrieves all available converter categories for the Flutter UI.
#[frb(sync)]
pub fn get_converter_categories() -> Vec<FfiConverterCategory> {
    converter::get_all_categories()
        .into_iter()
        .map(|c| {
            FfiConverterCategory {
            id: c.id,
            name: c.name,
            icon_name: c.icon_name,
            units: c
                .units
                .into_iter()
                .map(|u| FfiUnit {
                    id: u.id,
                    name: u.name,
                    symbol: u.symbol,
                    multiplier: u.multiplier,
                    offset: u.offset,
                })
                .collect(),
            show_swap_units_toggler: true,
            show_result_section: true,
        }})
        .collect()
}

/// Converts a value between two standard units.
#[frb(sync)]
pub fn convert_standard(value: f64, from_unit: FfiUnit, to_unit: FfiUnit) -> f64 {
    let from = converter::Unit {
        id: from_unit.id,
        name: from_unit.name,
        symbol: from_unit.symbol,
        multiplier: from_unit.multiplier,
        offset: from_unit.offset,
    };
    let to = converter::Unit {
        id: to_unit.id,
        name: to_unit.name,
        symbol: to_unit.symbol,
        multiplier: to_unit.multiplier,
        offset: to_unit.offset,
    };
    converter::convert_standard(value, &from, &to)
}


/// Converts a string representing a numeral from one base to another.
#[frb(sync)]
pub fn convert_numeral(value: String, from_base: u32, to_base: u32) -> Option<String> {
    converter::convert_numeral(&value, from_base, to_base)
}
