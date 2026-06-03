import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calculator_flutter_app/features/calculator/providers/calculator_provider.dart';

class TokenTextField extends ConsumerStatefulWidget {
  const TokenTextField({super.key});

  @override
  ConsumerState<TokenTextField> createState() => _TokenTextFieldState();
}

class _TokenTextFieldState extends ConsumerState<TokenTextField> {
  late TextEditingController _controller;
  bool _isUpdatingFromState = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(_onSelectionChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onSelectionChanged);
    _controller.dispose();
    super.dispose();
  }

  int _getCursorIndexFromCharOffset(List<String> tokens, int offset) {
    int currentOffset = 0;
    for (int i = 0; i < tokens.length; i++) {
      // If the tap is before the halfway point of the token, snap to before the token
      if (offset <= currentOffset + (tokens[i].length / 2)) {
        return i;
      }
      currentOffset += tokens[i].length;
    }
    return tokens.length;
  }

  int _getCharOffsetFromCursorIndex(List<String> tokens, int cursorIndex) {
    int offset = 0;
    for (int i = 0; i < cursorIndex && i < tokens.length; i++) {
      offset += tokens[i].length;
    }
    return offset;
  }

  void _onSelectionChanged() {
    if (_isUpdatingFromState) return;

    final state = ref.read(calculatorProvider);
    final selection = _controller.selection;

    if (selection.isValid && selection.isCollapsed) {
      final newIndex = _getCursorIndexFromCharOffset(state.tokens, selection.baseOffset);
      final snappedOffset = _getCharOffsetFromCursorIndex(state.tokens, newIndex);

      if (selection.baseOffset != snappedOffset) {
        _isUpdatingFromState = true;
        _controller.selection = TextSelection.collapsed(offset: snappedOffset);
        _isUpdatingFromState = false;
      }

      if (newIndex != state.cursorIndex) {
        // Schedule microtask to avoid updating provider during listener callback
        Future.microtask(() {
          ref.read(calculatorProvider.notifier).setCursor(newIndex);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(calculatorProvider);
    final theme = Theme.of(context);

    // Sync state to controller
    final expectedText = state.expression;
    final expectedOffset = _getCharOffsetFromCursorIndex(state.tokens, state.cursorIndex);

    _isUpdatingFromState = true;
    if (_controller.text != expectedText) {
      _controller.text = expectedText;
    }
    
    // Only update selection if it differs, to prevent interrupting user gestures unnecessarily
    if (_controller.selection.baseOffset != expectedOffset || !_controller.selection.isCollapsed) {
      _controller.selection = TextSelection.collapsed(offset: expectedOffset);
    }
    _isUpdatingFromState = false;

    return TextField(
      controller: _controller,
      readOnly: true,
      showCursor: true,
      autofocus: true,
      textAlign: TextAlign.right,
      style: theme.textTheme.headlineLarge?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w400,
        fontSize: 32,
      ),
      decoration: const InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
        isDense: true,
      ),
    );
  }
}
