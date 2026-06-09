import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import '../pages/analysis_page.dart' show ChartViewType;
import '../controllers/analysis_controller.dart';

class ChartTypeToggle extends StatelessWidget {
  final ChartViewType type;
  final IconData icon;
  final ValueNotifier<ChartViewType> chartTypeNotifier;

  const ChartTypeToggle({
    super.key,
    required this.type,
    required this.icon,
    required this.chartTypeNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ChartViewType>(
      valueListenable: chartTypeNotifier,
      builder: (context, currentType, _) {
        final isSelected = currentType == type;
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            chartTypeNotifier.value = type;
          },
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(18),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withAlpha(76),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : Colors.white.withAlpha(128),
            ),
          ),
        );
      },
    );
  }
}

class TimeFilterSelector extends StatelessWidget {
  final AnalysisController controller;

  const TimeFilterSelector({super.key, required this.controller});

  String _formatMonth(BuildContext context, DateTime date) {
    final months = [
      '',
      context.l10n.january,
      context.l10n.february,
      context.l10n.march,
      context.l10n.april,
      context.l10n.may,
      context.l10n.june,
      context.l10n.july,
      context.l10n.august,
      context.l10n.september,
      context.l10n.october,
      context.l10n.november,
      context.l10n.december,
    ];
    return '${months[date.month]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 0.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (controller.historyLimit == -1)
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.white),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    final current = controller.selectedMonth;
                    controller.setSelectedMonth(
                      DateTime(current.year, current.month - 1),
                    );
                  },
                ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surface.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: controller.historyLimit,
                      isDense: true,
                      isExpanded: true,
                      dropdownColor: Theme.of(context).colorScheme.surface,
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 7,
                          child: Text(
                            context.l10n.thisWeek,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 30,
                          child: Text(
                            context.l10n.thisMonth,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 90,
                          child: Text(
                            context.l10n.last3Months,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 180,
                          child: Text(
                            context.l10n.last6Months,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 366,
                          child: Text(
                            context.l10n.thisYear,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 365,
                          child: Text(
                            context.l10n.last1Year,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DropdownMenuItem(
                          value: -1,
                          child: Text(
                            controller.historyLimit == -1
                                ? _formatMonth(
                                    context,
                                    controller.selectedMonth,
                                  )
                                : context.l10n.selectMonth,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          controller.setHistoryLimit(value);
                        }
                      },
                      selectedItemBuilder: (BuildContext context) {
                        return [7, 30, 90, 180, 366, 365, -1].map<Widget>((
                          int item,
                        ) {
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              item == -1
                                  ? _formatMonth(
                                      context,
                                      controller.selectedMonth,
                                    )
                                  : [
                                      context.l10n.thisWeek,
                                      context.l10n.thisMonth,
                                      context.l10n.last3Months,
                                      context.l10n.last6Months,
                                      context.l10n.thisYear,
                                      context.l10n.last1Year,
                                      "",
                                    ][[
                                      7,
                                      30,
                                      90,
                                      180,
                                      366,
                                      365,
                                      -1,
                                    ].indexOf(item)],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
              if (controller.historyLimit == -1)
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.white),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    final current = controller.selectedMonth;
                    controller.setSelectedMonth(
                      DateTime(current.year, current.month + 1),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
