import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:calculator_flutter_app/generated/rust/bridge/converter.dart';

// --- Currency API Service ---

/// A service responsible for fetching and caching live currency exchange rates
/// from an external API (frankfurter.app).
class CurrencyService {
  static const String _baseUrl = 'https://api.frankfurter.app/latest';
  static const String _cacheKey = 'currency_rates_cache';

  static const Map<String, double> _fallbackRates = {
    'USD': 1.0,
    'EUR': 0.92,
    'GBP': 0.79,
    'JPY': 150.0,
    'AUD': 1.52,
    'CAD': 1.36,
    'CHF': 0.90,
    'CNY': 7.20,
    'INR': 83.0,
  };

  /// Fetches the latest currency exchange rates relative to USD.
  /// Uses a local cache if available and less than 12 hours old, unless `forceRefresh` is true.
  Future<Map<String, double>> fetchRates({bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();

    if (!forceRefresh) {
      final cachedStr = prefs.getString(_cacheKey);
      if (cachedStr != null) {
        try {
          final data = jsonDecode(cachedStr) as Map<String, dynamic>;
          final timestamp = data['timestamp'] as int;
          // Cache for 24 hours (1 day)
          if (DateTime.now().millisecondsSinceEpoch - timestamp <
              24 * 60 * 60 * 1000) {
            return Map<String, double>.from(data['rates']);
          }
        } catch (e) {
          // Fall through to fetch
        }
      }
    }

    try {
      final response = await http.get(Uri.parse('$_baseUrl?base=USD'));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final ratesRaw = json['rates'] as Map<String, dynamic>;
        final rates = ratesRaw.map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        );
        // Add USD since it's the base
        rates['USD'] = 1.0;

        // Cache it
        await prefs.setString(
          _cacheKey,
          jsonEncode({
            'timestamp': DateTime.now().millisecondsSinceEpoch,
            'rates': rates,
          }),
        );

        return rates;
      } else {
        throw Exception('Failed to load exchange rates');
      }
    } catch (e) {
      // Fallback to cache if offline
      final cachedStr = prefs.getString(_cacheKey);
      if (cachedStr != null) {
        final data = jsonDecode(cachedStr) as Map<String, dynamic>;
        return Map<String, double>.from(data['rates']);
      }
      return _fallbackRates;
    }
  }
}

final currencyServiceProvider = Provider((ref) => CurrencyService());

// --- State Management ---

/// Holds the state for the Unit Converter feature.
class ConverterState {
  final FfiConverterCategory? category;
  final FfiUnit? fromUnit;
  final FfiUnit? toUnit;
  final String inputValue;
  final String resultValue;
  final Map<String, double> currencyRates;
  final bool isLoadingRates;

  // Custom states for special calculators
  final String discountPercentage;
  final String gstPercentage;
  final bool addGst;
  final String bmiHeight;
  final String bmiWeight;

  ConverterState({
    this.category,
    this.fromUnit,
    this.toUnit,
    this.inputValue = '',
    this.resultValue = '',
    this.currencyRates = const {},
    this.isLoadingRates = false,
    this.discountPercentage = '',
    this.gstPercentage = '',
    this.addGst = true,
    this.bmiHeight = '',
    this.bmiWeight = '',
  });

  ConverterState copyWith({
    FfiConverterCategory? category,
    FfiUnit? fromUnit,
    FfiUnit? toUnit,
    bool clearUnits = false,
    String? inputValue,
    String? resultValue,
    Map<String, double>? currencyRates,
    bool? isLoadingRates,
    String? discountPercentage,
    String? gstPercentage,
    bool? addGst,
    String? bmiHeight,
    String? bmiWeight,
  }) {
    return ConverterState(
      category: category ?? this.category,
      fromUnit: clearUnits ? null : (fromUnit ?? this.fromUnit),
      toUnit: clearUnits ? null : (toUnit ?? this.toUnit),
      inputValue: inputValue ?? this.inputValue,
      resultValue: resultValue ?? this.resultValue,
      currencyRates: currencyRates ?? this.currencyRates,
      isLoadingRates: isLoadingRates ?? this.isLoadingRates,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      gstPercentage: gstPercentage ?? this.gstPercentage,
      addGst: addGst ?? this.addGst,
      bmiHeight: bmiHeight ?? this.bmiHeight,
      bmiWeight: bmiWeight ?? this.bmiWeight,
    );
  }
}

