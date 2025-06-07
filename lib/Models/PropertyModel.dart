import 'package:meta/meta.dart';
import 'dart:convert';

PropertyModel propertyModelFromJson(String str) => PropertyModel.fromJson(json.decode(str));

String propertyModelToJson(PropertyModel data) => json.encode(data.toJson());

class PropertyModel {
  int id;
  String? titre;
  String? description;
  String? localisation;
  double? taille;
  int? chambres;
  int? sallesDeBain;
  String? typeTransaction;
  String? typeMaison; // Nouveau champ
  dynamic prixVente;
  dynamic prixLocation;
  DateTime dateCreation;
  DateTime dateModification;
  bool publiee;
  List<String> images;
  List<String> equipements; // Nouveau champ

  PropertyModel({
    required this.id,
    required this.titre,
    required this.description,
    required this.localisation,
    required this.taille,
    required this.chambres,
    required this.sallesDeBain,
    required this.typeTransaction,
    required this.typeMaison,
    required this.prixVente,
    required this.prixLocation,
    required this.dateCreation,
    required this.dateModification,
    required this.publiee,
    required this.images,
    required this.equipements,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) => PropertyModel(
    id: json["id"],
    titre: json["titre"],
    description: json["description"],
    localisation: json["localisation"],
    taille: json["taille"]?.toDouble(),
    chambres: json["chambres"],
    sallesDeBain: json["salles_de_bain"],
    typeTransaction: json["type_transaction"],
    typeMaison: json["type_maison"], // Mapping du nouveau champ
    prixVente: json["prix_vente"],
    prixLocation: json["prix_location"],
    dateCreation: DateTime.parse(json["date_creation"]),
    dateModification: DateTime.parse(json["date_modification"]),
    publiee: json["publiee"],
    images: List<String>.from(json["images"].map((x) => x.toString())),
    equipements: json["equipements"] != null
        ? List<String>.from(json["equipements"].map((x) => x["nom"]?.toString() ?? ''))
        : <String>[],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "titre": titre,
    "description": description,
    "localisation": localisation,
    "taille": taille,
    "chambres": chambres,
    "salles_de_bain": sallesDeBain,
    "type_transaction": typeTransaction,
    "type_maison": typeMaison, // Sérialisation du nouveau champ
    "prix_vente": prixVente,
    "prix_location": prixLocation,
    "date_creation": dateCreation.toIso8601String(),
    "date_modification": dateModification.toIso8601String(),
    "publiee": publiee,
    "images": List<dynamic>.from(images.map((x) => x)),
    "equipements": List<dynamic>.from(equipements.map((x) => x)),
  };

  String get formattedPrice {
    if (typeTransaction == 'location' && prixLocation != null) {
      return '${prixLocation?.toStringAsFixed(2)}\$/mois';
    } else if (typeTransaction == 'vente' && prixVente != null) {
      return '${prixVente?.toStringAsFixed(2)}€';
    }
    return 'Prix non disponible';
  }

  @override
  String toString() {
    return 'PropertyModel{\n'
        '  id: $id,\n'
        '  titre: $titre,\n'
        '  description: ${description != null ? (description!.length > 20 ? '${description!.substring(0, 20)}...' : description) : null},\n'
        '  localisation: $localisation,\n'
        '  taille: $taille m²,\n'
        '  chambres: $chambres,\n'
        '  sallesDeBain: $sallesDeBain,\n'
        '  typeTransaction: $typeTransaction,\n'
        '  typeMaison: $typeMaison,\n' // Affichage du type de maison
        '  equipements: ${equipements.join(", ")},\n' // Affichage des équipements
        '  prix: ${formattedPrice},\n'
        '  publiee: $publiee,\n'
        '  images: ${images.length}\n'
        '}';
  }

  // Méthode utilitaire pour vérifier si un équipement est présent
  bool hasEquipement(String equipement) {
    return equipements.any((e) => e.toLowerCase() == equipement.toLowerCase());
  }
}