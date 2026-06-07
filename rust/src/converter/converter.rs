/// Represents a physical unit of measurement.
#[derive(Debug, Clone)]
pub struct Unit {
    pub id: String,
    pub name: String,
    pub symbol: String,
    pub multiplier: f64, // Multiplier to a base unit
    pub offset: f64,     // Offset to a base unit (e.g., for temperature)
}

impl Unit {
    /// Creates a new `Unit` instance.
    pub fn new(id: &str, name: &str, symbol: &str, multiplier: f64, offset: f64) -> Self {
        Self {
            id: id.to_string(),
            name: name.to_string(),
            symbol: symbol.to_string(),
            multiplier,
            offset,
        }
    }
}

/// Represents a category of units (e.g., Length, Mass, Volume).
#[derive(Debug, Clone)]
pub struct ConverterCategory {
    pub id: String,
    pub name: String,
    pub icon_name: String,
    pub units: Vec<Unit>,
}

/// Retrieves all available converter categories and their respective units.
pub fn get_all_categories() -> Vec<ConverterCategory> {
    vec![
        get_length_category(),
        get_area_category(),
        get_mass_category(),
        get_volume_category(),
        get_temperature_category(),
        get_speed_category(),
        get_time_category(),
        get_data_category(),
        get_numeral_category(),
    ]
}

fn get_length_category() -> ConverterCategory {
    ConverterCategory {
        id: "length".to_string(),
        name: "Length".to_string(),
        icon_name: "straighten".to_string(),
        units: vec![
            Unit::new("mm", "Millimeter", "mm", 0.001, 0.0),
            Unit::new("cm", "Centimeter", "cm", 0.01, 0.0),
            Unit::new("m", "Meter", "m", 1.0, 0.0), // Base
            Unit::new("km", "Kilometer", "km", 1000.0, 0.0),
            Unit::new("in", "Inch", "in", 0.0254, 0.0),
            Unit::new("ft", "Foot", "ft", 0.3048, 0.0),
            Unit::new("yd", "Yard", "yd", 0.9144, 0.0),
            Unit::new("mi", "Mile", "mi", 1609.344, 0.0),
            Unit::new("nmi", "Nautical Mile", "nmi", 1852.0, 0.0),
        ],
    }
}

fn get_area_category() -> ConverterCategory {
    ConverterCategory {
        id: "area".to_string(),
        name: "Area".to_string(),
        icon_name: "texture".to_string(),
        units: vec![
            Unit::new("sq_m", "Square Meter", "m²", 1.0, 0.0), // Base
            Unit::new("sq_km", "Square Kilometer", "km²", 1_000_000.0, 0.0),
            Unit::new("ha", "Hectare", "ha", 10_000.0, 0.0),
            Unit::new("ac", "Acre", "ac", 4046.8564224, 0.0),
            Unit::new("sq_ft", "Square Foot", "ft²", 0.09290304, 0.0),
            Unit::new("sq_yd", "Square Yard", "yd²", 0.83612736, 0.0),
            Unit::new("sq_mi", "Square Mile", "mi²", 2_589_988.110336, 0.0),
        ],
    }
}

fn get_mass_category() -> ConverterCategory {
    ConverterCategory {
        id: "mass".to_string(),
        name: "Mass".to_string(),
        icon_name: "scale".to_string(),
        units: vec![
            Unit::new("mg", "Milligram", "mg", 0.001, 0.0),
            Unit::new("g", "Gram", "g", 1.0, 0.0), // Base
            Unit::new("kg", "Kilogram", "kg", 1000.0, 0.0),
            Unit::new("t", "Metric Ton", "t", 1_000_000.0, 0.0),
            Unit::new("oz", "Ounce", "oz", 28.349523125, 0.0),
            Unit::new("lb", "Pound", "lb", 453.59237, 0.0),
            Unit::new("st", "Stone", "st", 6350.29318, 0.0),
        ],
    }
}

fn get_volume_category() -> ConverterCategory {
    ConverterCategory {
        id: "volume".to_string(),
        name: "Volume".to_string(),
        icon_name: "water_drop".to_string(),
        units: vec![
            Unit::new("ml", "Milliliter", "mL", 0.001, 0.0),
            Unit::new("l", "Liter", "L", 1.0, 0.0), // Base
            Unit::new("cu_m", "Cubic Meter", "m³", 1000.0, 0.0),
            Unit::new("cu_cm", "Cubic Centimeter", "cm³", 0.001, 0.0),
            Unit::new("gal_us", "Gallon (US)", "gal", 3.785411784, 0.0),
            Unit::new("qt_us", "Quart (US)", "qt", 0.946352946, 0.0),
            Unit::new("pt_us", "Pint (US)", "pt", 0.473176473, 0.0),
            Unit::new(
                "fl_oz_us",
                "Fluid Ounce (US)",
                "fl oz",
                0.0295735295625,
                0.0,
            ),
        ],
    }
}

