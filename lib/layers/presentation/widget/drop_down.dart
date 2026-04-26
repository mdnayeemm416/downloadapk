import 'package:adnetwork/config/theme/app_colors.dart';
import 'package:adnetwork/config/theme/styles_manager.dart';
import 'package:adnetwork/layers/presentation/widget/search_box.dart';
import 'package:flutter/material.dart';

class DropdownWidget<T> extends StatefulWidget {
  final T? selectedItem;
  final List<T> items;
  final double? width;
  final double? height;
  final Color? color;
  final Color? textColor;
  final Color? iconColor;
  final void Function(T) ontap;

  /// Converts item to string for display and filtering
  final String Function(T)? itemLabelBuilder;

  /// Optional custom widget builder for each dropdown item
  final Widget Function(BuildContext context, T item)? itemBuilder;

  // New validation properties
  final String? Function(String?)? validator;
  final String? hintText;
  final bool isRequired;
  final String? requiredErrorMessage;

  const DropdownWidget({
    super.key,
    required this.items,
    this.selectedItem,
    required this.ontap,
    this.color,
    this.textColor,
    this.iconColor,
    this.width,
    this.height,
    this.itemLabelBuilder,
    this.itemBuilder,

    // New parameters
    this.validator,
    this.hintText,
    this.isRequired = false,
    this.requiredErrorMessage = 'This field is required',
  });

  @override
  State<DropdownWidget<T>> createState() => _DropdownWidgetState<T>();
}

class _DropdownWidgetState<T> extends State<DropdownWidget<T>> {
  late T? selectedValue;
  late TextEditingController searchController;
  late List<T> filteredItems;
  final GlobalKey<FormFieldState> _formFieldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    selectedValue = widget.selectedItem;
    searchController = TextEditingController();
    filteredItems = List.from(widget.items);
  }

  // @override
  // void didUpdateWidget(covariant DropdownWidget<T> oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   if (widget.selectedItem != oldWidget.selectedItem) {
  //     selectedValue = widget.selectedItem;
  //     // Trigger validation when selected value changes
  //     _formFieldKey.currentState?.validate();
  //   }
  // }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  String getLabel(T item) {
    if (widget.itemLabelBuilder != null) {
      return widget.itemLabelBuilder!(item);
    }
    return item.toString();
  }

  String? _validateField(String? value) {
    // First check if it's required
    if (widget.isRequired && selectedValue == null) {
      return widget.requiredErrorMessage;
    }

    // Then use custom validator if provided
    if (widget.validator != null) {
      return widget.validator!(value);
    }

    return null;
  }

  void filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredItems = List.from(widget.items);
      } else {
        filteredItems = widget.items
            .where(
              (item) =>
                  getLabel(item).toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData currentTheme = Theme.of(context);
    final bool isDarkMode = currentTheme.brightness == Brightness.dark;

    return FormField<String>(
      key: _formFieldKey,
      validator: (value) => _validateField(value),
      builder: (formFieldState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MenuAnchor(
              alignmentOffset: const Offset(0, 0),
              builder: (context, controller, child) {
                return GestureDetector(
                  onTap: () {
                    if (controller.isOpen) {
                      controller.close();
                    } else {
                      searchController.clear();
                      filterItems('');
                      controller.open();
                    }
                  },
                  child: SizedBox(
                    width: widget.width,
                    height: widget.height,
                    child: TextFormField(
                      enabled: false,
                      controller: TextEditingController(
                        text: selectedValue != null
                            ? getLabel(selectedValue!)
                            : widget.hintText ?? "Select...",
                      ),
                      style: getRegularStyle(
                        color: Theme.of(context).colorScheme.tertiaryContainer,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.all(5),
                        suffixIcon: Icon(
                          Icons.keyboard_arrow_down_sharp,
                          size: 20,
                          color:
                              widget.iconColor ??
                              (!isDarkMode ? Colors.black45 : AppColors.cream),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(
                            color: formFieldState.hasError
                                ? Colors.red
                                : !isDarkMode
                                ? const Color.fromARGB(255, 233, 233, 233)
                                : const Color.fromARGB(255, 99, 99, 99),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(
                            color: formFieldState.hasError
                                ? Colors.red
                                : !isDarkMode
                                ? const Color.fromARGB(255, 233, 233, 233)
                                : const Color.fromARGB(255, 99, 99, 99),
                          ),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(
                            color: formFieldState.hasError
                                ? Colors.red
                                : !isDarkMode
                                ? const Color.fromARGB(255, 233, 233, 233)
                                : const Color.fromARGB(255, 99, 99, 99),
                          ),
                        ),
                        filled: true,
                        fillColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer,
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                  ),
                );
              },
              menuChildren: [
                if (widget.items.isNotEmpty)
                  SearchBox(
                    controller: searchController,
                    onChanged: filterItems,
                    onClear: () => filterItems(""),
                  ),
                Container(
                  width: widget.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Theme.of(context).colorScheme.primaryContainer,
                    border: Border.all(
                      color: !isDarkMode
                          ? const Color.fromARGB(255, 233, 233, 233)
                          : const Color.fromARGB(255, 99, 99, 99),
                    ),
                  ),
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: SingleChildScrollView(
                    primary: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: filteredItems.isNotEmpty
                          ? filteredItems.map((item) {
                              return Builder(
                                builder: (context) {
                                  final controller = MenuController.maybeOf(
                                    context,
                                  );
                                  return GestureDetector(
                                    onTap: () {
                                      widget.ontap(item);
                                      setState(() {
                                        selectedValue = item;
                                      });
                                      // Trigger validation after selection
                                      _formFieldKey.currentState?.validate();
                                      controller?.close();
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: widget.itemBuilder != null
                                          ? widget.itemBuilder!(context, item)
                                          : Text(
                                              getLabel(item),
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                    ),
                                  );
                                },
                              );
                            }).toList()
                          : [
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "No results found",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                    ),
                  ),
                ),
              ],
            ),

            // Error message
            if (formFieldState.hasError)
              Padding(
                padding: const EdgeInsets.only(left: 12.0, top: 4.0),
                child: Text(
                  formFieldState.errorText!,
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }
}
