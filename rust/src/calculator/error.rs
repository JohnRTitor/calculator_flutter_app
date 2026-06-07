use std::fmt;

#[derive(Debug, Clone)]
pub enum CalcError {
    InvalidExpression(String),
    DivisionByZero,
    Overflow,
    DomainError(String),
    IoError(String),
}

impl fmt::Display for CalcError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            CalcError::InvalidExpression(msg) => write!(f, "Invalid Expression: {}", msg),
            CalcError::DivisionByZero => write!(f, "Division By Zero"),
            CalcError::Overflow => write!(f, "Overflow"),
            CalcError::DomainError(msg) => write!(f, "Domain Error: {}", msg),
            CalcError::IoError(msg) => write!(f, "IO Error: {}", msg),
        }
    }
}

// Needed for flutter_rust_bridge Result returns
impl std::error::Error for CalcError {}
