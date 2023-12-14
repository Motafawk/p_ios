class SystemModel {
  int id;
  String? name;

  int display;
  String createdAt;
  String updatedAt;

  SystemModel({required this.id, this.name, required this.display, required this.createdAt, required this.updatedAt});
  factory SystemModel.fromJson(Map<String, dynamic> json) {
    return SystemModel(
      id: json['id'],
      name: json['name'],
      display: json['display'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'display': display,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

}