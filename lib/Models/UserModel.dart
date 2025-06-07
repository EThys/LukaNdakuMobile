class UserModel {
  String? username;
  String? postnom;
  String? email;
  String? telephone;
  String? ville;
  String? profession;
  String? genre;
  DateTime? dateNaissance;
  String? role;

  UserModel({
    this.username,
    this.postnom,
    this.email,
    this.telephone,
    this.ville,
    this.profession,
    this.genre,
    this.dateNaissance,
    this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    username: json["username"],
    postnom: json["postnom"],
    email: json["email"],
    telephone: json["telephone"],
    ville: json["ville"],
    profession: json["profession"],
    genre: json["genre"],
    dateNaissance: json["date_naissance"] == null
        ? null
        : DateTime.parse(json["date_naissance"]),
    role: json["role"],
  );

  Map<String, dynamic> toJson() => {
    "username": username,
    "postnom": postnom,
    "email": email,
    "telephone": telephone,
    "ville": ville,
    "profession": profession,
    "genre": genre,
    "date_naissance": dateNaissance?.toIso8601String(),
    "role": role,
  };

  @override
  String toString() {
    return 'UserModel(username: $username, email: $email, role: $role)';
  }
}