use crate::modular_math::mod_arith::{mod_reduce, mod_pow, is_prime};
use crate::modular_math::number_theory::gcd;
use crate::modular_math::number_theory_ext::unit_group;

#[derive(Debug, Clone)]
pub struct RingInfo {
    pub n: i128,
    pub classification: String,
    pub is_integral_domain: bool,
    pub is_field: bool,
    pub units: Vec<i128>,
    pub zero_divisors: Vec<i128>,
    pub idempotents: Vec<i128>,
    pub nilpotents: Vec<i128>,
}

/// Returns the zero divisors in Z_n. (Non-zero elements not coprime to n)
pub fn zero_divisors(n: i128) -> Vec<i128> {
    let mut zd = Vec::new();
    let n = n.abs();
    if n <= 1 {
        return zd;
    }
    for i in 1..n {
        let g = gcd(i, n);
        if g > 1 && g < n {
            zd.push(i);
        }
    }
    zd
}

/// Returns pairs of zero divisors (a,b) where a*b = 0 mod n. 
/// It returns one pair for each zero divisor a.
pub fn zero_divisor_pairs(n: i128) -> Vec<(i128, i128)> {
    let mut pairs = Vec::new();
    let n = n.abs();
    if n <= 1 {
        return pairs;
    }
    for i in 1..n {
        let g = gcd(i, n);
        if g > 1 && g < n {
            let b = n / g; // i * (n/g) = (i/g) * n == 0 mod n
            pairs.push((i, b));
        }
    }
    pairs
}

/// Returns the idempotent elements of Z_n (elements where a^2 == a mod n).
pub fn idempotents(n: i128) -> Vec<i128> {
    let mut idemp = Vec::new();
    let n = n.abs();
    if n <= 1 {
        return idemp;
    }
    for i in 0..n {
        if mod_pow(i, 2, n).unwrap_or(0) == i {
            idemp.push(i);
        }
    }
    idemp
}

/// Returns the nilpotent elements of Z_n (elements where a^k == 0 mod n for some k).
pub fn nilpotents(n: i128) -> Vec<i128> {
    let mut nilp = Vec::new();
    let n = n.abs();
    if n <= 1 {
        return nilp;
    }
    
    // An element a is nilpotent mod n iff every prime factor of n divides a.
    let factors = crate::modular_math::number_theory_ext::prime_factorization(n);
    let mut product_of_primes = 1;
    for (p, _) in factors {
        product_of_primes *= p;
    }
    
    for i in 0..n {
        if i % product_of_primes == 0 {
            nilp.push(i);
        }
    }
    nilp
}

/// Classifies the ring Z_n.
pub fn ring_classify(n: i128) -> RingInfo {
    let is_p = is_prime(n);
    let class_str = if is_p {
        "Finite Field (Galois Field)"
    } else if n == 1 {
        "Trivial Ring"
    } else {
        "Commutative Ring with Unity"
    };

    RingInfo {
        n,
        classification: class_str.to_string(),
        is_integral_domain: is_p,
        is_field: is_p,
        units: unit_group(n),
        zero_divisors: zero_divisors(n),
        idempotents: idempotents(n),
        nilpotents: nilpotents(n),
    }
}
