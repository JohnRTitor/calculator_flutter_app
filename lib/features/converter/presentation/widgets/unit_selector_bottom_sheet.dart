import 'package:flutter/material.dart';
import 'package:calculator_flutter_app/src/rust/api/converter_api.dart';

class UnitSelectorBottomSheet extends StatefulWidget {
  final List<FfiUnit> units;
  final FfiUnit? selectedUnit;
  final Function(FfiUnit) onSelect;

  const UnitSelectorBottomSheet({
    super.key,
    required this.units,
    required this.selectedUnit,
    required this.onSelect,
  });

  @override
  State<UnitSelectorBottomSheet> createState() => _UnitSelectorBottomSheetState();
}

class _UnitSelectorBottomSheetState extends State<UnitSelectorBottomSheet> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredUnits = widget.units.where((u) {
      final query = _searchQuery.toLowerCase();
      return u.name.toLowerCase().contains(query) || u.symbol.toLowerCase().contains(query) || u.id.toLowerCase().contains(query);
    }).toList();

    return Container(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search units',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ListView.builder(
              itemCount: filteredUnits.length,
              itemBuilder: (context, index) {
                final unit = filteredUnits[index];
                final isSelected = widget.selectedUnit?.id == unit.id;
                
                return ListTile(
                  title: Text(unit.name),
                  subtitle: Text(unit.symbol),
                  trailing: isSelected ? const Icon(Icons.check) : null,
                  selected: isSelected,
                  onTap: () {
                    widget.onSelect(unit);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
