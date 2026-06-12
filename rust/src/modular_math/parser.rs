use crate::modular_math::error::ModError;

#[derive(Debug, Clone, PartialEq)]
pub enum ModToken {
    Number(i128),
    Plus,
    Minus,
    Multiply,
    Divide,
    Power,
    Mod,
    PowMod,
    Inv,
    Gcd,
    Egcd,
    Crt,
    Comma,
    LParen,
    RParen,
}

#[derive(Debug, Clone)]
pub enum ModExpr {
    Number(i128),
    Add(Box<ModExpr>, Box<ModExpr>),
    Subtract(Box<ModExpr>, Box<ModExpr>),
    Multiply(Box<ModExpr>, Box<ModExpr>),
    Divide(Box<ModExpr>, Box<ModExpr>),
    Power(Box<ModExpr>, Box<ModExpr>),
    Modulo(Box<ModExpr>, Box<ModExpr>),
    PowMod(Box<ModExpr>, Box<ModExpr>, Box<ModExpr>),
    Inv(Box<ModExpr>, Box<ModExpr>),
    Gcd(Box<ModExpr>, Box<ModExpr>),
    Egcd(Box<ModExpr>, Box<ModExpr>),
    Crt(Vec<(Box<ModExpr>, Box<ModExpr>)>),
    Negate(Box<ModExpr>),
}

pub fn tokenize(input: &str) -> Result<Vec<ModToken>, ModError> {
    let mut tokens = Vec::new();
    let chars: Vec<char> = input.chars().collect();
    let mut i = 0;

    while i < chars.len() {
        let c = chars[i];
        if c.is_whitespace() {
            i += 1;
            continue;
        }

        if c.is_ascii_digit() {
            let mut num_str = String::new();
            while i < chars.len() && chars[i].is_ascii_digit() {
                num_str.push(chars[i]);
                i += 1;
            }
            let num = num_str.parse::<i128>().map_err(|_| ModError::InvalidExpression(format!("Invalid number: {}", num_str)))?;
            tokens.push(ModToken::Number(num));
            continue;
        }

        if c.is_ascii_alphabetic() {
            let mut ident = String::new();
            while i < chars.len() && chars[i].is_ascii_alphabetic() {
                ident.push(chars[i].to_ascii_lowercase());
                i += 1;
            }
            
            match ident.as_str() {
                "mod" => tokens.push(ModToken::Mod),
                "powmod" => tokens.push(ModToken::PowMod),
                "inv" => tokens.push(ModToken::Inv),
                "gcd" => tokens.push(ModToken::Gcd),
                "egcd" => tokens.push(ModToken::Egcd),
                "crt" => tokens.push(ModToken::Crt),
                _ => return Err(ModError::InvalidExpression(format!("Unknown function or operator: {}", ident))),
            }
            continue;
        }

        match c {
            '+' => tokens.push(ModToken::Plus),
            '-' => tokens.push(ModToken::Minus),
            '*' | '×' => tokens.push(ModToken::Multiply),
            '/' | '÷' => tokens.push(ModToken::Divide),
            '^' => tokens.push(ModToken::Power),
            ',' => tokens.push(ModToken::Comma),
            '(' => tokens.push(ModToken::LParen),
            ')' => tokens.push(ModToken::RParen),
            _ => return Err(ModError::InvalidExpression(format!("Unexpected character: {}", c))),
        }
        i += 1;
    }

    Ok(tokens)
}

pub fn parse(tokens: &[ModToken]) -> Result<ModExpr, ModError> {
    let mut pos = 0;
    let expr = parse_expression(tokens, &mut pos)?;
    if pos < tokens.len() {
        return Err(ModError::InvalidExpression("Unexpected tokens at the end".to_string()));
    }
    Ok(expr)
}

fn parse_expression(tokens: &[ModToken], pos: &mut usize) -> Result<ModExpr, ModError> {
    parse_term(tokens, pos)
}

fn parse_term(tokens: &[ModToken], pos: &mut usize) -> Result<ModExpr, ModError> {
    let mut expr = parse_factor(tokens, pos)?;

    while *pos < tokens.len() {
        match tokens[*pos] {
            ModToken::Plus => {
                *pos += 1;
                let right = parse_factor(tokens, pos)?;
                expr = ModExpr::Add(Box::new(expr), Box::new(right));
            }
            ModToken::Minus => {
                *pos += 1;
                let right = parse_factor(tokens, pos)?;
                expr = ModExpr::Subtract(Box::new(expr), Box::new(right));
            }
            ModToken::Mod => {
                *pos += 1;
                let right = parse_factor(tokens, pos)?;
                expr = ModExpr::Modulo(Box::new(expr), Box::new(right));
            }
            _ => break,
        }
    }

    Ok(expr)
}

fn parse_factor(tokens: &[ModToken], pos: &mut usize) -> Result<ModExpr, ModError> {
    let mut expr = parse_power(tokens, pos)?;

    while *pos < tokens.len() {
        match tokens[*pos] {
            ModToken::Multiply => {
                *pos += 1;
                let right = parse_power(tokens, pos)?;
                expr = ModExpr::Multiply(Box::new(expr), Box::new(right));
            }
            ModToken::Divide => {
                *pos += 1;
                let right = parse_power(tokens, pos)?;
                expr = ModExpr::Divide(Box::new(expr), Box::new(right));
            }
            _ => break,
        }
    }

    Ok(expr)
}

