import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import '../models/UserModel.dart';
import '../utils/Endpoints.dart';
import '../utils/StockageKeys.dart';
import '../utils/requetes.dart';

class AuthentificationCtrl with ChangeNotifier {

  AuthentificationCtrl({this.stockage});

  String _token = "";

  String get token {
    var locale = stockage?.read<String>(StockageKeys.tokenKey);
    return locale ?? "";
  }

  set token(String value) {
    stockage?.write(StockageKeys.tokenKey, value);
    _token = value;
  }

  UserModel _user = UserModel();
  List <UserModel> listUsers = [];
  UserModel _userAuth=UserModel();
  GetStorage? stockage;

  List<UserModel> Listregister = [];
  List<UserModel> Listlogin = [];
  bool loading = false;

  UserModel get user {
    var locale = stockage?.read(StockageKeys.userKey);
    _user = UserModel?.fromJson(locale);
    return _user;
  }
  set user(UserModel value) {
    stockage?.write(StockageKeys.userKey, value.toJson());
    _user = value;
  }

  UserModel get userPreference {
    var locale = stockage?.read(StockageKeys.userPreferenceKey);
    _user = UserModel?.fromJson(locale);
    return _user;
  }

  set userPreference(UserModel value) {
    stockage?.write(StockageKeys.userPreferenceKey, value.toJson());
    _user = value;
  }

  //LOGIN USER
  Future<HttpResponse> login(Map data) async {
    var url = "${Endpoints.login}";
    print("URL de connexion: $url");

    HttpResponse response = await postData(url, data);
    print(response.data);

    if (response.data != null && response.data['success'] == true) {
      var token = response.data['data']['token'];
      var userData = response.data['data']['user'];

      print("USERRRRRRRRRRRDATAAAAAAA${userData}");

      // Stocker le token
      stockage?.write(StockageKeys.tokenKey, token);

      // Convertir et stocker les informations de l'utilisateur
      UserModel user = UserModel.fromJson(userData);
      stockage?.write(StockageKeys.userKey, userData);

      print("YANGOOOOOOOOOOOOO${user.toJson()}");
      this.user = user;

      print("Informations de l'utilisateur: ${user.toJson()}");
      print("Token stocké: ${stockage?.read(StockageKeys.tokenKey)}");

      notifyListeners();
    }

    return response;
  }

  //REGISTER USER
  Future<HttpResponse> register(Map<String, dynamic> userData) async {
    try {
      const url = Endpoints.register;
      print("URL d'inscription: $url");

      HttpResponse response = await postData(url, userData);
      print(response.data);
      var test=response.data != null;

      if (test) {
        var user = response.data;
        print("ici userrrrrrrrrrrr${user}");

        user = UserModel.fromJson(user);
        this.user = user;

        print("Inscription réussie: Informations de l'utilisateur - $user");

        notifyListeners();
      } else {
        print("Échec de l'inscription");
      }

      return response;
    } catch (e) {
      print("Exception lors de l'inscription: $e");
      return HttpResponse(
        status: false,
        errorMsg: "Une erreur est survenue lors de l'inscription",
        isException: true,
      );
    }
  }


  //LOGOUT USER

  Future<HttpResponse> logout(Map data) async {
    var url = "${Endpoints.logout}";
    var tkn = stockage?.read(StockageKeys.tokenKey);
    HttpResponse response = await postData(url, data, token: tkn);
    if (response.status) {
      print("${response.status}");
      notifyListeners();
    }
    print(response.data);

    return response;
  }

// "identifiant": "jean.dupont@example.com",
// "password": "12345678"
}
main() async {
  await GetStorage.init();
  var stockage = GetStorage();
  var ctrl = AuthentificationCtrl(stockage: stockage);
  ctrl.login(
      {
        "username":"Ethberg",
        "email":"ethbergmuzola500@gmail.com",
        "password":"12345678",
        "postnom":"dfffdfrfrfrfr",
        "genre":"masculin",
        "telephone":"854434602",
        "date_naissance":"2001-12-05",
        "profession":"Etudiant",
        "ville":"Kinshasa"
        // "first_name": "John",
        // "last_name": "Doe",
        // "email": "jodhn.doe@example.com",
        // "password": "Password123!",
        // "phone": "+1234567840",
        // "address": "123 Main St",
        // "city": "New York",
        // "postal_code": "10001",
        // "country": "USA",
        // "date_of_birth": "1990-01-01",
        // "gender": "male",
        // "profile_picture": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=",
        // "bio": "Je suis un nouvel utilisateur",
        // "is_agent": false,
        // "is_admin": false
    }
  );
}

