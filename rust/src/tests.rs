#[cfg(test)]
mod tests {
    use crate::parser;
    use crate::evaluator;

    fn eval(expr: &str) -> f64 {
        eval_with_state(expr, false, 0.0)
    }

    fn eval_with_state(expr: &str, is_degree: bool, ans_value: f64) -> f64 {
        let tokens = parser::tokenize(expr).unwrap();
        let mut p = parser::Parser::new(&tokens);
        let ast = p.parse().unwrap();
        evaluator::evaluate_expr(&ast, is_degree, ans_value).unwrap()
    }

    fn eval_result(
        expr: &str,
        is_degree: bool,
        ans_value: f64,
    ) -> Result<f64, crate::error::CalcError> {
        let tokens = parser::tokenize(expr).unwrap();
        let mut p = parser::Parser::new(&tokens);
        let ast = p.parse().unwrap();
        evaluator::evaluate_expr(&ast, is_degree, ans_value)
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

    #[test]
    fn test_trig_modes() {
        assert!((eval_with_state("sin(90)", true, 0.0) - 1.0).abs() < 1e-10);
        assert!((eval_with_state("sin(π/2)", false, 0.0) - 1.0).abs() < 1e-10);
        assert!((eval_with_state("asin(1)", true, 0.0) - 90.0).abs() < 1e-10);
        assert!((eval_with_state("asin(1)", false, 0.0) - std::f64::consts::PI / 2.0).abs() < 1e-10);
    }

    #[test]
    fn test_trig_division_by_zero() {
        assert_eq!(eval_with_state("cos(90)", true, 0.0), 0.0);
        let result = eval_result("1/cos(90)", true, 0.0);
        assert!(matches!(result, Err(crate::error::CalcError::DivisionByZero)));
    }

    #[test]
    fn test_hyperbolic() {
        assert_eq!(eval("sinh(0)"), 0.0);
        assert_eq!(eval("cosh(0)"), 1.0);
        assert_eq!(eval("tanh(0)"), 0.0);
    }

    #[test]
    fn test_ans() {
        assert_eq!(eval_with_state("5+ans", false, 10.0), 15.0);
        assert_eq!(eval_with_state("ans*2", false, 21.0), 42.0);
    }
}
