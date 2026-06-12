use crate::modular_math::error::ModError;

/// Reduces `a` modulo `n`, ensuring the result is in the range `[0, n)`.
pub fn mod_reduce(a: i128, n: i128) -> i128 {
    if n == 0 {
        return a;
    }
    let r = a % n;
    if r < 0 {
        if n > 0 {
            r + n
        } else {
            r - n
        }
    } else {
        r
    }
}

/// Adds `a` and `b` modulo `n`.
pub fn mod_add(a: i128, b: i128, n: i128) -> i128 {
    mod_reduce(mod_reduce(a, n) + mod_reduce(b, n), n)
}

/// Subtracts `b` from `a` modulo `n`.
pub fn mod_sub(a: i128, b: i128, n: i128) -> i128 {
    mod_reduce(mod_reduce(a, n) - mod_reduce(b, n), n)
}

/// Multiplies `a` and `b` modulo `n`.
pub fn mod_mul(a: i128, b: i128, n: i128) -> i128 {
    mod_reduce(mod_reduce(a, n) * mod_reduce(b, n), n)
}

/// Negates `a` modulo `n`.
pub fn mod_neg(a: i128, n: i128) -> i128 {
    mod_reduce(-a, n)
}

/// Computes `base` raised to the power `exp` modulo `modulus`.
pub fn mod_pow(mut base: i128, mut exp: i128, modulus: i128) -> Result<i128, ModError> {
    if modulus <= 0 {
        return Err(ModError::InvalidModulus("Modulus must be positive".to_string()));
    }
    if modulus == 1 {
        return Ok(0);
    }

    if exp < 0 {
        base = mod_inv(base, modulus)?;
        exp = -exp;
    }

    let mut result = 1;
    base = mod_reduce(base, modulus);

    while exp > 0 {
        if exp % 2 == 1 {
            result = mod_mul(result, base, modulus);
        }
        base = mod_mul(base, base, modulus);
        exp /= 2;
    }

    Ok(result)
}

/// Computes the modular inverse of `a` modulo `n`.
pub fn mod_inv(a: i128, n: i128) -> Result<i128, ModError> {
    let (g, x, _) = crate::modular_math::number_theory::extended_gcd(a, n);
    if g != 1 && g != -1 {
        return Err(ModError::InverseDoesNotExist(format!("{} and {} are not coprime", a, n)));
    }
    Ok(mod_reduce(x, n))
}

/// Divides `a` by `b` modulo `n`.
pub fn mod_div(a: i128, b: i128, n: i128) -> Result<i128, ModError> {
    let inv_b = mod_inv(b, n)?;
    Ok(mod_mul(a, inv_b, n))
}

/// Determines if a number is prime using trial division and Miller-Rabin.
pub fn is_prime(n: i128) -> bool {
    if n <= 1 {
        return false;
    }
    if n <= 3 {
        return true;
    }
    if n % 2 == 0 || n % 3 == 0 {
        return false;
    }

    // Trial division for small primes
    let mut i = 5;
    while i * i <= n.min(10000) {
        if n % i == 0 || n % (i + 2) == 0 {
            return false;
        }
        i += 6;
    }

    if n <= 10000 {
        return true;
    }

    // Miller-Rabin for larger numbers
    let mut d = n - 1;
    let mut s = 0;
    while d % 2 == 0 {
        d /= 2;
        s += 1;
    }

    let bases = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37];
    for &a in &bases {
        if n <= a {
            break;
        }
        let mut x = mod_pow(a, d, n).unwrap();
        if x == 1 || x == n - 1 {
            continue;
        }
        let mut composite = true;
        for _ in 1..s {
            x = mod_pow(x, 2, n).unwrap();
            if x == n - 1 {
                composite = false;
                break;
            }
        }
        if composite {
            return false;
        }
    }

    true
}
