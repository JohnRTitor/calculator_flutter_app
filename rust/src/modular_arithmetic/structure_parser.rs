pub struct ParseResult {
    pub modulus: i128,
    pub canonical_notation: String,
    pub interpreted_as: Option<String>,
    pub suggestion: Option<String>,
}

pub fn parse_structure_input(input: &str, expected_type: &str) -> Result<ParseResult, String> {
    let clean = input.replace(" ", "").to_lowercase();

    // Check for extension field syntax like GF(2^8)
    if expected_type == "field" && clean.contains('^') {
        let parts: Vec<&str> = clean.split('^').collect();
        if parts.len() == 2 {
            let base_str = parts[0]
                .chars()
                .filter(|c| c.is_ascii_digit())
                .collect::<String>();
            let exp_str = parts[1]
                .chars()
                .filter(|c| c.is_ascii_digit())
                .collect::<String>();

            if let (Ok(b), Ok(e)) = (base_str.parse::<u32>(), exp_str.parse::<u32>()) {
                let p = b as i128;
                let modulus = p.pow(e);
                let canonical = format!("GF({}^{})", b, e);

                // Even though extension fields aren't fully supported by analyze_structure,
                // we parse them and return the canonical name.
                // The math validator will handle the error later.
                return Ok(ParseResult {
                    modulus,
                    canonical_notation: canonical,
                    interpreted_as: None,
                    suggestion: None,
                });
            }
        }
    }

    // Extract all digits
    let digits: String = clean.chars().filter(|c| c.is_ascii_digit()).collect();
    if digits.is_empty() {
        return Err("No numeric modulus found in input.".to_string());
    }

    let modulus = digits
        .parse::<i128>()
        .map_err(|_| "Modulus is too large.".to_string())?;

    // Determine implied type based on syntax
    let is_group_syntax = clean.contains('*')
        || clean.contains('u')
        || clean.contains("^*")
        || clean.contains(" units");
    let is_field_syntax = clean.contains('f') || clean.contains("gf");
    let is_ring_syntax = clean.contains('z') && !is_group_syntax;
    let is_raw_number = clean == digits;

    let mut actual_type = expected_type;
    if is_group_syntax {
        actual_type = "group";
    } else if is_field_syntax {
        actual_type = "field";
    } else if is_ring_syntax {
        actual_type = "ring";
    }

    // Construct canonical
    let canonical = match actual_type {
        "group" => format!("U({})", modulus),
        "field" => format!("GF({})", modulus),
        _ => format!("Z_{}", modulus), // ring is default
    };

    let mut interpreted_as = None;
    let mut suggestion = None;

    if is_raw_number {
        interpreted_as = Some(format!("Interpreted as {}", canonical));
    } else if !is_canonical(&clean, actual_type, modulus) {
        // Input is non-canonical, but parseable
        suggestion = Some(format!("Did you mean {}?", canonical));
    }

    // Check if expected_type differs from actual_type (but they didn't just type a number)
    if expected_type != actual_type && !is_raw_number {
        suggestion = Some(format!("Did you mean {}?", canonical));
    }

    Ok(ParseResult {
        modulus,
        canonical_notation: canonical,
        interpreted_as,
        suggestion,
    })
}

fn is_canonical(clean: &str, structure_type: &str, modulus: i128) -> bool {
    let s = clean.replace(" ", "");
    match structure_type {
        "group" => s == format!("u({})", modulus) || s == format!("z_{}*", modulus),
        "field" => s == format!("gf({})", modulus),
        "ring" => s == format!("z_{}", modulus),
        _ => false,
    }
}
