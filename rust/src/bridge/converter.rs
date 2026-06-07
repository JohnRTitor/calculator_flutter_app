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
}

/// Retrieves all available converter categories for the Flutter UI.
#[frb(sync)]
pub fn get_converter_categories() -> Vec<FfiConverterCategory> {
    converter::get_all_categories()
        .into_iter()
        .map(|c| FfiConverterCategory {
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
        })
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

/// FFI representation of a discount calculation result.
#[frb]
pub struct DiscountResult {
    pub amount_saved: f64,
    pub final_price: f64,
}

/// Calculates the discount and final price from an original price and percentage.
#[frb(sync)]
pub fn calculate_discount(original_price: f64, discount_percentage: f64) -> DiscountResult {
    let (_, final_price, amount_saved) =
        converter::calculate_discount(original_price, discount_percentage);
    DiscountResult {
        amount_saved,
        final_price,
    }
}

/// FFI representation of a Goods and Services Tax (GST) calculation result.
#[frb]
pub struct GstResult {
    pub gst_amount: f64,
    pub total_amount: f64,
    pub original_amount: f64,
}

/// Calculates the GST amount and total amount for a given base amount and rate.
#[frb(sync)]
pub fn calculate_gst(amount: f64, gst_percentage: f64, add_gst: bool) -> GstResult {
    let (gst_amount, total_amount, original_amount, _) =
        converter::calculate_gst(amount, gst_percentage, add_gst);
    GstResult {
        gst_amount,
        total_amount,
        original_amount,
    }
}

/// FFI representation of a Body Mass Index (BMI) calculation result.
#[frb]
pub struct BmiResult {
    pub bmi: f64,
    pub category: String,
}

/// Calculates BMI based on weight (kg) and height (m).
#[frb(sync)]
pub fn calculate_bmi(weight_kg: f64, height_m: f64) -> BmiResult {
    let (bmi, category) = converter::calculate_bmi(weight_kg, height_m);
    BmiResult { bmi, category }
}

/// Converts a string representing a numeral from one base to another.
#[frb(sync)]
pub fn convert_numeral(value: String, from_base: u32, to_base: u32) -> Option<String> {
    converter::convert_numeral(&value, from_base, to_base)
}
