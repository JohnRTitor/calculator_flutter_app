import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calculator_flutter_app/generated/rust/bridge/converter.dart';
import 'package:calculator_flutter_app/features/converter/presentation/providers/converter_provider.dart';
import 'package:calculator_flutter_app/features/converter/presentation/screens/converter_detail_screen.dart';
import 'package:calculator_flutter_app/features/settings/presentation/providers/theme_provider.dart';
import 'package:calculator_flutter_app/app/theme/ui_style.dart';
import 'package:calculator_flutter_app/shared/widgets/glass_utils.dart';
import 'package:calculator_flutter_app/app/navigation/route_transitions.dart';

class ConverterHomeScreen extends ConsumerStatefulWidget {
  const ConverterHomeScreen({super.key});

  @override
  ConsumerState<ConverterHomeScreen> createState() =>
      _ConverterHomeScreenState();
}

class _ConverterHomeScreenState extends ConsumerState<ConverterHomeScreen> {
  List<FfiConverterCategory>? categories;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() {
    final cats = getConverterCategories();
    if (mounted) {
      setState(() {
        categories = cats;
      });
    }
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'straighten':
        return Icons.straighten;
      case 'texture':
        return Icons.texture;
      case 'scale':
        return Icons.scale;
      case 'water_drop':
        return Icons.water_drop;
      case 'thermostat':
        return Icons.thermostat;
      case 'speed':
        return Icons.speed;
      case 'schedule':
        return Icons.schedule;
      case 'storage':
        return Icons.storage;
      case 'pin':
        return Icons.pin;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (categories == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final uiStyle = ref.watch(uiStyleProvider);

    // Add extra items to match user request (Discount, GST, BMI, Currency)
    // We'll create custom FfiConverterCategory objects for them since they are specialized
    final displayCategories = [
      FfiConverterCategory(
        id: 'currency',
        name: 'Currency',
        iconName: 'currency_exchange',
        units: [],
      ),
      ...categories!,
      FfiConverterCategory(
        id: 'discount',
        name: 'Discount',
        iconName: 'local_offer',
        units: [],
      ),
      FfiConverterCategory(
        id: 'gst',
        name: 'GST',
        iconName: 'receipt_long',
        units: [],
      ),
      FfiConverterCategory(
        id: 'bmi',
        name: 'BMI',
        iconName: 'monitor_weight',
        units: [],
      ),
    ];

    return Scaffold(
      body: GridView.builder(
        padding: const EdgeInsets.all(24.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 24.0,
          childAspectRatio: 0.8,
        ),
        itemCount: displayCategories.length,
        itemBuilder: (context, index) {
          final cat = displayCategories[index];
          IconData iconData = _getIcon(cat.iconName);
          if (cat.id == 'currency') iconData = Icons.currency_exchange;
          if (cat.id == 'discount') iconData = Icons.local_offer;
          if (cat.id == 'gst') iconData = Icons.receipt_long;
          if (cat.id == 'bmi') iconData = Icons.monitor_weight;

          return SharedSurface(
            uiStyle: uiStyle,
            onTap: () {
              ref.read(converterProvider.notifier).setCategory(cat);
              Navigator.push(
                context,
                FadePageRoute(page: const ConverterDetailScreen()),
              );
            },
            borderRadius: BorderRadius.circular(24.0),
            isInteractive: true,
            glassRole: GlassSurfaceRole.card,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: uiStyle == UiStyle.liquidGlass
                        ? Theme.of(
                            context,
                          ).colorScheme.primaryContainer.withValues(alpha: 0.12)
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    iconData,
                    size: 32,
                    color: uiStyle == UiStyle.liquidGlass
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  cat.name,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