/// A Riverpod Notifier managing the logic and state for all unit and currency conversions.
class ConverterNotifier extends Notifier<ConverterState> {
  @override
  ConverterState build() {
    // Cannot run async init directly in build synchronously returning state,
    // but we can trigger it.
    Future.microtask(() => _initCurrencyRates());
    return ConverterState();
  }

  Future<void> _initCurrencyRates() async {
    state = state.copyWith(isLoadingRates: true);
    try {
      final rates = await ref.read(currencyServiceProvider).fetchRates();
      state = state.copyWith(currencyRates: rates, isLoadingRates: false);
      if (state.category?.id == 'currency') {
        setCategory(state.category!);
      } else {
        _calculateResult();
      }
    } catch (e) {
      state = state.copyWith(isLoadingRates: false);
    }
  }

  Future<void> refreshCurrencyRates() async {
    state = state.copyWith(isLoadingRates: true);
    try {
      final rates = await ref.read(currencyServiceProvider).fetchRates(forceRefresh: true);
      state = state.copyWith(currencyRates: rates, isLoadingRates: false);
      if (state.category?.id == 'currency') {
        setCategory(state.category!);
      } else {
        _calculateResult();
      }
    } catch (e) {
      state = state.copyWith(isLoadingRates: false);
    }
  }

  void setCategory(FfiConverterCategory category) {
    if (category.id == 'currency') {
      // Create virtual units for currency
      if (state.currencyRates.isNotEmpty) {
        final units = state.currencyRates.keys
            .map(
              (k) => FfiUnit(
                id: k,
                name: k,
                symbol: k,
                multiplier: 1.0,
                offset: 0.0,
              ),
            )
            .toList();
        final cat = FfiConverterCategory(
          id: 'currency',
          name: 'Currency',
          iconName: 'currency_exchange',
          units: units,
        );
        state = state.copyWith(
          category: cat,
          fromUnit: units.isNotEmpty ? units.first : null,
          toUnit: units.length > 1
              ? units[1]
              : (units.isNotEmpty ? units.first : null),
          inputValue: '',
          resultValue: '',
          clearUnits: units.isEmpty,
        );
      } else {
        state = state.copyWith(
          category: category,
          inputValue: '',
          resultValue: '',
          clearUnits: true,
        );
      }
    } else {
      state = state.copyWith(
        category: category,
        fromUnit: category.units.isNotEmpty ? category.units.first : null,
        toUnit: category.units.length > 1
            ? category.units[1]
            : (category.units.isNotEmpty ? category.units.first : null),
        inputValue: '',
        resultValue: '',
        discountPercentage: '',
        gstPercentage: '',
        bmiHeight: '',
        bmiWeight: '',
        clearUnits: category.units.isEmpty,
      );
    }
  }

  /// Sets the unit to convert from.
  void setFromUnit(FfiUnit unit) {
    state = state.copyWith(fromUnit: unit);
    _calculateResult();
  }

  /// Sets the unit to convert to.
  void setToUnit(FfiUnit unit) {
    state = state.copyWith(toUnit: unit);
    _calculateResult();
  }

  /// Swaps the "from" and "to" units.
  void swapUnits() {
    final temp = state.fromUnit;
    state = state.copyWith(fromUnit: state.toUnit, toUnit: temp);
    _calculateResult();
  }

  /// Appends a digit to the input value.
  void onDigit(String digit) {
    state = state.copyWith(inputValue: state.inputValue + digit);
    _calculateResult();
  }

  /// Deletes the last character from the input value.
  void onDelete() {
    if (state.inputValue.isNotEmpty) {
      state = state.copyWith(
        inputValue: state.inputValue.substring(0, state.inputValue.length - 1),
      );
      _calculateResult();
    }
  }

  /// Clears the input and result values.
  void onClear() {
    state = state.copyWith(inputValue: '', resultValue: '');
  }

  /// Appends a decimal point to the input value, if one doesn't already exist.
  void onDot() {
    if (!state.inputValue.contains('.')) {
      if (state.inputValue.isEmpty) {
        state = state.copyWith(inputValue: '0.');
      } else {
        state = state.copyWith(inputValue: '${state.inputValue}.');
      }
    }
  }

  // Setters for special fields
  void setDiscountPercentage(String val) {
    state = state.copyWith(discountPercentage: val);
    _calculateResult();
  }

