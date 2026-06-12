use crate::modular_math::{evaluator, parser};
use crate::shared::history;
use flutter_rust_bridge::frb;

/// Represents the result of a modular calculation
#[frb]
pub struct ModularResult {
    pub value: String,
    pub details: Option<String>,
    pub modulus_used: Option<String>,
    pub steps: Option<String>,
}

#[frb(sync)]
pub fn modular_evaluate(
    expression: String,
    context_modulus: Option<String>,
    mode: String,
    show_steps: bool,
) -> Result<ModularResult, String> {
    if expression.trim().is_empty() {
        return Ok(ModularResult {
            value: "0".to_string(),
            details: None,
            modulus_used: None,
            steps: None,
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

    let result = evaluator::evaluate_mod_expr(&ast, modulus_i128, struct_mode, show_steps).map_err(|e| e.to_string())?;

    Ok(ModularResult {
        value: result.value,
        details: result.details,
        modulus_used: result.modulus_used.map(|m| m.to_string()),
        steps: result.steps,
    })
}

#[frb]
pub struct StructureAnalysis {
    pub label: String,
    pub order: String,
    pub is_cyclic: bool,
    pub identity: String,
    pub elements: String,
    pub generators: Option<String>,
    pub units: Option<String>,
    pub zero_divisors: Option<String>,
    pub idempotents: Option<String>,
    pub nilpotents: Option<String>,
    pub inverses: Option<String>,
    pub element_orders: Option<String>,
    pub cayley_table: Option<String>,
    pub classification: String,
}

#[frb(sync)]
pub fn analyze_structure(
    structure_type: String,
    n: String,
) -> Result<StructureAnalysis, String> {
    let modulus = n.parse::<i128>().map_err(|_| "Invalid modulus".to_string())?;
    if modulus <= 1 {
        return Err("Modulus must be > 1".to_string());
    }

    match structure_type.to_lowercase().as_str() {
        "ring" => {
            let info = crate::modular_math::ring_analysis::ring_classify(modulus);
            let mut inverses_str = String::new();
            for &u in &info.units {
                if let Ok(inv) = crate::modular_math::mod_arith::mod_inv(u, modulus) {
                    inverses_str.push_str(&format!("{}⁻¹={}, ", u, inv));
                }
            }
            if !inverses_str.is_empty() {
                inverses_str.truncate(inverses_str.len() - 2);
            }

            let cayley = if modulus <= 25 {
                if let Ok(table) = crate::modular_math::cayley::addition_table(modulus) {
                    let mut s = String::new();
                    for row in table {
                        s.push_str(&row.iter().map(|n| format!("{:3}", n)).collect::<Vec<_>>().join(" "));
                        s.push('\n');
                    }
                    Some(s)
                } else { None }
            } else { None };

            Ok(StructureAnalysis {
                label: format!("Z_{}", modulus),
                order: format!("|Z_{}| = {}", modulus, modulus),
                is_cyclic: true, // Z_n is always cyclic under addition
                identity: "0".to_string(),
                elements: format!("{{0, 1, ..., {}}}", modulus - 1),
                generators: Some("1".to_string()),
                units: Some(format!("{{{}}}", info.units.iter().map(|x| x.to_string()).collect::<Vec<_>>().join(", "))),
                zero_divisors: Some(format!("{{{}}}", info.zero_divisors.iter().map(|x| x.to_string()).collect::<Vec<_>>().join(", "))),
                idempotents: Some(format!("{{{}}}", info.idempotents.iter().map(|x| x.to_string()).collect::<Vec<_>>().join(", "))),
                nilpotents: Some(format!("{{{}}}", info.nilpotents.iter().map(|x| x.to_string()).collect::<Vec<_>>().join(", "))),
                inverses: Some(inverses_str),
                element_orders: None, // Too verbose for additive group
                cayley_table: cayley,
                classification: info.classification,
            })
        }
        "group" => {
            let units = crate::modular_math::number_theory_ext::unit_group(modulus);
            let generators = crate::modular_math::number_theory_ext::primitive_roots(modulus).ok();
            
            let mut orders_str = String::new();
            if units.len() <= 50 {
                for &u in &units {
                    if let Ok(ord) = crate::modular_math::number_theory_ext::element_order(u, modulus) {
                        orders_str.push_str(&format!("ord({})={}, ", u, ord));
                    }
                }
                if !orders_str.is_empty() {
                    orders_str.truncate(orders_str.len() - 2);
                }
            }

            let mut inverses_str = String::new();
            if units.len() <= 50 {
                for &u in &units {
                    if let Ok(inv) = crate::modular_math::mod_arith::mod_inv(u, modulus) {
                        inverses_str.push_str(&format!("{}⁻¹={}, ", u, inv));
                    }
                }
                if !inverses_str.is_empty() {
                    inverses_str.truncate(inverses_str.len() - 2);
                }
            }

            let cayley = if units.len() <= 25 {
                if let Ok((_, table)) = crate::modular_math::cayley::unit_group_table(modulus) {
                    let mut s = String::new();
                    for row in table {
                        s.push_str(&row.iter().map(|n| format!("{:3}", n)).collect::<Vec<_>>().join(" "));
                        s.push('\n');
                    }
                    Some(s)
                } else { None }
            } else { None };

            Ok(StructureAnalysis {
                label: format!("Z_{}*", modulus),
                order: format!("|Z_{}*| = φ({}) = {}", modulus, modulus, units.len()),
                is_cyclic: generators.is_some(),
                identity: "1".to_string(),
                elements: format!("{{{}}}", units.iter().map(|x| x.to_string()).collect::<Vec<_>>().join(", ")),
                generators: generators.as_ref().map(|g| format!("{{{}}}", g.iter().map(|x| x.to_string()).collect::<Vec<_>>().join(", "))),
                units: None, // Itself
                zero_divisors: None, // None in a group
                idempotents: None,
                nilpotents: None,
                inverses: Some(inverses_str),
                element_orders: Some(orders_str),
                cayley_table: cayley,
                classification: if generators.is_some() { "Cyclic Group".to_string() } else { "Abelian Group".to_string() },
            })
        }
        "field" => {
            if !crate::modular_math::mod_arith::is_prime(modulus) {
                return Err(format!("GF(p) requires p to be prime. {} is not prime.", modulus));
            }
            let elements = format!("{{0, 1, ..., {}}}", modulus - 1);
            let generators = crate::modular_math::number_theory_ext::primitive_roots(modulus).ok();

            Ok(StructureAnalysis {
                label: format!("GF({})", modulus),
                order: format!("|GF({})| = {}", modulus, modulus),
                is_cyclic: true, // Multiplicative group is cyclic
                identity: "0 (Add), 1 (Mul)".to_string(),
                elements,
                generators: generators.as_ref().map(|g| format!("{{{}}} (Mul)", g.iter().map(|x| x.to_string()).collect::<Vec<_>>().join(", "))),
                units: Some(format!("{{1, ..., {}}}", modulus - 1)),
                zero_divisors: Some("{none}".to_string()),
                idempotents: Some("{0, 1}".to_string()),
                nilpotents: Some("{0}".to_string()),
                inverses: Some("All non-zero elements have inverses".to_string()),
                element_orders: None,
                cayley_table: None, // Fields get too large fast, skip for field summary
                classification: "Finite Field (Galois Field)".to_string(),
            })
        }
        _ => Err("Invalid structure type. Use 'ring', 'group', or 'field'.".to_string()),
    }
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
