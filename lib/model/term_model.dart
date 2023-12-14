class TermModel {
  int id;
  String? name;

  int display;
  String createdAt;
  String updatedAt;

  TermModel({required this.id, this.name, required this.display, required this.createdAt, required this.updatedAt});
  factory TermModel.fromJson(Map<String, dynamic> json) {
    return TermModel(
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