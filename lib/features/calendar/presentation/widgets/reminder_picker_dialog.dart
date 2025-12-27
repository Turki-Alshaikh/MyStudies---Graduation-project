import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/app_snackbar.dart';

import '../../../../core/constants/app_spacing.dart';
class ReminderPickerDialog extends StatefulWidget {
  const ReminderPickerDialog({Key? key}) : super(key: key);
  @override
  State<ReminderPickerDialog> createState() => _ReminderPickerDialogState();
}

class _ReminderPickerDialogState extends State<ReminderPickerDialog> {
  static const durationsMap = {
    '1 day': Duration(days: 1),
    '1 hour': Duration(hours: 1),
    '10 min': Duration(minutes: 10),
  };
  String? selectedKey = '1 day';
  bool customMode = false;
  int customValue = 10;
  String unit = 'minutes';
  final customController = TextEditingController(text: '10');

  @override
  void dispose() {
    customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: const Text('Remind me before event'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CupertinoSlidingSegmentedControl<String>(
            groupValue: customMode ? null : selectedKey,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.onSurface.withOpacity(0.07),
            thumbColor: Theme.of(context).colorScheme.surfaceVariant,
            children: {
              for (final label in durationsMap.keys)
                label: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 9,
                    horizontal: 16,
                  ),
                  child: Text(label),
                ),
            },
            onValueChanged: (v) {
              setState(() {
                selectedKey = v;
                customMode = false;
              });
            },
          ),
          AppSpacing.verticalSpaceMD,
          OutlinedButton(
            onPressed: () {
              setState(() => customMode = !customMode);
            },
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLG - 2),
              ),
              side: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 1.2,
              ),
            ),
            child: Text(
              'Custom...',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (customMode) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: customController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Value'),
                    onChanged: (v) {
                      setState(() {
                        customValue = int.tryParse(v) ?? 1;
                      });
                    },
                  ),
                ),
                AppSpacing.horizontalSpaceSM,
                PopupMenuButton<String>(
                  initialValue: unit,
                  onSelected: (u) => setState(() => unit = u),
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'minutes', child: Text('min')),
                    PopupMenuItem(value: 'hours', child: Text('hour')),
                    PopupMenuItem(value: 'days', child: Text('day')),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).dividerColor.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          unit == 'minutes'
                              ? 'min'
                              : unit == 'hours'
                                  ? 'hour'
                                  : 'day',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_drop_down_rounded,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ],
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Theme.of(context).cardColor,
                  elevation: 4,
                ),
              ],
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.md - 2),
            ),
          ),
          onPressed: () {
            Duration? d;
            if (customMode) {
              if (customValue <= 0) {
                AppSnackBars.showError(
                  context,
                  'Enter a value greater than zero for your reminder.',
                );
                return;
              }
              switch (unit) {
                case 'minutes':
                  d = Duration(minutes: customValue);
                  break;
                case 'hours':
                  d = Duration(hours: customValue);
                  break;
                case 'days':
                  d = Duration(days: customValue);
                  break;
                default:
                  d = Duration(minutes: customValue);
              }
            } else {
              d = durationsMap[selectedKey!]!;
            }
            Navigator.pop(context, d);
          },
          child: const Text('Set'),
        ),
      ],
    );
  }
}