fn parse_power(tokens: &[ModToken], pos: &mut usize) -> Result<ModExpr, ModError> {
    let mut expr = parse_unary(tokens, pos)?;

    if *pos < tokens.len() && tokens[*pos] == ModToken::Power {
        *pos += 1;
        let right = parse_power(tokens, pos)?; // Right-associative
        expr = ModExpr::Power(Box::new(expr), Box::new(right));
    }

    Ok(expr)
}

fn parse_unary(tokens: &[ModToken], pos: &mut usize) -> Result<ModExpr, ModError> {
    if *pos < tokens.len() && tokens[*pos] == ModToken::Minus {
        *pos += 1;
        let expr = parse_unary(tokens, pos)?;
        Ok(ModExpr::Negate(Box::new(expr)))
    } else {
        parse_primary(tokens, pos)
    }
}

fn parse_primary(tokens: &[ModToken], pos: &mut usize) -> Result<ModExpr, ModError> {
    if *pos >= tokens.len() {
        return Err(ModError::InvalidExpression("Unexpected end of expression".to_string()));
    }

    match &tokens[*pos] {
        ModToken::Number(n) => {
            *pos += 1;
            Ok(ModExpr::Number(*n))
        }
        ModToken::LParen => {
            *pos += 1;
            let expr = parse_expression(tokens, pos)?;
            if *pos >= tokens.len() || tokens[*pos] != ModToken::RParen {
                return Err(ModError::InvalidExpression("Expected ')'".to_string()));
            }
            *pos += 1;
            Ok(expr)
        }
        ModToken::PowMod => {
            *pos += 1; // consume powmod
            expect_token(tokens, pos, ModToken::LParen)?;
            let base = parse_expression(tokens, pos)?;
            expect_token(tokens, pos, ModToken::Comma)?;
            let exp = parse_expression(tokens, pos)?;
            expect_token(tokens, pos, ModToken::Comma)?;
            let m = parse_expression(tokens, pos)?;
            expect_token(tokens, pos, ModToken::RParen)?;
            Ok(ModExpr::PowMod(Box::new(base), Box::new(exp), Box::new(m)))
        }
        ModToken::Inv => {
            *pos += 1;
            expect_token(tokens, pos, ModToken::LParen)?;
            let a = parse_expression(tokens, pos)?;
            expect_token(tokens, pos, ModToken::Comma)?;
            let m = parse_expression(tokens, pos)?;
            expect_token(tokens, pos, ModToken::RParen)?;
            Ok(ModExpr::Inv(Box::new(a), Box::new(m)))
        }
        ModToken::Gcd => {
            *pos += 1;
            expect_token(tokens, pos, ModToken::LParen)?;
            let a = parse_expression(tokens, pos)?;
            expect_token(tokens, pos, ModToken::Comma)?;
            let b = parse_expression(tokens, pos)?;
            expect_token(tokens, pos, ModToken::RParen)?;
            Ok(ModExpr::Gcd(Box::new(a), Box::new(b)))
        }
        ModToken::Egcd => {
            *pos += 1;
            expect_token(tokens, pos, ModToken::LParen)?;
            let a = parse_expression(tokens, pos)?;
            expect_token(tokens, pos, ModToken::Comma)?;
            let b = parse_expression(tokens, pos)?;
            expect_token(tokens, pos, ModToken::RParen)?;
            Ok(ModExpr::Egcd(Box::new(a), Box::new(b)))
        }
        ModToken::Crt => {
            *pos += 1;
            expect_token(tokens, pos, ModToken::LParen)?;
            let mut pairs = Vec::new();
            
            loop {
                let rem = parse_expression(tokens, pos)?;
                // Allow "mod" or comma as separator between rem and mod
                let has_mod_token = if *pos < tokens.len() && tokens[*pos] == ModToken::Mod {
                    *pos += 1;
                    true
                } else {
                    expect_token(tokens, pos, ModToken::Comma)?;
                    false
                };
                
                let m = parse_expression(tokens, pos)?;
                pairs.push((Box::new(rem), Box::new(m)));
                
                if *pos < tokens.len() && tokens[*pos] == ModToken::Comma {
                    *pos += 1;
                } else {
                    break;
                }
            }
            
            expect_token(tokens, pos, ModToken::RParen)?;
            Ok(ModExpr::Crt(pairs))
        }
        _ => Err(ModError::InvalidExpression(format!("Unexpected token: {:?}", tokens[*pos]))),
    }
}

fn expect_token(tokens: &[ModToken], pos: &mut usize, expected: ModToken) -> Result<(), ModError> {
    if *pos >= tokens.len() {
        return Err(ModError::InvalidExpression(format!("Expected {:?}, found end of expression", expected)));
    }
    if tokens[*pos] == expected {
        *pos += 1;
        Ok(())
    } else {
        Err(ModError::InvalidExpression(format!("Expected {:?}, found {:?}", expected, tokens[*pos])))
    }
}
