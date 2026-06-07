import 'package:flutter/material.dart';
import 'package:calculator_flutter_app/app/theme/ui_style.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calculator_flutter_app/features/calculator/presentation/screens/calculator_screen.dart';
import 'package:calculator_flutter_app/features/converter/presentation/screens/converter_home_screen.dart';
import 'package:calculator_flutter_app/features/history/presentation/screens/history_screen.dart';
import 'package:calculator_flutter_app/features/settings/presentation/screens/settings_screen.dart';
import 'package:calculator_flutter_app/features/settings/presentation/providers/theme_provider.dart';
import 'package:calculator_flutter_app/shared/widgets/glass_utils.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen>
    with SingleTickerProviderStateMixin {
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

    if (uiStyle == UiStyle.liquidGlass) {
      return _buildGlassLayout(context, uiStyle);
    }
    return _buildMaterialLayout(context, uiStyle);
  }

  Widget _buildMaterialLayout(BuildContext context, UiStyle uiStyle) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildTopBar(colorScheme, textTheme, uiStyle),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [CalculatorScreen(), ConverterHomeScreen()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassLayout(BuildContext context, UiStyle uiStyle) {
    // Both styles now use the same Scaffold, but the global background handles the glass aesthetic
    return _buildMaterialLayout(context, uiStyle);
  }

  Widget _buildTopBar(
    ColorScheme colorScheme,
    TextTheme textTheme,
    UiStyle uiStyle,
  ) {
    final brightness = Theme.of(context).brightness;
    final isGlass = uiStyle == UiStyle.liquidGlass;
    final glassPrimary = resolveGlassStyle(
      colorScheme,
      brightness: brightness,
      role: GlassSurfaceRole.primary,
      isSelected: true,
    );
    final glassCard = resolveGlassStyle(
      colorScheme,
      brightness: brightness,
      role: GlassSurfaceRole.card,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: SizedBox(
        height: 40,
        child: Row(
          children: [
            // History Icon
            IconButton(
              icon: const Icon(Icons.history, size: 22),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              ),
              tooltip: 'History',
              color: colorScheme.onSurfaceVariant,
            ),

            const Spacer(),

            // TabBar (Pill Switcher)
            SharedSurface(
              uiStyle: uiStyle,
              borderRadius: BorderRadius.circular(24),
              glassRole: GlassSurfaceRole.card,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: SizedBox(
                width: 220,
                height: 36,
                child: TabBar(
                  controller: _tabController,
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: isGlass
                        ? glassPrimary.fillColor
                        : colorScheme.primary,
                    boxShadow: isGlass ? glassPrimary.shadows : null,
                  ),
                  labelColor: isGlass
                      ? glassPrimary.foregroundColor
                      : colorScheme.onPrimary,
                  unselectedLabelColor: isGlass
                      ? glassCard.foregroundColor.withValues(alpha: 0.72)
                      : colorScheme.onSurfaceVariant,
                  labelStyle: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  unselectedLabelStyle: textTheme.titleSmall,
                  splashBorderRadius: BorderRadius.circular(20),
                  tabs: const [
                    Tab(text: 'Calculator'),
                    Tab(text: 'Converter'),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // More Menu
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                size: 22,
                color: colorScheme.onSurfaceVariant,
              ),
              tooltip: 'More options',
              onSelected: (value) {
                if (value == 'settings') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
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
