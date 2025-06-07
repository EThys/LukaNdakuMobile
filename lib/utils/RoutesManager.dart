import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:luka_ndaku/screens/BottomNavBar.dart';
import 'package:luka_ndaku/screens/ChatPage.dart';
import 'package:luka_ndaku/screens/CreatePropertyPage.dart';
import 'package:luka_ndaku/screens/HelpCenterPage.dart';
import 'package:luka_ndaku/screens/HomePage.dart';
import 'package:luka_ndaku/screens/LoginPage.dart';
import 'package:luka_ndaku/screens/RegisterPage.dart';
import 'package:luka_ndaku/screens/Splashscreen.dart';
import 'Routes.dart';


class RoutesManager {
  static Route route(RouteSettings r) {
    switch (r.name) {
      case Routes.loginRoute:
        return MaterialPageRoute(builder: (_)=>LoginPage());
      case Routes.registerRoute:
        return MaterialPageRoute(builder: (_)=>RegistrationPage());
      // case Routes.detailPageRoute:
      //   final PropertyModel property = r.arguments as PropertyModel;
      //   return MaterialPageRoute(builder: (_)=>PropertyDetailPage(property: property));
      case Routes.homeRoute:
        return MaterialPageRoute(builder: (_)=>HomePage());
      case Routes.bottomRoute:
        return MaterialPageRoute(builder: (_)=>BottomNavBar());
      case Routes.chatPageRoute:
        return MaterialPageRoute(builder: (_)=>ChatPage());
      case Routes.HelpCenterPageRoute:
        return MaterialPageRoute(builder: (_)=>HelpCenterPage());
      case Routes.createPropertyRoute:
        return MaterialPageRoute(builder: (_)=>CreatePropertyPage());
      default:
        return MaterialPageRoute(builder: (_) =>SplashScreen());
    }
  }
}
