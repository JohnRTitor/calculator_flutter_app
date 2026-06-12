import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:calculator_flutter_app/generated/rust/shared/history.dart';
import 'package:calculator_flutter_app/generated/rust/bridge/calculator.dart'
    as bridge;

part 'history_provider.g.dart';

/// A Riverpod Notifier that manages the history of calculations.
///
/// Interacts with the Rust backend to load, save, clear, and delete history entries.
@Riverpod(keepAlive: true)
class History extends _$History {
  @override
  Future<List<HistoryEntry>> build() async {
    try {
      final file = await _getHistoryFile();
      await bridge.historyLoad(path: file.path);
    } catch (_) {}
    return bridge.historyGetAll();
  }

  Future<File> _getHistoryFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/calc_history.json');
  }

  Future<void> saveHistoryToFile() async {
    try {
      final file = await _getHistoryFile();
      await bridge.historySave(path: file.path);
    } catch (_) {}
  }

  Future<void> refresh() async {
    state = AsyncData(bridge.historyGetAll());
  }

  Future<void> delete(int index) async {
    bridge.historyDelete(index: BigInt.from(index));
    await saveHistoryToFile();
    await refresh();
  }

  Future<void> clear() async {
    bridge.historyClear();
    await saveHistoryToFile();
    await refresh();
  }
}
