import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calculator_flutter_app/src/rust/frb_generated.dart';
import 'package:calculator_flutter_app/app.dart';

import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await RustLib.init();
  
  runApp(
    const ProviderScope(
      child: CalculatorApp(),
    ),
  );
}
