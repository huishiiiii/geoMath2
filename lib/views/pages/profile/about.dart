import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

class AboutPage extends StatefulWidget {
  static const routeName = 'about';
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  Future<String> _getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    print('package info: ${packageInfo.version}');
    return packageInfo.version;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text('About'),
      ),
      body: Center(
        child: FutureBuilder<String>(
          future: _getAppVersion(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text('Version: ${snapshot.data}');
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}
