import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:geomath/helpers/text_constant.dart';

class CustomCalculatorDropdownButton extends StatefulWidget {
  final String hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final List<String> items;
  final String? defaultItem;
  final Function(String)? onItemSelected;
  const CustomCalculatorDropdownButton(
      {Key? key,
      required this.hintText,
      this.prefixIcon,
      this.suffixIcon,
      required this.items,
      this.defaultItem,
      this.onItemSelected})
      : super(key: key);

  @override
  State<CustomCalculatorDropdownButton> createState() =>
      _CustomDropdownButtonState();
}

class _CustomDropdownButtonState extends State<CustomCalculatorDropdownButton> {
  String? selectedValue;
  final TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final items = widget.items;

    return Padding(
      padding: const EdgeInsets.only(left: 12.0),
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          if (widget.prefixIcon != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Icon(widget.prefixIcon),
            ),
          DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
            hint: Text(widget.hintText),
            items: items
                .map((item) => DropdownMenuItem(
                      value: item,
                      child: Text(
                        item,
                        style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w500),
                      ),
                    ))
                .toList(),
            value: widget.defaultItem ?? selectedValue,
            onChanged: (newValue) {
              setState(() {
                selectedValue = newValue;
                if (widget.onItemSelected != null) {
                  widget.onItemSelected!(newValue!);
                }
              });
            },
            buttonStyleData: ButtonStyleData(
              padding: const EdgeInsets.only(left: 20),
              height: 40,
              width: MediaQuery.of(context).size.width * 0.5,
              decoration: BoxDecoration(
                border: Border.all(
                    color: Theme.of(context).colorScheme.onSurface, width: 0.5),
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            dropdownStyleData: DropdownStyleData(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                direction: DropdownDirection.left,
                maxHeight: 200,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                )),
            dropdownSearchData: DropdownSearchData(
              searchController: textEditingController,
              searchInnerWidgetHeight: 50,
              searchInnerWidget: Container(
                height: 50,
                padding: const EdgeInsets.only(
                  top: 8,
                  bottom: 4,
                  right: 8,
                  left: 8,
                ),
                child: TextFormField(
                  expands: true,
                  maxLines: null,
                  controller: textEditingController,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    hintText: TextConstant.search,
                    hintStyle: const TextStyle(fontSize: 14),
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              searchMatchFn: (item, searchValue) {
                return item.value
                    .toString()
                    .toLowerCase()
                    .contains(searchValue.toLowerCase());
              },
            ),
            onMenuStateChange: (isOpen) {
              if (!isOpen) {
                textEditingController.clear();
              }
            },
          )),
        ],
      ),
    );
  }
}
