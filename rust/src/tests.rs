#[cfg(test)]
mod tests {
    use crate::parser;
    use crate::evaluator;

    fn eval(expr: &str) -> f64 {
        let tokens = parser::tokenize(expr).unwrap();
        let mut p = parser::Parser::new(&tokens);
        let ast = p.parse().unwrap();
        evaluator::evaluate_expr(&ast).unwrap()
    }

    #[test]
    fn test_basic_arithmetic() {
        assert_eq!(eval("2+2"), 4.0);
        assert_eq!(eval("10-3*2"), 4.0);
        assert_eq!(eval("(10-3)*2"), 14.0);
        assert_eq!(eval("10/2"), 5.0);
        assert_eq!(eval("10%3"), 1.0);
        assert_eq!(eval("-5+2"), -3.0);
    }

    #[test]
    fn test_implicit_multiplication() {
        assert_eq!(eval("2(3+4)"), 14.0);
        assert_eq!(eval("(2+3)(4+5)"), 45.0);
        assert_eq!(eval("2π"), 2.0 * std::f64::consts::PI);
        assert_eq!(eval("3e"), 3.0 * std::f64::consts::E);
    }

    #[test]
    fn test_scientific() {
        assert!((eval("sin(π/2)") - 1.0).abs() < 1e-10);
        assert!((eval("cos(0)") - 1.0).abs() < 1e-10);
        assert_eq!(eval("log(100)"), 2.0);
        assert_eq!(eval("ln(e)"), 1.0);
        assert_eq!(eval("sqrt(16)"), 4.0);
        assert_eq!(eval("5!"), 120.0);
        assert_eq!(eval("2^3"), 8.0);
        assert_eq!(eval("3!+2"), 8.0);
    }
    
    #[test]
    fn test_exponential_notation() {
        assert_eq!(eval("1e3"), 1000.0);
        assert_eq!(eval("2.5e-2"), 0.025);
    }
}
