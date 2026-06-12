#[cfg(test)]
mod tests {
    use crate::bridge::modular_math::analyze_structure;

    #[test]
    fn test_ring_classification() {
        let res = analyze_structure("ring".to_string(), "12".to_string()).unwrap();
        assert_eq!(res.label, "Z_12");
        assert_eq!(res.order, "|Z_12| = 12");
        assert_eq!(res.is_cyclic, true);
        assert!(res.units.as_ref().unwrap().contains("1, 5, 7, 11"));
        assert!(res.zero_divisors.as_ref().unwrap().contains("2, 3, 4, 6, 8, 9, 10"));
        assert!(res.idempotents.as_ref().unwrap().contains("4, 9"));
        assert!(res.nilpotents.as_ref().unwrap().contains("6"));
    }

    #[test]
    fn test_group_classification() {
        let res = analyze_structure("group".to_string(), "10".to_string()).unwrap();
        assert_eq!(res.label, "Z_10*");
        assert_eq!(res.order, "|Z_10*| = φ(10) = 4");
        assert_eq!(res.is_cyclic, true);
        assert!(res.generators.as_ref().unwrap().contains("3, 7"));
    }

    #[test]
    fn test_field_classification() {
        let res = analyze_structure("field".to_string(), "7".to_string()).unwrap();
        assert_eq!(res.label, "GF(7)");
        assert_eq!(res.order, "|GF(7)| = 7");
        assert_eq!(res.is_cyclic, true);

        let err_res = analyze_structure("field".to_string(), "10".to_string());
        assert!(err_res.is_err());
    }
}
