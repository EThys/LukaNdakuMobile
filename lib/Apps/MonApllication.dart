import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luka_ndaku/controllers/PropertyCtrl.dart';
import 'package:provider/provider.dart';
import '../controllers/AuthentificationCtrl.dart';
import '../utils/Routes.dart';
import '../utils/RoutesManager.dart';
import '../utils/StockageKeys.dart';
import '../utils/favorites_services.dart';
//import 'package:alice/alice.dart';

//Alice alice = Alice( showNotification: true);

class MonApplication extends StatelessWidget {
  var _stockage = GetStorage();
  @override
  Widget build(BuildContext context) {

    var token=_stockage.read(StockageKeys.tokenKey) ;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_)=> AuthentificationCtrl(stockage:_stockage)),
        ChangeNotifierProvider(create: (_)=> PropertyController(stockage:_stockage)),
      ],
      child: MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.red,
          textTheme: GoogleFonts.latoTextTheme(
            Theme.of(context).textTheme,
          ),
        ),
        debugShowCheckedModeBanner: false,
        onGenerateRoute: RoutesManager.route,
        initialRoute: Routes.splashRoute,
      ),
    );
  }
}
