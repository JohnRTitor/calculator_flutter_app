import 'package:flutter/material.dart';
import 'package:calculator_flutter_app/app/theme/ui_style.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calculator_flutter_app/features/calculator/presentation/screens/calculator_screen.dart';
import 'package:calculator_flutter_app/features/converter/presentation/screens/converter_home_screen.dart';
import 'package:calculator_flutter_app/features/currency/presentation/screens/currency_home_screen.dart';
import 'package:calculator_flutter_app/features/history/presentation/screens/history_screen.dart';
import 'package:calculator_flutter_app/features/settings/presentation/screens/settings_screen.dart';
import 'package:calculator_flutter_app/features/settings/presentation/providers/theme_provider.dart';
import 'package:calculator_flutter_app/shared/widgets/glass_utils.dart';
import 'package:calculator_flutter_app/app/navigation/route_transitions.dart';

/// The primary navigation scaffold of the application.
///
/// Contains a top tab bar to switch between the Calculator and Converter screens,
/// and provides access to the History and Settings screens.
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
    _tabController = TabController(length: 3, vsync: this);
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
                children: [
                  const CalculatorScreen(),
                  const ConverterHomeScreen(),
                  const CurrencyHomeScreen(),
                ],
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
            isGlass
                ? SharedSurface(
                    uiStyle: uiStyle,
                    glassRole: GlassSurfaceRole.button,
                    frosted: true,
                    borderRadius: BorderRadius.circular(24),
                    child: IconButton(
                      icon: const Icon(Icons.history, size: 22),
                      onPressed: () => Navigator.push(
                        context,
                        FadePageRoute(page: const HistoryScreen()),
                      ),
                      tooltip: 'History',
                      color: glassCard.foregroundColor,
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.history, size: 22),
                    onPressed: () => Navigator.push(
                      context,
                      FadePageRoute(page: const HistoryScreen()),
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
              frosted: true,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: SizedBox(
                width: 200,
                height: 36,
                child: TabBar(
                  controller: _tabController,
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: isGlass ? null : colorScheme.primary,
                    border: isGlass
                        ? Border.all(
                            color: glassPrimary.borderColor,
                            width: 1.0,
                          )
                        : null,
                    boxShadow: isGlass ? glassPrimary.shadows : null,
                    gradient: isGlass
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color.lerp(
                                glassPrimary.fillColor,
                                Colors.white,
                                brightness == Brightness.light ? 0.2 : 0.1,
                              )!,
                              glassPrimary.fillColor,
                              Color.lerp(
                                glassPrimary.fillColor,
                                Colors.black,
                                brightness == Brightness.light ? 0.05 : 0.15,
                              )!,
                            ],
                            stops: const [0.0, 0.4, 1.0],
                          )
                        : null,
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
                    Tab(icon: Icon(Icons.calculate_outlined, size: 20)),
                    Tab(icon: Icon(Icons.swap_horiz_outlined, size: 20)),
                    Tab(icon: Icon(Icons.attach_money_outlined, size: 20)),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // More Menu
            isGlass
                ? SharedSurface(
                    uiStyle: uiStyle,
                    glassRole: GlassSurfaceRole.button,
                    frosted: true,
                    borderRadius: BorderRadius.circular(24),
                    child: PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        size: 22,
                        color: glassCard.foregroundColor,
                      ),
                      tooltip: 'More options',
                      onSelected: (value) {
                        if (value == 'settings') {
                          Navigator.push(
                            context,
                            FadePageRoute(page: const SettingsScreen()),
                          );
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'settings',
                          child: Text('Settings'),
                        ),
                      ],
                    ),
                  )
                : PopupMenuButton<String>(
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
                          FadePageRoute(page: const SettingsScreen()),
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'settings',
                        child: Text('Settings'),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
