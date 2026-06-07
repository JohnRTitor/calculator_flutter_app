#[cfg(test)]
mod tests {
    use crate::calculator::evaluator;
    use crate::calculator::parser;

    // Base evaluation function that returns the raw Result
    fn evaluate_core(
        expr: &str,
        is_degree: bool,
        ans_value: f64,
    ) -> Result<crate::calculator::rational::CalcValue, crate::calculator::error::CalcError> {
        let tokens = parser::tokenize(expr).unwrap();
        let mut p = parser::Parser::new(&tokens);
        let ast = p.parse().unwrap();
        evaluator::evaluate_expr(&ast, is_degree, ans_value)
    }

    // Convenience: evaluates to f64 with default state (radians, ans = 0)
    fn eval(expr: &str) -> f64 {
        evaluate_core(expr, false, 0.0).unwrap().to_float()
    }

    // Convenience: evaluates to f64 with custom state
    fn eval_with_state(expr: &str, is_degree: bool, ans_value: f64) -> f64 {
        evaluate_core(expr, is_degree, ans_value)
            .unwrap()
            .to_float()
    }

    // Convenience: evaluates to Result (useful for testing expected errors)
    fn eval_result(
        expr: &str,
        is_degree: bool,
    ) -> Result<crate::calculator::rational::CalcValue, crate::calculator::error::CalcError> {
        evaluate_core(expr, is_degree, 0.0)
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
        assert!(
            (eval_with_state("asin(1)", false, 0.0) - std::f64::consts::PI / 2.0).abs() < 1e-10
        );
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

    #[test]
    fn test_edge_cases() {
        assert!(matches!(
            eval_result("1/0", false),
            Err(crate::calculator::error::CalcError::DivisionByZero)
        ));
        assert!(matches!(
            eval_result("1/cos(90)", true),
            Err(crate::calculator::error::CalcError::DivisionByZero)
        ));
        assert!(matches!(
            eval_result("tan(90)", true),
            Err(crate::calculator::error::CalcError::DomainError(_))
        ));
        assert!(matches!(
            eval_result("sqrt(-1)", false),
            Err(crate::calculator::error::CalcError::DomainError(_))
        ));
        assert!(matches!(
            eval_result("asin(2)", false),
            Err(crate::calculator::error::CalcError::DomainError(_))
        ));
        assert!(matches!(
            eval_result("0/0", false),
            Err(crate::calculator::error::CalcError::DivisionByZero)
        ));

        assert_eq!(eval_with_state("cos(90)", true, 0.0), 0.0);
        assert_eq!(eval_with_state("sin(180)", true, 0.0), 0.0);
        assert_eq!(eval_with_state("tan(180)", true, 0.0), 0.0);
    }

    #[test]
    fn test_length_conversion() {
        let cats = crate::unit_converter::converter::get_all_categories();
        let length_cat = cats.iter().find(|c| c.id == "length").unwrap();

        let m = length_cat.units.iter().find(|u| u.id == "m").unwrap();
        let km = length_cat.units.iter().find(|u| u.id == "km").unwrap();

        let res1 = crate::unit_converter::converter::convert_standard(1000.0, m, km);
        assert!((res1 - 1.0).abs() < 1e-9);
    }

    #[test]
    fn test_temperature_conversion() {
        let cats = crate::unit_converter::converter::get_all_categories();
        let temp_cat = cats.iter().find(|c| c.id == "temperature").unwrap();
        let c = temp_cat.units.iter().find(|u| u.id == "c").unwrap();
        let f = temp_cat.units.iter().find(|u| u.id == "f").unwrap();

        let res1 = crate::unit_converter::converter::convert_standard(0.0, c, f);
        assert!((res1 - 32.0).abs() < 1e-9);
    }

    #[test]
    fn test_bmi_calculation() {
        let (bmi, category) = crate::unit_converter::converter::calculate_bmi(70.0, 1.75);
        assert!((bmi - 22.857142857142858).abs() < 1e-9);
        assert_eq!(category, "Normal");
    }

    #[test]
    fn test_numeral_conversion() {
        let hex_val = crate::unit_converter::converter::convert_numeral("255", 10, 16).unwrap();
        assert_eq!(hex_val, "FF");
    }
}
