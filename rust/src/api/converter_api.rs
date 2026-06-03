use flutter_rust_bridge::frb;
use crate::converter;

#[frb]
#[derive(Debug, Clone)]
pub struct FfiUnit {
    pub id: String,
    pub name: String,
    pub symbol: String,
    pub multiplier: f64,
    pub offset: f64,
}

#[frb]
#[derive(Debug, Clone)]
pub struct FfiConverterCategory {
    pub id: String,
    pub name: String,
    pub icon_name: String,
    pub units: Vec<FfiUnit>,
}

#[frb(sync)]
pub fn get_converter_categories() -> Vec<FfiConverterCategory> {
    converter::get_all_categories()
        .into_iter()
        .map(|c| FfiConverterCategory {
            id: c.id,
            name: c.name,
            icon_name: c.icon_name,
            units: c.units
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

#[frb]
pub struct DiscountResult {
    pub amount_saved: f64,
    pub final_price: f64,
}

#[frb(sync)]
pub fn calculate_discount(original_price: f64, discount_percentage: f64) -> DiscountResult {
    let (_, final_price, amount_saved) = converter::calculate_discount(original_price, discount_percentage);
    DiscountResult {
        amount_saved,
        final_price,
    }
}

#[frb]
pub struct GstResult {
    pub gst_amount: f64,
    pub total_amount: f64,
    pub original_amount: f64,
}

#[frb(sync)]
pub fn calculate_gst(amount: f64, gst_percentage: f64, add_gst: bool) -> GstResult {
    let (gst_amount, total_amount, original_amount, _) = converter::calculate_gst(amount, gst_percentage, add_gst);
    GstResult {
        gst_amount,
        total_amount,
        original_amount,
    }
}

#[frb]
pub struct BmiResult {
    pub bmi: f64,
    pub category: String,
}

#[frb(sync)]
pub fn calculate_bmi(weight_kg: f64, height_m: f64) -> BmiResult {
    let (bmi, category) = converter::calculate_bmi(weight_kg, height_m);
    BmiResult { bmi, category }
}

#[frb(sync)]
pub fn convert_numeral(value: String, from_base: u32, to_base: u32) -> Option<String> {
    converter::convert_numeral(&value, from_base, to_base)
}
