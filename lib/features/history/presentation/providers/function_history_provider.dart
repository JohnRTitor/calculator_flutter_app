import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:calculator_flutter_app/generated/rust/bridge/calculator.dart' as bridge;
import 'package:calculator_flutter_app/generated/rust/shared/history.dart';

part 'function_history_provider.g.dart';

@Riverpod(keepAlive: true)
class FunctionHistory extends _$FunctionHistory {
  @override
  Future<List<HistoryEntry>> build() async {
    try {
      final file = await _getHistoryFile();
      await bridge.funcHistoryLoad(path: file.path);
    } catch (_) {}
    return bridge.funcHistoryGetAll();
  }

  Future<File> _getHistoryFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/func_history.json');
  }

  Future<void> saveHistoryToFile() async {
    try {
      final file = await _getHistoryFile();
      await bridge.funcHistorySave(path: file.path);
    } catch (_) {}
  }

  Future<void> refresh() async {
    state = AsyncData(bridge.funcHistoryGetAll());
  }

  Future<void> delete(int index) async {
    bridge.funcHistoryDelete(index: BigInt.from(index));
    await saveHistoryToFile();
    await refresh();
  }

  Future<void> clear() async {
    bridge.funcHistoryClear();
    await saveHistoryToFile();
    await refresh();
  }
}
