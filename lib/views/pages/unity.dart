import 'package:flutter/material.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import 'package:geomath/helpers/color_constant.dart';
import 'package:geomath/views/widget/app_bar.dart';

class UnityPage extends StatefulWidget {
  static const routeName = 'unity';
  const UnityPage({super.key});

  @override
  State<UnityPage> createState() => _UnityPageState();
}

class _UnityPageState extends State<UnityPage> {
  static final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();
  UnityWidgetController? _unityWidgetController;

  void onUnityCreated(controller) async {
    _unityWidgetController = await controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        backgroundColor: ColorConstant.primaryColor,
        title: 'Learn with AR',
      ),
      key: _scaffoldKey,
      body: WillPopScope(
        onWillPop: () async {
          // Handle Android back button press
          // Return true to allow back navigation, false to prevent it
          return true; // Adjust as per your requirement
        },
        child: UnityWidget(
          onUnityCreated: onUnityCreated,
          fullscreen: false,
          useAndroidViewSurface: true,
        ),
      ),
    );
  }
}
