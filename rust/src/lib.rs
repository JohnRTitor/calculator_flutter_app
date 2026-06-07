/// The main library entry point for the Rust backend of the Calculator App.
/// Exposes modules for calculation logic, unit conversion, and Flutter Rust Bridge FFI.
pub mod bridge;
pub mod calculator;
pub mod converter;
mod frb_generated;
pub mod shared;

#[cfg(test)]
mod tests;
