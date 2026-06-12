use crate::modular_arithmetic::{evaluator, parser};
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
        Some(ref s) if !s.trim().is_empty() => Some(
            s.parse::<i128>()
                .map_err(|_| "Invalid context modulus".to_string())?,
        ),
        _ => None,
    };

    let struct_mode = match mode.to_lowercase().as_str() {
        "field" => evaluator::StructureMode::Field,
        "crt" => evaluator::StructureMode::Crt,
        _ => evaluator::StructureMode::Ring,
    };

    let result = evaluator::evaluate_mod_expr(&ast, modulus_i128, struct_mode, show_steps)
        .map_err(|e| e.to_string())?;

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

#[frb]
pub struct StructureAnalysisResponse {
    pub success: bool,
    pub analysis: Option<StructureAnalysis>,
    pub error_message: Option<String>,
    pub suggestion: Option<String>,
    pub interpreted_as: Option<String>,
}

#[frb(sync)]
pub fn analyze_structure(
    structure_type: String,
    n: String,
) -> Result<StructureAnalysisResponse, String> {
    // 1. Parse Notation
    let parsed = match crate::modular_arithmetic::structure_parser::parse_structure_input(
        &n,
        &structure_type,
    ) {
        Ok(p) => p,
        Err(e) => {
            return Ok(StructureAnalysisResponse {
                success: false,
                analysis: None,
                error_message: Some(e),
                suggestion: None,
                interpreted_as: None,
            });
        }
    };

    // If there is a suggestion, we return it without running the analysis
    // (the user must accept the suggestion or fix the input)
    if let Some(suggestion) = parsed.suggestion {
        return Ok(StructureAnalysisResponse {
            success: false,
            analysis: None,
            error_message: None,
            suggestion: Some(suggestion),
            interpreted_as: None,
        });
    }

    let modulus = parsed.modulus;

    // 2. Math Validation
    if modulus <= 1 {
        return Ok(StructureAnalysisResponse {
            success: false,
            analysis: None,
            error_message: Some("Modulus must be > 1".to_string()),
            suggestion: None,
            interpreted_as: None,
        });
    }

    // 3. Analyze
    let analysis = match structure_type.to_lowercase().as_str() {
        "ring" => {
            let info = crate::modular_arithmetic::ring_analysis::ring_classify(modulus);
            let mut inverses_str = String::new();
            for &u in &info.units {
                if let Ok(inv) = crate::modular_arithmetic::mod_arith::mod_inv(u, modulus) {
                    inverses_str.push_str(&format!("{}⁻¹={}, ", u, inv));
                }
            }
            if !inverses_str.is_empty() {
                inverses_str.truncate(inverses_str.len() - 2);
            }

            let cayley = if modulus <= 25 {
                if let Ok(table) = crate::modular_arithmetic::cayley::addition_table(modulus) {
                    let mut s = String::new();
                    for row in table {
                        s.push_str(
                            &row.iter()
                                .map(|num| format!("{:3}", num))
                                .collect::<Vec<_>>()
                                .join(" "),
                        );
                        s.push('\n');
                    }
                    Some(s)
                } else {
                    None
                }
            } else {
                None
            };

            StructureAnalysis {
                label: parsed.canonical_notation.clone(),
                order: format!("|{}| = {}", parsed.canonical_notation, modulus),
                is_cyclic: true, // Z_n is always cyclic under addition
                identity: "0".to_string(),
                elements: format!("{{0, 1, ..., {}}}", modulus - 1),
                generators: Some("1".to_string()),
                units: Some(format!(
                    "{{{}}}",
                    info.units
                        .iter()
                        .map(|x| x.to_string())
                        .collect::<Vec<_>>()
                        .join(", ")
                )),
                zero_divisors: Some(format!(
                    "{{{}}}",
                    info.zero_divisors
                        .iter()
                        .map(|x| x.to_string())
                        .collect::<Vec<_>>()
                        .join(", ")
                )),
                idempotents: Some(format!(
                    "{{{}}}",
                    info.idempotents
                        .iter()
                        .map(|x| x.to_string())
                        .collect::<Vec<_>>()
                        .join(", ")
                )),
                nilpotents: Some(format!(
                    "{{{}}}",
                    info.nilpotents
                        .iter()
                        .map(|x| x.to_string())
                        .collect::<Vec<_>>()
                        .join(", ")
                )),
                inverses: Some(inverses_str),
                element_orders: None, // Too verbose for additive group
                cayley_table: cayley,
                classification: info.classification,
            }
        }
        "group" => {
            let units = crate::modular_arithmetic::number_theory_ext::unit_group(modulus);
            let generators =
                crate::modular_arithmetic::number_theory_ext::primitive_roots(modulus).ok();

            let mut orders_str = String::new();
            if units.len() <= 50 {
                for &u in &units {
                    if let Ok(ord) =
                        crate::modular_arithmetic::number_theory_ext::element_order(u, modulus)
                    {
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
                    if let Ok(inv) = crate::modular_arithmetic::mod_arith::mod_inv(u, modulus) {
                        inverses_str.push_str(&format!("{}⁻¹={}, ", u, inv));
                    }
                }
                if !inverses_str.is_empty() {
                    inverses_str.truncate(inverses_str.len() - 2);
                }
            }

            let cayley = if units.len() <= 25 {
                if let Ok((_, table)) = crate::modular_arithmetic::cayley::unit_group_table(modulus)
                {
                    let mut s = String::new();
                    for row in table {
                        s.push_str(
                            &row.iter()
                                .map(|num| format!("{:3}", num))
                                .collect::<Vec<_>>()
                                .join(" "),
                        );
                        s.push('\n');
                    }
                    Some(s)
                } else {
                    None
                }
            } else {
                None
            };

            StructureAnalysis {
                label: parsed.canonical_notation.clone(),
                order: format!(
                    "|{}| = φ({}) = {}",
                    parsed.canonical_notation,
                    modulus,
                    units.len()
                ),
                is_cyclic: generators.is_some(),
                identity: "1".to_string(),
                elements: format!(
                    "{{{}}}",
                    units
                        .iter()
                        .map(|x| x.to_string())
                        .collect::<Vec<_>>()
                        .join(", ")
                ),
                generators: generators.as_ref().map(|g| {
                    format!(
                        "{{{}}}",
                        g.iter()
                            .map(|x| x.to_string())
                            .collect::<Vec<_>>()
                            .join(", ")
                    )
                }),
                units: None,         // Itself
                zero_divisors: None, // None in a group
                idempotents: None,
                nilpotents: None,
                inverses: Some(inverses_str),
                element_orders: Some(orders_str),
                cayley_table: cayley,
                classification: if generators.is_some() {
                    "Cyclic Group".to_string()
                } else {
                    "Abelian Group".to_string()
                },
            }
        }
        "field" => {
            // Check for math errors
            if !crate::modular_arithmetic::mod_arith::is_prime(modulus) {
                // Determine if it was parsed as an extension field originally
                let is_extension = parsed.canonical_notation.contains('^');
                let error_msg = if is_extension {
                    format!(
                        "{} requires a prime modulus in this version (extension fields not yet supported).",
                        parsed.canonical_notation
                    )
                } else {
                    format!(
                        "{} is not a field because {} is not prime.",
                        parsed.canonical_notation, modulus
                    )
                };

                return Ok(StructureAnalysisResponse {
                    success: false,
                    analysis: None,
                    error_message: Some(error_msg),
                    suggestion: None,
                    interpreted_as: None,
                });
            }

            let elements = format!("{{0, 1, ..., {}}}", modulus - 1);
            let generators =
                crate::modular_arithmetic::number_theory_ext::primitive_roots(modulus).ok();

            StructureAnalysis {
                label: parsed.canonical_notation.clone(),
                order: format!("|{}| = {}", parsed.canonical_notation, modulus),
                is_cyclic: true, // Multiplicative group is cyclic
                identity: "0 (Add), 1 (Mul)".to_string(),
                elements,
                generators: generators.as_ref().map(|g| {
                    format!(
                        "{{{}}} (Mul)",
                        g.iter()
                            .map(|x| x.to_string())
                            .collect::<Vec<_>>()
                            .join(", ")
                    )
                }),
                units: Some(format!("{{1, ..., {}}}", modulus - 1)),
                zero_divisors: Some("{none}".to_string()),
                idempotents: Some("{0, 1}".to_string()),
                nilpotents: Some("{0}".to_string()),
                inverses: Some("All non-zero elements have inverses".to_string()),
                element_orders: None,
                cayley_table: None, // Fields get too large fast, skip for field summary
                classification: "Finite Field (Galois Field)".to_string(),
            }
        }
        _ => {
            return Ok(StructureAnalysisResponse {
                success: false,
                analysis: None,
                error_message: Some(
                    "Invalid structure type. Use 'ring', 'group', or 'field'.".to_string(),
                ),
                suggestion: None,
                interpreted_as: None,
            });
        }
    };

    Ok(StructureAnalysisResponse {
        success: true,
        analysis: Some(analysis),
        error_message: None,
        suggestion: None,
        interpreted_as: parsed.interpreted_as,
    })
}

crate::history_bridge!(
    modular_history_add,
    modular_history_get_all,
    modular_history_clear,
    modular_history_delete,
    modular_history_save,
    modular_history_load,
    history::MOD_HISTORY
);
