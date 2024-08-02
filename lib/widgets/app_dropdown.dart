import 'package:flutter/material.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';

class AppDropdown<T> extends FormField<T> {
  AppDropdown({
    super.key,
    required this.label,
    required this.hint,
    this.isRequired = false,
    T? value,
    required this.itemList,
    required this.onChanged,
    required this.itemBuilder,
    this.isSearch,
    super.validator,
  }) : super(
          initialValue: value,
          builder: (FormFieldState<T> state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w400)),
                    const SizedBox(
                      width: 4,
                    ),
                    isRequired == true
                        ? const Text(
                            "*",
                            style: TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          )
                        : Container()
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(0),
                      margin: const EdgeInsets.only(top: 0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: state.hasError
                              ? Colors.redAccent
                              : Colors.black54.withOpacity(0.5),
                          width: 1,
                        ),
                        borderRadius:
                            BorderRadius.circular(3),
                      ),
                      child: isSearch == true
                          ? CustomDropdown.search(
                              decoration: const CustomDropdownDecoration(
                                  hintStyle: TextStyle(
                                      fontWeight: FontWeight.w200,
                                      color: Colors.black54)),
                              hintText: hint,
                              items: itemList
                                  .map((item) => item.toString())
                                  .toList(),
                              onChanged: (newValue) {
                                final selectedItem = itemList.firstWhere(
                                    (item) => item.toString() == newValue);
                                state.didChange(selectedItem);
                                onChanged(selectedItem);
                              },
                            )
                          : CustomDropdown(
                              decoration: const CustomDropdownDecoration(
                                  hintStyle: TextStyle(
                                      fontWeight: FontWeight.w200,
                                      color: Colors.black54)),
                              hintText: hint,
                              items: itemList
                                  .map((item) => item.toString())
                                  .toList(),
                              onChanged: (newValue) {
                                final selectedItem = itemList.firstWhere(
                                    (item) => item.toString() == newValue);
                                state.didChange(selectedItem);
                                onChanged(selectedItem);
                              },
                            ),
                    ),
                  ],
                ),
                if (state.hasError)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      state.errorText!,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            );
          },
        );

  final String label, hint;
  final bool isRequired;
  final bool? isSearch;
  final List<T> itemList;
  final void Function(T?) onChanged;
  final DropdownMenuItem<T> Function(T item) itemBuilder;
}
