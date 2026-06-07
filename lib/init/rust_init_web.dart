import 'package:calculator_flutter_app/generated/rust/frb_generated.dart';

Future<void> initializeRust() async {
  await RustLib.init();
}
