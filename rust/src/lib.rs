/// The main library entry point for the Rust backend of the Calculator App.
/// Exposes modules for calculation logic, unit conversion, and Flutter Rust Bridge FFI.
pub mod bridge;
pub mod shared;
pub mod calculator;
pub mod converter;
pub mod modular_math;
mod frb_generated;
mod tests;
