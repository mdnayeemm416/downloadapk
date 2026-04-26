import 'package:adnetwork/config/theme/styles_manager.dart';
import 'package:flutter/material.dart';

/// A reusable segmented option selector widget.
/// Works for gender, categories, or any small set of options.
class OptionSelector<T> extends StatelessWidget {
  final String? label;
  final List<T> options;
  final T? selectedOption;
  final String Function(T) labelBuilder;
  final IconData Function(T)? iconBuilder;
  final ValueChanged<T> onSelected;

  const OptionSelector({
    super.key,
    this.label,
    required this.options,
    required this.selectedOption,
    required this.labelBuilder,
    this.iconBuilder,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: getMediumStyle(
              fontSize: 13,
              color: colorScheme.onSurface.withValues(alpha: .8),
            ),
          ),
          const SizedBox(height: 8),
        ],
        Row(
          children: options.map((option) {
            final isSelected = option == selectedOption;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: option != options.last ? 10 : 0,
                ),
                child: GestureDetector(
                  onTap: () => onSelected(option),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? colorScheme.primary
                            : theme.dividerColor,
                        width: 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: colorScheme.primary.withValues(alpha: .25),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : [],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (iconBuilder != null) ...[
                          Icon(
                            iconBuilder!(option),
                            size: 18,
                            color: isSelected
                                ? colorScheme.onPrimary
                                : colorScheme.onSurface.withValues(alpha: .6),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          labelBuilder(option),
                          style: getMediumStyle(
                            fontSize: 13,
                            color: isSelected
                                ? colorScheme.onPrimary
                                : colorScheme.onSurface.withValues(alpha: .7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