fn get_temperature_category() -> ConverterCategory {
    ConverterCategory {
        id: "temperature".to_string(),
        name: "Temperature".to_string(),
        icon_name: "thermostat".to_string(),
        units: vec![
            Unit::new("c", "Celsius", "°C", 1.0, 0.0), // Base
            Unit::new("f", "Fahrenheit", "°F", 5.0 / 9.0, -32.0),
            Unit::new("k", "Kelvin", "K", 1.0, -273.15),
        ],
    }
}

fn get_speed_category() -> ConverterCategory {
    ConverterCategory {
        id: "speed".to_string(),
        name: "Speed".to_string(),
        icon_name: "speed".to_string(),
        units: vec![
            Unit::new("mps", "Meters per second", "m/s", 1.0, 0.0), // Base
            Unit::new("kmph", "Kilometers per hour", "km/h", 0.27777777777778, 0.0),
            Unit::new("mph", "Miles per hour", "mph", 0.44704, 0.0),
            Unit::new("knot", "Knot", "kn", 0.51444444444444, 0.0),
            Unit::new("fps", "Feet per second", "ft/s", 0.3048, 0.0),
        ],
    }
}

fn get_time_category() -> ConverterCategory {
    ConverterCategory {
        id: "time".to_string(),
        name: "Time".to_string(),
        icon_name: "schedule".to_string(),
        units: vec![
            Unit::new("ms", "Millisecond", "ms", 0.001, 0.0),
            Unit::new("s", "Second", "s", 1.0, 0.0), // Base
            Unit::new("min", "Minute", "min", 60.0, 0.0),
            Unit::new("h", "Hour", "h", 3600.0, 0.0),
            Unit::new("d", "Day", "d", 86400.0, 0.0),
            Unit::new("wk", "Week", "wk", 604800.0, 0.0),
            Unit::new("mo", "Month", "mo", 2629800.0, 0.0), // average month (30.4375 days)
            Unit::new("yr", "Year", "yr", 31557600.0, 0.0), // average year (365.25 days)
        ],
    }
}

fn get_data_category() -> ConverterCategory {
    ConverterCategory {
        id: "data".to_string(),
        name: "Data".to_string(),
        icon_name: "storage".to_string(),
        units: vec![
            Unit::new("bit", "Bit", "bit", 0.125, 0.0),
            Unit::new("byte", "Byte", "B", 1.0, 0.0), // Base
            Unit::new("kb", "Kilobyte (Decimal)", "KB", 1000.0, 0.0),
            Unit::new("mb", "Megabyte (Decimal)", "MB", 1_000_000.0, 0.0),
            Unit::new("gb", "Gigabyte (Decimal)", "GB", 1_000_000_000.0, 0.0),
            Unit::new("tb", "Terabyte (Decimal)", "TB", 1_000_000_000_000.0, 0.0),
            Unit::new(
                "pb",
                "Petabyte (Decimal)",
                "PB",
                1_000_000_000_000_000.0,
                0.0,
            ),
            Unit::new("kib", "Kibibyte (Binary)", "KiB", 1024.0, 0.0),
            Unit::new("mib", "Mebibyte (Binary)", "MiB", 1_048_576.0, 0.0),
            Unit::new("gib", "Gibibyte (Binary)", "GiB", 1_073_741_824.0, 0.0),
            Unit::new("tib", "Tebibyte (Binary)", "TiB", 1_099_511_627_776.0, 0.0),
            Unit::new(
                "pib",
                "Pebibyte (Binary)",
                "PiB",
                1_125_899_906_842_624.0,
                0.0,
            ),
        ],
    }
}

fn get_numeral_category() -> ConverterCategory {
    ConverterCategory {
        id: "numeral".to_string(),
        name: "Numeral System".to_string(),
        icon_name: "pin".to_string(),
        units: vec![
            Unit::new("dec", "Decimal", "DEC", 1.0, 0.0),
            Unit::new("bin", "Binary", "BIN", 1.0, 0.0),
            Unit::new("oct", "Octal", "OCT", 1.0, 0.0),
            Unit::new("hex", "Hexadecimal", "HEX", 1.0, 0.0),
        ],
    }
}

/// Converts a value from one standard unit to another within the same category.
pub fn convert_standard(value: f64, from_unit: &Unit, to_unit: &Unit) -> f64 {
    // 1. Convert from_unit to base_unit
    let base_value = (value + from_unit.offset) * from_unit.multiplier;
    // 2. Convert base_unit to to_unit
    (base_value / to_unit.multiplier) - to_unit.offset
}



/// Converts a numeral string from one base (radix) to another.
/// Returns `None` if the input string is invalid for the given `from_base`.
pub fn convert_numeral(value: &str, from_base: u32, to_base: u32) -> Option<String> {
    // Attempt to parse the value using the from_base
    let decimal_val = match u128::from_str_radix(value, from_base) {
        Ok(v) => v,
        Err(_) => return None,
    };

    // Format the value into the to_base
    match to_base {
        2 => Some(format!("{:b}", decimal_val)),
        8 => Some(format!("{:o}", decimal_val)),
        10 => Some(format!("{}", decimal_val)),
        16 => Some(format!("{:x}", decimal_val).to_uppercase()),
        _ => None,
    }
}
