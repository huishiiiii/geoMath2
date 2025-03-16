import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geomath/enum/user_enum.dart';
import 'package:geomath/helpers/asset_helper.dart';
import 'package:geomath/helpers/global.dart';
import 'package:geomath/helpers/theme_helper.dart';
import 'package:geomath/provider/theme_provider.dart';
import 'package:geomath/services/firebase_service.dart';
import 'package:geomath/views/pages/home/home_tab.dart';
import 'package:geomath/views/pages/note/manage_class_notes.dart';
import 'package:geomath/views/pages/note/manage_notes.dart';
import 'package:geomath/views/pages/quiz/manage_class_quiz.dart';
import 'package:geomath/views/pages/quiz/manage_quiz.dart';
import 'package:geomath/views/pages/setting/settings.dart';
import 'package:geomath/views/widget/bottom_navigation_bar.dart';
import 'package:geomath/views/widget/home_app_bar.dart';
import 'package:geomath/views/widget/button/pop_up_profile_button.dart';
import 'package:provider/provider.dart';

import '../../helpers/color_constant.dart';
import '../../helpers/text_constant.dart';
import 'note/note.dart';
import 'quiz/quiz.dart';

class HomePage extends StatefulWidget {
  static const routeName = 'home';
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseService firebaseService = FirebaseService();

  String firstName = '';
  String lastName = '';
  String role = '';
  String gender = '';
  String email = '';
  String? image;
  // List of image paths
  List<String> imagePaths = [
    AssetHelper.slideshow1,
    AssetHelper.slideshow2,
    AssetHelper.slideshow3,
  ];

  // Index of the current image being displayed
  int currentIndex = 0;

  Future<Map<String, dynamic>> fetchUserDetails(String uid) async {
    return await firebaseService.getUserDetails(uid);
  }

  Future<void> getUserDetails() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    Map<String, dynamic> userDetails = await fetchUserDetails(user!.uid);

