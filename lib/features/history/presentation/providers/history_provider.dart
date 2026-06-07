import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:calculator_flutter_app/generated/rust/bridge/calculator.dart';
import 'package:calculator_flutter_app/generated/rust/calculator/history.dart';

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
      await historyLoad(path: file.path);
    } catch (_) {}
    return historyGetAll();
  }

  Future<File> _getHistoryFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/calc_history.json');
  }

  Future<void> saveHistoryToFile() async {
    try {
      final file = await _getHistoryFile();
      await historySave(path: file.path);
    } catch (_) {}
  }

  Future<void> refresh() async {
    state = AsyncData(historyGetAll());
  }

  Future<void> delete(int index) async {
    historyDelete(index: BigInt.from(index));
    await saveHistoryToFile();
    await refresh();
  }

  Future<void> clear() async {
    historyClear();
    await saveHistoryToFile();
    await refresh();
  }
}
