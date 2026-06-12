use std::fmt;

/// Represents errors that can occur during modular arithmetic evaluation or parsing.
#[derive(Debug, Clone)]
pub enum ModError {
    InvalidModulus(String),
    InverseDoesNotExist(String),
    NotPrime(String),
    InconsistentCRT(String),
    DivisionByZero,
    InvalidExpression(String),
    InvalidPolynomial(String),
    Overflow,
}

impl fmt::Display for ModError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            ModError::InvalidModulus(msg) => write!(f, "Invalid Modulus: {}", msg),
            ModError::InverseDoesNotExist(msg) => write!(f, "Inverse does not exist: {}", msg),
            ModError::NotPrime(msg) => write!(f, "Not Prime: {}", msg),
            ModError::InconsistentCRT(msg) => write!(f, "Inconsistent CRT system: {}", msg),
            ModError::DivisionByZero => write!(f, "Division By Zero"),
            ModError::InvalidExpression(msg) => write!(f, "Invalid Expression: {}", msg),
            ModError::InvalidPolynomial(msg) => write!(f, "Invalid Polynomial: {}", msg),
            ModError::Overflow => write!(f, "Overflow"),
        }
    }
}

impl std::error::Error for ModError {}
