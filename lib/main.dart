import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calculator_flutter_app/generated/rust/frb_generated.dart';

import 'package:calculator_flutter_app/app/app.dart';

import 'package:flutter/services.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

/// The main entry point for the Calculator application.
///
/// Initializes Flutter bindings, sets up Edge-to-Edge UI, loads the Rust library
/// via flutter_rust_bridge, and starts the app wrapped in a Riverpod ProviderScope.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  ExternalLibrary? externalLibrary;
  if (Platform.isLinux) {
    final executable = Platform.resolvedExecutable;
    final libPath = path.join(
      path.dirname(executable),
      'lib',
      'librust_lib_calculator_flutter_app.so',
    );
    if (File(libPath).existsSync()) {
      externalLibrary = ExternalLibrary.open(libPath);
    }
  }
  await RustLib.init(externalLibrary: externalLibrary);

  runApp(const ProviderScope(child: CalculatorApp()));
}
