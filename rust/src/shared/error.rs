use std::fmt;

#[derive(Debug, Clone, PartialEq)]
pub enum CommonError {
    InvalidExpression(String),
    DivisionByZero,
    Overflow,
    DomainError(String),
    IoError(String),
}

impl fmt::Display for CommonError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            CommonError::InvalidExpression(msg) => write!(f, "Invalid Expression: {}", msg),
            CommonError::DivisionByZero => write!(f, "Division by Zero"),
            CommonError::Overflow => write!(f, "Overflow"),
            CommonError::DomainError(msg) => write!(f, "Domain Error: {}", msg),
            CommonError::IoError(msg) => write!(f, "IO Error: {}", msg),
        }
    }
}

impl std::error::Error for CommonError {}
