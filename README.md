# Flutter Rust Calculator

A modern, production-quality Android calculator application built with a **Flutter** UI and a **Rust** calculation engine. 

## Features
- **Native Material Design 3 UI**: Uses `dynamic_color` for full Android 12+ Material You theming and edge-to-edge transparent system bars.
- **Rust Core**: A fully custom-built recursive descent parser handles all mathematical evaluations efficiently on a background thread.
- **Scientific Mode**: Easily switch between standard keypad and a full scientific interface (`sin`, `cos`, `tan`, `log`, `ln`, `sqrt`, `^`, `!`).
- **History & Memory**: Persistent on-disk calculation history and full memory functionality (`MC`, `MR`, `M+`, `M-`, `MS`).
- **Offline First**: Zero external runtime dependencies for mathematical evaluations.

## Development

This project was built using `flutter_rust_bridge`. 

To run the application locally:
```bash
flutter run
```

To cross-compile the release Android APK:
```bash
flutter build apk --release
```
