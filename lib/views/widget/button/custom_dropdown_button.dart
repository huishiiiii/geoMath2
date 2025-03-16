import 'package:flutter/material.dart';
import 'package:geomath/helpers/color_constant.dart';

class CustomDropdownButton extends StatefulWidget {
  final bool enabled;
  final String hintText;
  final double? height;
  final double? width;
  final BorderRadius? borderRadius;
  final IconData? prefixIcon;
  final List<String> items;
  final String? defaultItem;
  final void Function(String?)? onItemSelected;
  const CustomDropdownButton(
      {Key? key,
      this.enabled = true,
      required this.hintText,
      this.prefixIcon,
      required this.items,
      this.defaultItem,
      this.onItemSelected,
      this.height,
      this.borderRadius,
      this.width})
      : super(key: key);

  @override
  State<CustomDropdownButton> createState() => _CustomDropdownButtonState();
}

class _CustomDropdownButtonState extends State<CustomDropdownButton> {
  String? selectedValue;
  final TextEditingController controller = TextEditingController();
  bool isTextUnderlined = false;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.defaultItem;
    print('Note Model: ${widget.defaultItem}');
    if (selectedValue != null && widget.onItemSelected != null) {
      print('hello');
      widget.onItemSelected!(selectedValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (selectedValue == null) {
      setState(() {
        controller.clear();
      });
    }
    return Column(
      children: [
        Row(
          children: [
            DropdownMenu(
                menuHeight: 240,
                width: widget.width ?? MediaQuery.of(context).size.width - 60,
                controller: controller,
                enableFilter: true,
                enabled: widget.enabled ?? widget.items.isNotEmpty,
                requestFocusOnTap: widget.items.isEmpty ? false : true,
                leadingIcon: Icon(
                  widget.prefixIcon,
                  size: 18,
                ),
                trailingIcon: null,
                // (selectedValue == null || selectedValue!.isEmpty)
                //     ? const Icon(
                //         Icons.arrow_drop_down_rounded,
                //         opticalSize: 30,
                //       )
                //     : GestureDetector(
                //         onTap: () {
                //           setState(() {
                //             selectedValue = '';
                //             controller.clear();
                //             FocusManager.instance.primaryFocus?.unfocus();
                //           });
                //           widget.onItemSelected!(selectedValue);
                //         },
                //         child: const Icon(Icons.close),
                //       ),
                label: Text(
                  widget.hintText,
                ),
                initialSelection: widget.defaultItem,
                inputDecorationTheme: InputDecorationTheme(
                  focusColor: Theme.of(context).colorScheme.secondary,
                  focusedBorder: const UnderlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      borderSide: BorderSide(
                        color: ColorConstant.transparentColor,
                      )),
                  border: MaterialStateUnderlineInputBorder.resolveWith(
                      (Set<MaterialState> states) {
                    return const UnderlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        borderSide: BorderSide(
                          color: ColorConstant.transparentColor,
                        ));
                  }),
                  prefixIconColor: MaterialStateColor.resolveWith(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.focused)) {
                        return Theme.of(context).colorScheme.secondary;
                      } else {
                        return Theme.of(context)
                            .colorScheme
                            .onSecondaryContainer;
                      }
                    },
                  ),
                  suffixIconColor: MaterialStateColor.resolveWith(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.focused)) {
                        return Theme.of(context).colorScheme.secondary;
                      } else {
                        return Theme.of(context)
                            .colorScheme
                            .onSecondaryContainer;
                      }
                    },
                  ),
                  labelStyle: const TextStyle(
                      fontWeight: FontWeight.normal, fontSize: 16),
                  floatingLabelStyle: MaterialStateTextStyle.resolveWith(
                      (Set<MaterialState> states) {
                    if (states.contains(MaterialState.focused)) {
                      return TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary);
                    }
                    return TextStyle(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.normal,
                    );
                  }),
                  constraints: BoxConstraints(
                    maxHeight: widget.height ?? 45,
                  ),
                  fillColor: Theme.of(context).colorScheme.surface,
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 9.0),
                ),
                onSelected: (newValue) {
                  setState(() {
                    selectedValue = newValue;
                    FocusScope.of(context).unfocus();
                  });
                  widget.onItemSelected!(selectedValue);
                },
                dropdownMenuEntries: widget.items.map<DropdownMenuEntry>(
                  (item) {
                    return DropdownMenuEntry(
                      value: item,
                      label: item,
                      style: MenuItemButton.styleFrom(
                          // maximumSize: Size(200, 200),
                          foregroundColor:
                              Theme.of(context).colorScheme.secondary),
                    );
                  },
                ).toList()),
          ],
        ),
      ],
    );
  }
}
