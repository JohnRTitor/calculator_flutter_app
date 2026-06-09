use crate::bridge::currency::{
    calculate_discount, calculate_gst, calculate_investment_one_time, calculate_investment_sip,
    calculate_loan_emi,
};

#[test]
fn test_loan_emi() {
    // 100,000 principal, 10% annual interest, 12 months
    let loan = calculate_loan_emi(100_000.0, 10.0, 12);

    // EMI ~ 8791.59
    assert!((loan.monthly_emi - 8791.59).abs() < 1.0);
    assert!((loan.total_interest - 5499.06).abs() < 1.0);
    assert!((loan.total_payment - 105499.06).abs() < 1.0);

    // Zero interest
    let loan_zero_int = calculate_loan_emi(120_000.0, 0.0, 12);
    assert!((loan_zero_int.monthly_emi - 10000.0).abs() < 1e-9);
    assert_eq!(loan_zero_int.total_interest, 0.0);
    assert_eq!(loan_zero_int.total_payment, 120_000.0);

    // Zero principal
    let loan_zero_prin = calculate_loan_emi(0.0, 10.0, 12);
    assert_eq!(loan_zero_prin.monthly_emi, 0.0);
    assert_eq!(loan_zero_prin.total_interest, 0.0);
    assert_eq!(loan_zero_prin.total_payment, 0.0);
}

#[test]
fn test_investment_one_time() {
    // 10,000 principal, 12% return, 5 years, compounded 1 time per year (annual)
    let inv = calculate_investment_one_time(10_000.0, 12.0, 5.0, 1.0);

    // 10000 * (1.12)^5 = 17623.4168
    assert!((inv.future_value - 17623.42).abs() < 1.0);
    assert_eq!(inv.total_investment, 10_000.0);
    assert!((inv.total_interest - 7623.42).abs() < 1.0);

    // Zero return
    let inv_zero = calculate_investment_one_time(10_000.0, 0.0, 5.0, 1.0);
    assert_eq!(inv_zero.future_value, 10_000.0);
    assert_eq!(inv_zero.total_interest, 0.0);
}

#[test]
fn test_investment_sip() {
    // 1000 per month, 12% return, 5 years
    let sip = calculate_investment_sip(1000.0, 12.0, 5.0);

    // 82486.37
    assert!((sip.future_value - 82486.37).abs() < 1.0);
    assert_eq!(sip.total_investment, 60_000.0);
    assert!((sip.total_interest - 22486.37).abs() < 1.0);

    // Zero return
    let sip_zero = calculate_investment_sip(1000.0, 0.0, 5.0);
    assert_eq!(sip_zero.future_value, 60_000.0);
    assert_eq!(sip_zero.total_interest, 0.0);
}

#[test]
fn test_discount() {
    // 100 price, 20% discount
    let disc1 = calculate_discount(100.0, 20.0);
    assert_eq!(disc1.final_price, 80.0);
    assert_eq!(disc1.amount_saved, 20.0);

    // 0% discount
    let disc2 = calculate_discount(100.0, 0.0);
    assert_eq!(disc2.final_price, 100.0);
    assert_eq!(disc2.amount_saved, 0.0);

    // 100% discount
    let disc3 = calculate_discount(100.0, 100.0);
    assert_eq!(disc3.final_price, 0.0);
    assert_eq!(disc3.amount_saved, 100.0);
}

#[test]
fn test_gst() {
    // Add GST: 100 base, 18% GST
    let gst_add = calculate_gst(100.0, 18.0, true);
    assert_eq!(gst_add.total_amount, 118.0);
    assert_eq!(gst_add.gst_amount, 18.0);
    assert_eq!(gst_add.original_amount, 100.0);

    // Remove GST: 118 total, 18% GST
    let gst_sub = calculate_gst(118.0, 18.0, false);
    assert_eq!(gst_sub.total_amount, 118.0);
    assert_eq!(gst_sub.gst_amount, 18.0);
    assert_eq!(gst_sub.original_amount, 100.0);

    // 0% GST
    let gst_zero = calculate_gst(100.0, 0.0, true);
    assert_eq!(gst_zero.total_amount, 100.0);
    assert_eq!(gst_zero.gst_amount, 0.0);
    assert_eq!(gst_zero.original_amount, 100.0);
}
