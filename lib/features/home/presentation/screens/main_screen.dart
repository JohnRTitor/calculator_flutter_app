import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:calculator_flutter_app/core/theme/ui_style.dart';
import 'package:calculator_flutter_app/features/calculator/presentation/screens/calculator_screen.dart';
import 'package:calculator_flutter_app/features/converter/presentation/screens/converter_home_screen.dart';
import 'package:calculator_flutter_app/features/history/presentation/screens/history_screen.dart';
import 'package:calculator_flutter_app/features/settings/presentation/screens/settings_screen.dart';
import 'package:calculator_flutter_app/features/settings/providers/theme_provider.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uiStyle = ref.watch(uiStyleProvider);
    final themeMode = ref.watch(themeModeProvider);

    if (uiStyle == UiStyle.liquidGlass) {
      return _buildGlassLayout(context, themeMode);
    }
    return _buildMaterialLayout(context);
  }

  Widget _buildMaterialLayout(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildTopBar(colorScheme, textTheme),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  CalculatorScreen(),
                  ConverterHomeScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassLayout(BuildContext context, AppThemeMode themeMode) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final brightness = Theme.of(context).brightness;

    return GlassScaffold(
      background: _buildGlassBackground(colorScheme, brightness, themeMode),
      statusBarStyle: GlassStatusBarStyle.auto,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildTopBar(colorScheme, textTheme),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  CalculatorScreen(),
                  ConverterHomeScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Dynamic gradient background for glass refraction.
  /// Adapts to theme mode and color scheme.
  Widget _buildGlassBackground(ColorScheme colorScheme, Brightness brightness, AppThemeMode themeMode) {
    final List<Color> gradientColors;

    if (themeMode == AppThemeMode.amoled) {
      // AMOLED: pure black with very subtle accent hints
      gradientColors = [
        Colors.black,
        colorScheme.primaryContainer.withValues(alpha: 0.06),
        Colors.black,
      ];
    } else if (brightness == Brightness.dark) {
      // Dark: deep dark with subtle color accents
      gradientColors = [
        colorScheme.surface,
        colorScheme.primaryContainer.withValues(alpha: 0.15),
        colorScheme.tertiaryContainer.withValues(alpha: 0.08),
        colorScheme.surface,
      ];
    } else {
      // Light: soft gradient with pastel tints
      gradientColors = [
        colorScheme.surface,
        colorScheme.primaryContainer.withValues(alpha: 0.3),
        colorScheme.tertiaryContainer.withValues(alpha: 0.2),
        colorScheme.surface,
      ];
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
      ),
    );
  }

  Widget _buildTopBar(ColorScheme colorScheme, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: SizedBox(
        height: 40,
        child: Row(
          children: [
            // History Icon
            IconButton(
              icon: const Icon(Icons.history, size: 22),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
              tooltip: 'History',
              color: colorScheme.onSurfaceVariant,
            ),
            
            const Spacer(),
            
            // TabBar
            SizedBox(
              width: 200,
              child: TabBar(
                controller: _tabController,
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.label,
                indicatorWeight: 3.0,
                indicatorColor: colorScheme.primary,
                labelColor: colorScheme.onSurface,
                unselectedLabelColor: colorScheme.onSurfaceVariant,
                labelStyle: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                unselectedLabelStyle: textTheme.titleSmall,
                tabs: const [
                  Tab(text: 'Calculator'),
                  Tab(text: 'Converter'),
                ],
              ),
            ),

            const Spacer(),

            // More Menu
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, size: 22, color: colorScheme.onSurfaceVariant),
              tooltip: 'More options',
              onSelected: (value) {
                if (value == 'settings') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'settings', child: Text('Settings')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
