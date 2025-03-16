import 'package:flutter/material.dart';
import 'package:geomath/helpers/text_constant.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  const CustomBottomNavigationBar(
      {super.key, required this.onTabSelected, required this.currentIndex});

  @override
  State<CustomBottomNavigationBar> createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  @override
  Widget build(BuildContext context) {
    int currentIndex = widget.currentIndex;

    if (widget.currentIndex >= 4) {
      currentIndex = widget.currentIndex % 4;
    }

    return Align(
      alignment: const Alignment(0.0, 0.85),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50.0),
        child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(30)),
            child: BottomNavigationBar(
              selectedItemColor: Theme.of(context).colorScheme.background,
              unselectedItemColor: Theme.of(context).colorScheme.tertiary,
              showSelectedLabels: true,
              showUnselectedLabels: false,
              currentIndex: currentIndex,
              onTap: widget.onTabSelected,
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.home_rounded), label: TextConstant.home),
                BottomNavigationBarItem(
                    icon: Icon(Icons.description_rounded),
                    label: TextConstant.note),
                BottomNavigationBarItem(
                    icon: Icon(Icons.quiz_rounded), label: TextConstant.quiz),
                BottomNavigationBarItem(
                    icon: Icon(Icons.settings_rounded),
                    label: TextConstant.setting),
              ],
            )),
      ),
    );
  }
}
