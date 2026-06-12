use crate::modular_arithmetic::error::ModError;

/// Computes the greatest common divisor of `a` and `b`.
pub fn gcd(mut a: i128, mut b: i128) -> i128 {
    a = a.abs();
    b = b.abs();
    while b != 0 {
        let temp = b;
        b = a % b;
        a = temp;
    }
    a
}

/// Extended Euclidean Algorithm.
/// Returns (g, x, y) such that a*x + b*y = g = gcd(a, b).
pub fn extended_gcd(mut a: i128, mut b: i128) -> (i128, i128, i128) {
    let mut s = 0;
    let mut old_s = 1;
    let mut t = 1;
    let mut old_t = 0;

    let a_neg = a < 0;
    let b_neg = b < 0;
    a = a.abs();
    b = b.abs();

    while b != 0 {
        let quotient = a / b;
        let temp = b;
        b = a % b;
        a = temp;

        let temp = s;
        s = old_s - quotient * s;
        old_s = temp;

        let temp = t;
        t = old_t - quotient * t;
        old_t = temp;
    }

    if a_neg {
        old_s = -old_s;
    }
    if b_neg {
        old_t = -old_t;
    }

    (a, old_s, old_t)
}

/// Solves a system of congruences using the Chinese Remainder Theorem.
/// remainders is a slice of (remainder, modulus) tuples.
/// Returns Ok((solution, combined_modulus)) or Err if inconsistent.
pub fn crt(remainders: &[(i128, i128)]) -> Result<(i128, i128), ModError> {
    if remainders.is_empty() {
        return Err(ModError::InconsistentCRT("Empty system".to_string()));
    }

    let mut current_remainder = remainders[0].0;
    let mut current_modulus = remainders[0].1;

    // Normalize first equation
    current_remainder =
        crate::modular_arithmetic::mod_arith::mod_reduce(current_remainder, current_modulus);

    for &(mut rem, modl) in &remainders[1..] {
        if modl <= 0 {
            return Err(ModError::InvalidModulus(
                "Modulus must be positive".to_string(),
            ));
        }

        rem = crate::modular_arithmetic::mod_arith::mod_reduce(rem, modl);

        let (g, m1, _m2) = extended_gcd(current_modulus, modl);

        if (rem - current_remainder) % g != 0 {
            return Err(ModError::InconsistentCRT(
                "System has no solution".to_string(),
            ));
        }

        // current_modulus / g and modl / g are coprime
        let lcm = (current_modulus / g) * modl;

        let diff = (rem - current_remainder) / g;

        // Calculate diff * m1 * (current_modulus) + current_remainder
        let step = crate::modular_arithmetic::mod_arith::mod_mul(
            crate::modular_arithmetic::mod_arith::mod_mul(diff, m1, lcm),
            current_modulus,
            lcm,
        );

        current_remainder =
            crate::modular_arithmetic::mod_arith::mod_add(current_remainder, step, lcm);
        current_modulus = lcm;
    }

    Ok((current_remainder, current_modulus))
}
