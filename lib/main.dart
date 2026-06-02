import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calculator_flutter_app/src/rust/frb_generated.dart';
import 'package:calculator_flutter_app/app.dart';

import 'package:flutter/services.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  ExternalLibrary? externalLibrary;
  if (Platform.isLinux) {
    final executable = Platform.resolvedExecutable;
    final libPath = path.join(path.dirname(executable), 'lib', 'librust_lib_calculator_flutter_app.so');
    if (File(libPath).existsSync()) {
      externalLibrary = ExternalLibrary.open(libPath);
    }
  }
  await RustLib.init(externalLibrary: externalLibrary);
  
  runApp(
    const ProviderScope(
      child: CalculatorApp(),
    ),
  );
}
