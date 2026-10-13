import 'package:flutter/material.dart';
import 'package:flyx/core/theme/app_dimensions.dart';
import 'package:flyx/core/theme/app_theme.dart';
import 'package:flyx/features/shared/widgets/empty_state.dart';
import 'package:hugeicons/hugeicons.dart';


enum TransferHistoryFilter {
  all('All'),
  sent('Sent'),
  received('Received'),
  incomplete('Incomplete');

  final String label;
  const TransferHistoryFilter(this.label);
}

class TransferScreen extends StatelessWidget {
  const TransferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpace.screenV,
          horizontal: AppSpace.screenH,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Transfers",style:context.textTheme.titleLarge),
            SizedBox(height:AppSpace.gap),
            TransferHistoryFilterBar(
              selected: TransferHistoryFilter.all,
              onChanged: (filter) {
                
              },
            ),

            SizedBox(height: AppSpace.section),
            SizedBox(height: AppSpace.section),

            TransferHistoryTable(),
            
          ],
        ),
      ),
    );
  }
}

class TransferHistoryFilterBar extends StatefulWidget {
  const TransferHistoryFilterBar({
    super.key,
    required this.selected,
    required this.onChanged,
  });


  final TransferHistoryFilter selected;
  final ValueChanged<TransferHistoryFilter> onChanged;

  @override
  State<TransferHistoryFilterBar> createState() => _TransferHistoryFilterBarState();
}

class _TransferHistoryFilterBarState extends State<TransferHistoryFilterBar> {
  
  late TransferHistoryFilter _selected;

  
  @override
  void initState() {
    _selected = widget.selected;
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: TransferHistoryFilter.values.map((value) {
          final isSelected= value == _selected;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selected = value;
              });
              widget.onChanged(value);
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: AppSpace.row),
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: AppRadius.icon,
                color: isSelected ? context.colorScheme.primary : context.colorScheme.surfaceContainer,
                border: Border.all(
                  color: isSelected ? context.colorScheme.primary : context.colorScheme.outlineVariant,
                ),
              ),
              child: Text(value.label,style: TextStyle(color: isSelected ? context.colorScheme.onPrimary : null),),
            ),
          );
        }).toList(),
      ),
    );
  }
}


class TransferHistoryTable extends StatelessWidget {
  const TransferHistoryTable({super.key});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      title: 'No transfers found',
      subtitle: 'No transfers found for the selected filter',
      icon: HugeIcons.strokeRoundedHistory,
    ) ;
  }
}