  void setGstPercentage(String val) {
    state = state.copyWith(gstPercentage: val);
    _calculateResult();
  }

  void toggleAddGst() {
    state = state.copyWith(addGst: !state.addGst);
    _calculateResult();
  }

  void setBmiHeight(String val) {
    state = state.copyWith(bmiHeight: val);
    _calculateResult();
  }

  void setBmiWeight(String val) {
    state = state.copyWith(bmiWeight: val);
    _calculateResult();
  }

  void _calculateResult() {
    if (state.inputValue.isEmpty && state.category?.id != 'bmi') {
      state = state.copyWith(resultValue: '');
      return;
    }

    final catId = state.category?.id;
    if (catId == null) return;

    if (catId == 'currency') {
      final from = state.fromUnit?.id;
      final to = state.toUnit?.id;
      if (from != null &&
          to != null &&
          state.currencyRates.containsKey(from) &&
          state.currencyRates.containsKey(to)) {
        final val = double.tryParse(state.inputValue) ?? 0.0;
        final fromRate = state.currencyRates[from]!;
        final toRate = state.currencyRates[to]!;
        final res = val * (toRate / fromRate);
        state = state.copyWith(resultValue: _formatResult(res));
      }
      return;
    }

    if (catId == 'discount') {
      final price = double.tryParse(state.inputValue) ?? 0.0;
      final percent = double.tryParse(state.discountPercentage) ?? 0.0;
      final res = calculateDiscount(
        originalPrice: price,
        discountPercentage: percent,
      );
      state = state.copyWith(
        resultValue:
            'Final: ${_formatResult(res.finalPrice)} (Saved: ${_formatResult(res.amountSaved)})',
      );
      return;
    }

    if (catId == 'gst') {
      final amt = double.tryParse(state.inputValue) ?? 0.0;
      final percent = double.tryParse(state.gstPercentage) ?? 0.0;
      final res = calculateGst(
        amount: amt,
        gstPercentage: percent,
        addGst: state.addGst,
      );
      state = state.copyWith(
        resultValue:
            'Total: ${_formatResult(res.totalAmount)} (GST: ${_formatResult(res.gstAmount)})',
      );
      return;
    }

    if (catId == 'bmi') {
      final h = double.tryParse(state.bmiHeight) ?? 0.0;
      final w = double.tryParse(state.bmiWeight) ?? 0.0;
      final res = calculateBmi(
        weightKg: w,
        heightM: h / 100.0,
      ); // Assuming height input is in cm
      if (res.bmi > 0) {
        state = state.copyWith(
          resultValue: 'BMI: ${_formatResult(res.bmi)} - ${res.category}',
        );
      } else {
        state = state.copyWith(resultValue: '');
      }
      return;
    }

    if (catId == 'numeral') {
      // For numeral, we need fromBase and toBase based on units
      final fromBase = _getBaseFromUnit(state.fromUnit?.id);
      final toBase = _getBaseFromUnit(state.toUnit?.id);
      if (fromBase != null && toBase != null) {
        final res = convertNumeral(
          value: state.inputValue,
          fromBase: fromBase,
          toBase: toBase,
        );
        state = state.copyWith(resultValue: res ?? 'Invalid input');
      }
      return;
    }

    // Standard conversion
    final fromUnit = state.fromUnit;
    final toUnit = state.toUnit;
    if (fromUnit != null && toUnit != null) {
      final val = double.tryParse(state.inputValue);
      if (val != null) {
        final res = convertStandard(
          value: val,
          fromUnit: fromUnit,
          toUnit: toUnit,
        );
        state = state.copyWith(resultValue: _formatResult(res));
      } else {
        state = state.copyWith(resultValue: '');
      }
    }
  }

  String _formatResult(double val) {
    String s = val.toStringAsFixed(6);
    if (s.contains('.')) {
      s = s.replaceAll(RegExp(r'0*$'), '');
      if (s.endsWith('.')) {
        s = s.substring(0, s.length - 1);
      }
    }
    return s;
  }

  int? _getBaseFromUnit(String? id) {
    switch (id) {
      case 'dec':
        return 10;
      case 'bin':
        return 2;
      case 'oct':
        return 8;
      case 'hex':
        return 16;
      default:
        return null;
    }
  }
}

/// The global provider for the `ConverterNotifier`.
final converterProvider = NotifierProvider<ConverterNotifier, ConverterState>(
  () {
    return ConverterNotifier();
  },
);
