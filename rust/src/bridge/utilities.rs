use flutter_rust_bridge::frb;

/// FFI representation of a precise date difference
#[frb]
pub struct DateDiffResult {
    pub years: i32,
    pub months: i32,
    pub days: i32,
    pub total_days: i32,
}

/// Calculates the difference between two timestamps (in milliseconds since epoch)
#[frb(sync)]
pub fn calculate_date_difference(start_timestamp_ms: i64, end_timestamp_ms: i64) -> DateDiffResult {
    // Note: A robust calendar implementation is complex. For simple utilities without bringing in chrono,
    // we use a simplified approximation or we just calculate total days.
    // For exact calendar months/years, standard libraries or chrono are better.
    // But we can approximate it using total days.
    let diff_ms = (end_timestamp_ms - start_timestamp_ms).abs();
    let total_days = (diff_ms / (1000 * 60 * 60 * 24)) as i32;
    
    // Very simplified approximation for years/months/days just from total days
    let years = total_days / 365;
    let mut remaining = total_days % 365;
    let months = remaining / 30;
    let days = remaining % 30;

    DateDiffResult {
        years,
        months,
        days,
        total_days,
    }
}

/// FFI representation of a Loan/EMI calculation result
#[frb]
pub struct LoanResult {
    pub monthly_emi: f64,
    pub total_interest: f64,
    pub total_payment: f64,
}

/// Calculates EMI and total interest for a loan
#[frb(sync)]
pub fn calculate_loan_emi(principal: f64, annual_interest_rate: f64, tenure_months: i32) -> LoanResult {
    if principal <= 0.0 || tenure_months <= 0 {
        return LoanResult {
            monthly_emi: 0.0,
            total_interest: 0.0,
            total_payment: 0.0,
        };
    }
    
    if annual_interest_rate <= 0.0 {
        let monthly_emi = principal / (tenure_months as f64);
        return LoanResult {
            monthly_emi,
            total_interest: 0.0,
            total_payment: principal,
        };
    }

    let r = (annual_interest_rate / 12.0) / 100.0;
    let n = tenure_months as f64;
    
    let compound_factor = (1.0 + r).powf(n);
    let monthly_emi = principal * r * compound_factor / (compound_factor - 1.0);
    
    let total_payment = monthly_emi * n;
    let total_interest = total_payment - principal;

    LoanResult {
        monthly_emi,
        total_interest,
        total_payment,
    }
}

/// FFI representation of an Investment calculation result
#[frb]
pub struct InvestmentResult {
    pub future_value: f64,
    pub total_investment: f64,
    pub total_interest: f64,
}

/// Calculates the future value of a one-time investment
#[frb(sync)]
pub fn calculate_investment_one_time(
    principal: f64, 
    annual_interest_rate: f64, 
    years: f64, 
    compounds_per_year: f64
) -> InvestmentResult {
    let r = annual_interest_rate / 100.0;
    let n = compounds_per_year;
    let t = years;
    
    let future_value = principal * (1.0 + r / n).powf(n * t);
    let total_interest = future_value - principal;
    
    InvestmentResult {
        future_value,
        total_investment: principal,
        total_interest,
    }
}

/// Calculates the future value of a Systematic Investment Plan (SIP)
#[frb(sync)]
pub fn calculate_investment_sip(
    monthly_contribution: f64, 
    annual_interest_rate: f64, 
    years: f64
) -> InvestmentResult {
    let r = (annual_interest_rate / 12.0) / 100.0;
    let n = years * 12.0;
    
    let total_investment = monthly_contribution * n;
    
    let future_value = if r > 0.0 {
        monthly_contribution * (((1.0 + r).powf(n) - 1.0) / r) * (1.0 + r)
    } else {
        total_investment
    };
    
    let total_interest = future_value - total_investment;
    
    InvestmentResult {
        future_value,
        total_investment,
        total_interest,
    }
}

/// FFI representation of a discount calculation result.
#[frb]
pub struct DiscountResult {
    pub amount_saved: f64,
    pub final_price: f64,
}

/// Calculates the discount and final price from an original price and percentage.
#[frb(sync)]
pub fn calculate_discount(original_price: f64, discount_percentage: f64) -> DiscountResult {
    let amount_saved = (original_price * discount_percentage) / 100.0;
    let final_price = original_price - amount_saved;
    DiscountResult {
        amount_saved,
        final_price,
    }
}

/// FFI representation of a Goods and Services Tax (GST) calculation result.
#[frb]
pub struct GstResult {
    pub gst_amount: f64,
    pub total_amount: f64,
    pub original_amount: f64,
}

/// Calculates the GST amount and total amount for a given base amount and rate.
#[frb(sync)]
pub fn calculate_gst(amount: f64, gst_percentage: f64, add_gst: bool) -> GstResult {
    if add_gst {
        let gst_amount = (amount * gst_percentage) / 100.0;
        let total_amount = amount + gst_amount;
        GstResult {
            gst_amount,
            total_amount,
            original_amount: amount,
        }
    } else {
        let original_amount = amount / (1.0 + gst_percentage / 100.0);
        let gst_amount = amount - original_amount;
        GstResult {
            gst_amount,
            total_amount: amount,
            original_amount,
        }
    }
}

/// FFI representation of a Body Mass Index (BMI) calculation result.
#[frb]
pub struct BmiResult {
    pub bmi: f64,
    pub category: String,
}

/// Calculates BMI based on weight (kg) and height (m).
#[frb(sync)]
pub fn calculate_bmi(weight_kg: f64, height_m: f64) -> BmiResult {
    if height_m <= 0.0 {
        return BmiResult {
            bmi: 0.0,
            category: "Invalid".to_string(),
        };
    }
    let bmi = weight_kg / (height_m * height_m);

    let category = if bmi < 18.5 {
        "Underweight"
    } else if bmi >= 18.5 && bmi < 25.0 {
        "Normal"
    } else if bmi >= 25.0 && bmi < 30.0 {
        "Overweight"
    } else {
        "Obese"
    };

    BmiResult {
        bmi,
        category: category.to_string(),
    }
}
