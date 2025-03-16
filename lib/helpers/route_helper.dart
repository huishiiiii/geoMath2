import 'package:flutter/material.dart';
import 'package:geomath/views/pages/home/home_tab.dart';
import 'package:geomath/views/pages/note/add_new_note.dart';
import 'package:geomath/views/pages/note/update_note.dart';
import 'package:geomath/views/pages/note/view_note.dart';
import 'package:geomath/views/pages/profile/about.dart';
import 'package:geomath/views/pages/profile/edit_profile.dart';
import 'package:geomath/views/pages/quiz/add_new_quiz.dart';
import 'package:geomath/views/pages/quiz/question_page.dart';
import 'package:geomath/views/pages/quiz/update_quiz.dart';
import 'package:geomath/views/pages/quiz/view_quiz_page.dart';
import 'package:geomath/views/pages/register.dart';
import 'package:geomath/views/pages/home/learn_with_ar/learn_with_ar.dart';
import 'package:geomath/views/pages/note/note.dart';
import 'package:geomath/views/pages/setting/change_password.dart';
import 'package:geomath/views/pages/setting/settings.dart';
import 'package:geomath/views/pages/profile/user_profile.dart';
import 'package:geomath/views/pages/unity.dart';

import '../views/pages/login.dart';
import '../views/pages/home/calculator/calculator.dart';
import '../views/pages/home.dart';
import '../views/pages/progress/progress.dart';
import '../views/pages/quiz/quiz.dart';

class RouteHelper {
  static Route<dynamic> generateRoute(
      RouteSettings settings, BuildContext context) {
    switch (settings.name) {
      case HomePage.routeName:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case RegisterPage.routeName:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case LearnWithARPage.routeName:
        return MaterialPageRoute(builder: (_) => const LearnWithARPage());
      case NotePage.routeName:
        return MaterialPageRoute(builder: (_) => const NotePage());
      case UnityPage.routeName:
        return MaterialPageRoute(builder: (_) => const UnityPage());
      case ProgressPage.routeName:
        return MaterialPageRoute(builder: (_) => const ProgressPage(), settings: settings);
      case QuizPage.routeName:
        return MaterialPageRoute(builder: (_) => const QuizPage());
      case CalculatorPage.routeName:
        return MaterialPageRoute(builder: (_) => const CalculatorPage());
      case SettingTabPage.routeName:
        return MaterialPageRoute(builder: (_) => const SettingTabPage());
      case UserProfilePage.routeName:
        return MaterialPageRoute(builder: (_) => const UserProfilePage());
      case EditUserProfilePage.routeName:
        return MaterialPageRoute(builder: (_) => const EditUserProfilePage());
      case ChangePasswordPage.routeName:
        return MaterialPageRoute(builder: (_) => const ChangePasswordPage());
      case HomeTabPage.routeName:
        return MaterialPageRoute(builder: (_) => const HomeTabPage());
      case AboutPage.routeName:
        return MaterialPageRoute(builder: (_) => const AboutPage());
      case AddNewNotePage.routeName:
        return MaterialPageRoute(builder: (_) => const AddNewNotePage());
      case ViewNotePage.routeName:
        return MaterialPageRoute(
            builder: (_) => const ViewNotePage(), settings: settings);
      case UpdateNotePage.routeName:
        return MaterialPageRoute(
            builder: (_) => const UpdateNotePage(), settings: settings);
      case ViewQuizPage.routeName:
        return MaterialPageRoute(
            builder: (_) => const ViewQuizPage(), settings: settings);
      case AddNewQuizPage.routeName:
        return MaterialPageRoute(builder: (_) => const AddNewQuizPage());
      case UpdateQuizPage.routeName:
        return MaterialPageRoute(
            builder: (_) => const UpdateQuizPage(), settings: settings);
      case QuestionPage.routeName:
        return MaterialPageRoute(
            builder: (_) => const QuestionPage(), settings: settings);
      default:
        return MaterialPageRoute(builder: (_) => const LoginPage());
    }
  }
}
