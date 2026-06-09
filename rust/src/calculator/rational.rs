/// Calculates the Greatest Common Divisor (GCD) of two integers.
pub fn gcd(mut a: i128, mut b: i128) -> i128 {
    a = a.abs();
    b = b.abs();
    while b != 0 {
        let t = b;
        b = a % b;
        a = t;
    }
    a.max(1)
}

/// Represents a rational number with a numerator and denominator.
/// Used to maintain precision in calculations instead of falling back to floats immediately.
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct Rational {
    pub num: i128,
    pub den: i128,
}

impl Rational {
    /// Creates a new `Rational` number in its simplest form.
    pub fn new(num: i128, den: i128) -> Self {
        if den == 0 {
            return Self { num, den }; // Let upper levels handle division by zero or infinity
        }
        let g = gcd(num, den);
        let mut n = num / g;
        let mut d = den / g;
        if d < 0 {
            n = -n;
            d = -d;
        }
        Self { num: n, den: d }
    }
}

/// Represents the evaluated value of an expression.
/// Can be a precise Rational, a multiple of Pi, or a fallback floating point value.
#[derive(Clone, Copy, Debug, PartialEq)]
pub enum CalcValue {
    Rational(Rational),
    PiRational(Rational),
    Float(f64),
}

impl CalcValue {
    /// Converts this `CalcValue` into a standard `f64` float.
    pub fn to_float(self) -> f64 {
        match self {
            CalcValue::Rational(r) => r.num as f64 / r.den as f64,

            CalcValue::PiRational(r) => (r.num as f64 / r.den as f64) * std::f64::consts::PI,

            CalcValue::Float(f) => f,
        }
    }

    /// Converts this `CalcValue` into an exact fraction string, if possible.
    pub fn to_exact_fraction_string(&self) -> Option<String> {
        match self {
            CalcValue::Rational(r) => {
                if r.den != 1 {
                    Some(format!("{}/{}", r.num, r.den))
                } else {
                    None
                }
            }
            CalcValue::PiRational(r) => {
                if r.num == 0 {
                    Some("0".to_string())
                } else {
                    let num_str = if r.num == 1 {
                        "π".to_string()
                    } else if r.num == -1 {
                        "-π".to_string()
                    } else {
                        format!("{}π", r.num)
                    };
                    if r.den == 1 {
                        Some(num_str)
                    } else {
                        Some(format!("{}/{}", num_str, r.den))
                    }
                }
            }
            _ => None,
        }
    }

    /// Adds two `CalcValue`s, preserving rationality if possible.
    pub fn add(self, other: CalcValue) -> CalcValue {
        match (self, other) {
            (CalcValue::Rational(r1), CalcValue::Rational(r2)) => {
                let num = r1
                    .num
                    .checked_mul(r2.den)
                    .and_then(|n| n.checked_add(r2.num.checked_mul(r1.den)?));

                let den = r1.den.checked_mul(r2.den);

                match (num, den) {
                    (Some(n), Some(d)) => CalcValue::Rational(Rational::new(n, d)),
                    _ => CalcValue::Float(self.to_float() + other.to_float()), // overflow fallback
                }
            }

            (CalcValue::PiRational(r1), CalcValue::PiRational(r2)) => {
                let num = r1
                    .num
                    .checked_mul(r2.den)
                    .and_then(|n| n.checked_add(r2.num.checked_mul(r1.den)?));

                let den = r1.den.checked_mul(r2.den);

                match (num, den) {
                    (Some(n), Some(d)) => CalcValue::PiRational(Rational::new(n, d)),
                    _ => CalcValue::Float(self.to_float() + other.to_float()),
                }
            }

            _ => CalcValue::Float(self.to_float() + other.to_float()),
        }
    }

    /// Subtracts `other` from `self`, preserving rationality if possible.
    pub fn sub(self, other: CalcValue) -> CalcValue {
        match (self, other) {
            (CalcValue::Rational(r1), CalcValue::Rational(r2)) => {
                let num = r1
                    .num
                    .checked_mul(r2.den)
                    .and_then(|n| n.checked_sub(r2.num.checked_mul(r1.den)?));

                let den = r1.den.checked_mul(r2.den);

                match (num, den) {
                    (Some(n), Some(d)) => CalcValue::Rational(Rational::new(n, d)),
                    _ => CalcValue::Float(self.to_float() - other.to_float()),
                }
            }

            (CalcValue::PiRational(r1), CalcValue::PiRational(r2)) => {
                let num = r1
                    .num
                    .checked_mul(r2.den)
                    .and_then(|n| n.checked_sub(r2.num.checked_mul(r1.den)?));

                let den = r1.den.checked_mul(r2.den);

                match (num, den) {
                    (Some(n), Some(d)) => CalcValue::PiRational(Rational::new(n, d)),
                    _ => CalcValue::Float(self.to_float() - other.to_float()),
                }
            }

            _ => CalcValue::Float(self.to_float() - other.to_float()),
        }
    }

