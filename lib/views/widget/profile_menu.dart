import 'package:flutter/material.dart';
import 'package:geomath/helpers/text_constant.dart';

class ProfileMenu extends StatelessWidget {
  const ProfileMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.black),
      child: Column(children: [
        Container(
          height: 100,
          color: Colors.amber,
        ),
        ElevatedButton(onPressed: () {}, child: Text(TextConstant.userProfile)),
        ElevatedButton(onPressed: () {}, child: Text(TextConstant.userProfile)),
        ElevatedButton(onPressed: () {}, child: Text(TextConstant.userProfile))
      ]),
    );
  }
}