    // Access user details
    setState(() {
      firstName = userDetails['firstname'];
      lastName = userDetails['lastname'];
      role = userDetails['role'];
      gender = userDetails['gender'];
      email = userDetails['email'];
      image = userDetails['profilePic'];
    });
  }

  int _pageIndex = 0;
  String classId = '';
  late List<int> _pageIndexStack = [0];

  void changeTabIndex(int index, String? className) {
    setState(() {
      _pageIndex = index;
      classId = className!;
    });
  }

  void addToPageIndexStack(int index) {
    // Check if the index is not already in the stack before adding
    if (_pageIndexStack.isEmpty || _pageIndexStack.last != index) {
      _pageIndexStack.add(index);
    }
  }

  void navigateToPage(BuildContext context, Widget page) async {
    final selectedTabIndex = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => page),
    );
    if (selectedTabIndex != null && selectedTabIndex is int) {
      setState(() {
        if (_pageIndexStack.isNotEmpty) {
          _pageIndexStack.removeLast(); // Remove the last index
        }
        _pageIndex = selectedTabIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    getUserDetails();
    addToPageIndexStack(_pageIndex);

    final List<Widget> tabList = [
      const HomeTabPage(),
      NotePage(
        onTabSelected: changeTabIndex,
      ),
      QuizPage(
        onTabSelected: changeTabIndex,
      ),
      const SettingTabPage(),
      Container(),
      ManageNotesTabPage(
        onTabSelected: changeTabIndex,
      ),
      ManageQuizzesTabPage(
        onTabSelected: changeTabIndex,
      ),
      Container(),
      Container(),
      ManageClassNotesTabPage(classId: classId),
      ManageClassQuizTabPage(classId: classId)
    ];

    Widget _buildSlideshowImage(String imagePath) {
      return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
      );
    }

    setScreenWidth(context);
    return WillPopScope(
      onWillPop: () async {
        if (_pageIndexStack.length > 1) {
          setState(() {
            _pageIndexStack.removeLast(); // Remove the current index
            _pageIndex =
                _pageIndexStack.last; // Set the page index to the previous one
          }); // Print the _pageIndexStack
          return false; // Prevent the default back button behavior
        } else {
          return true; // Allow the default back button behavior
        }
      },
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: const CustomHomeAppBar(),
          extendBodyBehindAppBar: false,
          body: role == RoleEnum.student.enumToString()
              ? Stack(
                  children: [
                    Center(
                      child: Column(children: [
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Ink(
                                  padding: const EdgeInsets.all(7),
                                  decoration: ShapeDecoration(
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                    shape: const CircleBorder(),
                                  ),
                                  child: Tooltip(
                                    message: Provider.of<ThemeProvider>(context)
                                                .themeData ==
                                            CustomThemeData.lightMode
                                        ? 'Turn On Dark Mode'
                                        : 'Turn On Light Mode',
                                    child: IconButton(
                                      onPressed: () {
                                        Provider.of<ThemeProvider>(context,
                                                listen: false)
                                            .toggleTheme();
                                      },
                                      icon: Icon(
                                        Provider.of<ThemeProvider>(context)
                                                    .themeData ==
                                                CustomThemeData.lightMode
                                            ? Icons.mode_night_outlined
                                            : Icons.wb_sunny_outlined,
                                        color: MaterialStateColor.resolveWith(
                                          (Set<MaterialState> states) {
                                            if (states.contains(
                                                MaterialState.focused)) {
                                              return Theme.of(context)
                                                  .colorScheme
                                                  .secondary;
                                            } else {
                                              return Theme.of(context)
                                                  .colorScheme
                                                  .onSurface;
                                            }
                                          },
                                        ),
                                      ),
                                      selectedIcon: const Icon(
                                          Icons.brightness_2_outlined),
                                    ),
                                  )),
                              PopUpProfileButton(gender: gender, image: image),
                            ],
                          ),
                        ),
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 40.0),
                              child: lastName.isEmpty
                                  ? const LinearProgressIndicator()
                                  : Text('Hi, $lastName',
                                      style: const TextStyle(fontSize: 30)),
                            )),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 20.0, horizontal: 40.0),
                              child: Text('Welcome to GeoMath',
                                  style: TextStyle(fontSize: 30))),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.075),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(40),
                                    topRight: Radius.circular(40))),
                            child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.08),
                                      tabList.elementAt(_pageIndex),
                                      SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.12),
                                    ],
                                  ),
                                )),
                          ),
                        )
                      ]),
                    ),
                    Align(
                      alignment: const Alignment(0.0, -0.4),
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: ClipRRect(
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.15,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: ColorConstant
                                      .blackColor!, // Adjust the color as needed
                                  width: 1.0, // Adjust the width of the border
                                ),
                              ),
                              child: CarouselSlider.builder(
                                itemCount: imagePaths.length,
                                itemBuilder: (BuildContext context, int index,
                                    int realIndex) {
                                  return _buildSlideshowImage(
                                      imagePaths[index]);
                                },
                                options: CarouselOptions(
                                  autoPlay: true,
                                  aspectRatio: 16 / 9,
                                  enlargeCenterPage: true,
                                  viewportFraction: 1.0,
                                  onPageChanged: (index, reason) {
                                    setState(() {
                                      currentIndex = index;
                                    });
                                  },
                                ),
                              ),
                            ),
                          )),
                    ),
                    CustomBottomNavigationBar(
                      currentIndex: _pageIndex,
                      onTabSelected: (index) {
                        setState(() {
                          _pageIndex = index;
                        });
                      },
                    )
                  ],
                )
              : Stack(
                  children: [
                    Center(
                      child: Column(children: [
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Ink(
                                  padding: const EdgeInsets.all(7),
                                  decoration: ShapeDecoration(
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                    shape: const CircleBorder(),
                                  ),
                                  child: Tooltip(
                                    message: Provider.of<ThemeProvider>(context)
                                                .themeData ==
                                            CustomThemeData.lightMode
                                        ? 'Turn On Dark Mode'
                                        : 'Turn On Light Mode',
                                    child: IconButton(
                                      onPressed: () {
                                        Provider.of<ThemeProvider>(context,
                                                listen: false)
                                            .toggleTheme();
                                      },
                                      icon: Icon(
                                        Provider.of<ThemeProvider>(context)
                                                    .themeData ==
                                                CustomThemeData.lightMode
                                            ? Icons.mode_night_outlined
                                            : Icons.wb_sunny_outlined,
                                        color: MaterialStateColor.resolveWith(
                                          (Set<MaterialState> states) {
                                            if (states.contains(
                                                MaterialState.focused)) {
                                              return Theme.of(context)
                                                  .colorScheme
                                                  .secondary;
                                            } else {
                                              return Theme.of(context)
                                                  .colorScheme
                                                  .onSurface;
                                            }
                                          },
                                        ),
                                      ),
                                      selectedIcon: const Icon(
                                          Icons.brightness_2_outlined),
                                    ),
                                  )),
                              PopUpProfileButton(gender: gender, image: image),
                            ],
                          ),
                        ),
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 40.0),
                              child: Text('Hi, $lastName',
                                  style: const TextStyle(fontSize: 30)),
                            )),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 20.0, horizontal: 40.0),
                              child: Text('Welcome to GeoMath',
                                  style: TextStyle(fontSize: 30))),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.075),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(40),
                                    topRight: Radius.circular(40))),
                            child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.08),
                                      tabList.elementAt(_pageIndex),
                                      SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.12),
                                    ],
                                  ),
                                )),
                          ),
                        )
                      ]),
                    ),
                    Align(
                      alignment: const Alignment(0.0, -0.4),
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(0),
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.15,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: ColorConstant
                                      .blackColor!, // Adjust the color as needed
                                  width: 1.0, // Adjust the width of the border
                                ),
                              ),
                              child: CarouselSlider.builder(
                                itemCount: imagePaths.length,
                                itemBuilder: (BuildContext context, int index,
                                    int realIndex) {
                                  return _buildSlideshowImage(
                                      imagePaths[index]);
                                },
                                options: CarouselOptions(
                                  autoPlay: true,
                                  aspectRatio: 16 / 9,
                                  enlargeCenterPage: true,
                                  viewportFraction: 1.0,
                                  onPageChanged: (index, reason) {
                                    setState(() {
                                      currentIndex = index;
                                    });
                                  },
                                ),
                              ),
                            ),
                          )),
                    ),
                    CustomBottomNavigationBar(
                      currentIndex: _pageIndex,
                      onTabSelected: (index) {
                        setState(() {
                          _pageIndex = index;
                        });
                      },
                    )
                  ],
                )),
    );
  }
}