    /// Multiplies two `CalcValue`s, preserving rationality if possible.
    pub fn mul(self, other: CalcValue) -> CalcValue {
        match (self, other) {
            (CalcValue::Rational(r1), CalcValue::Rational(r2)) => {
                let num = r1.num.checked_mul(r2.num);
                let den = r1.den.checked_mul(r2.den);

                match (num, den) {
                    (Some(n), Some(d)) => CalcValue::Rational(Rational::new(n, d)),
                    _ => CalcValue::Float(self.to_float() * other.to_float()),
                }
            }

            (CalcValue::Rational(r1), CalcValue::PiRational(r2))
            | (CalcValue::PiRational(r2), CalcValue::Rational(r1)) => {
                let num = r1.num.checked_mul(r2.num);
                let den = r1.den.checked_mul(r2.den);

                match (num, den) {
                    (Some(n), Some(d)) => CalcValue::PiRational(Rational::new(n, d)),
                    _ => CalcValue::Float(self.to_float() * other.to_float()),
                }
            }

            _ => CalcValue::Float(self.to_float() * other.to_float()),
        }
    }

    /// Divides `self` by `other`, preserving rationality if possible.
    /// Returns an error if dividing by zero.
    pub fn div(self, other: CalcValue) -> Result<CalcValue, ()> {
        let other_float = other.to_float();
        if other_float == 0.0 {
            return Err(()); // Division by zero handled in upper levels
        }
        Ok(match (self, other) {
            (CalcValue::Rational(r1), CalcValue::Rational(r2)) => {
                let num = r1.num.checked_mul(r2.den);
                let den = r1.den.checked_mul(r2.num);

                match (num, den) {
                    (Some(n), Some(d)) => CalcValue::Rational(Rational::new(n, d)),
                    _ => CalcValue::Float(self.to_float() / other_float),
                }
            }

            (CalcValue::PiRational(r1), CalcValue::Rational(r2)) => {
                let num = r1.num.checked_mul(r2.den);
                let den = r1.den.checked_mul(r2.num);

                match (num, den) {
                    (Some(n), Some(d)) => CalcValue::PiRational(Rational::new(n, d)),
                    _ => CalcValue::Float(self.to_float() / other_float),
                }
            }

            (CalcValue::PiRational(r1), CalcValue::PiRational(r2)) => {
                let num = r1.num.checked_mul(r2.den);
                let den = r1.den.checked_mul(r2.num);

                match (num, den) {
                    // Pi cancels out
                    (Some(n), Some(d)) => CalcValue::Rational(Rational::new(n, d)),
                    _ => CalcValue::Float(self.to_float() / other_float),
                }
            }

            _ => CalcValue::Float(self.to_float() / other_float),
        })
    }

    /// Computes `self % other`. Always falls back to floating point evaluation.
    pub fn modulo(self, other: CalcValue) -> Result<CalcValue, ()> {
        let other_float = other.to_float();
        if other_float == 0.0 {
            return Err(());
        }
        // Keep modulo as float since it's rarely used exactly, but we can do exact modulo if both are rational and denominators match/etc
        // For simplicity, just float modulo
        Ok(CalcValue::Float(self.to_float() % other_float))
    }

    /// Raises `self` to the power of `other`, attempting to preserve rationality for integer exponents.
    pub fn pow(self, other: CalcValue) -> CalcValue {
        match (self, other) {
            (CalcValue::Rational(r1), CalcValue::Rational(r2)) if r2.den == 1 => {
                // Integer exponent
                if r2.num >= 0 && r2.num <= u32::MAX as i128 {
                    let num = r1.num.checked_pow(r2.num as u32);
                    let den = r1.den.checked_pow(r2.num as u32);

                    if let (Some(n), Some(d)) = (num, den) {
                        return CalcValue::Rational(Rational::new(n, d));
                    }
                } else if r2.num < 0 && r2.num.abs() <= u32::MAX as i128 {
                    // Negative exponent
                    let exp = r2.num.abs() as u32;
                    let num = r1.den.checked_pow(exp);
                    let den = r1.num.checked_pow(exp);

                    if let (Some(n), Some(d)) = (num, den) {
                        return CalcValue::Rational(Rational::new(n, d));
                    }
                }
                CalcValue::Float(self.to_float().powf(other.to_float()))
            }

            _ => CalcValue::Float(self.to_float().powf(other.to_float())),
        }
    }

    /// Negates this `CalcValue`.
    pub fn negate(self) -> CalcValue {
        match self {
            CalcValue::Rational(r) => CalcValue::Rational(Rational::new(-r.num, r.den)),

            CalcValue::PiRational(r) => CalcValue::PiRational(Rational::new(-r.num, r.den)),

            CalcValue::Float(f) => CalcValue::Float(-f),
        }
    }
}
