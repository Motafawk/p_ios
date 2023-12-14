class TypeModel {
  int id;
  String name;
  String? nameSingle;
  String? bannerColor;

  int? display;
  String? createdAt;
  String? updatedAt;

  TypeModel({required this.id, required this.name, this.nameSingle, this.bannerColor, this.display, this.createdAt, this.updatedAt});
  factory TypeModel.fromJson(Map<String, dynamic> json) {
    return TypeModel(
      id: json['id'],
      name: json['name'],
      nameSingle: json['name_single'],
      bannerColor: json['banner_color'],
      display: json['display'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'name_single': nameSingle,
      'banner_color': bannerColor,
      'display': display,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

}
