import 'package:flutter/material.dart';
import 'package:geomath/helpers/color_constant.dart';
import 'package:geomath/views/widget/app_bar.dart';

import '../../../../helpers/text_constant.dart';

class LearnWithARPage extends StatelessWidget {
  static const routeName = 'learn_with_ar';
  const LearnWithARPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: TextConstant.learnWithAr,
      ),
      body: SafeArea(
        child: Column(children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            child: TextFormField(
              style: const TextStyle(),
              onTap: () {
              },
              decoration: const InputDecoration(hintText: "Search Client"),
            ),
          )
        ]),
      ),
      backgroundColor: ColorConstant.primaryColor,
    );
  }
}

class ListItems extends StatelessWidget {
  const ListItems({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ListView(
          padding: const EdgeInsets.all(8),
          children: [
            TextFormField(
              decoration: const InputDecoration(hintText: "search"),
            )
          ],
        ),
      ),
    );
  }
}
