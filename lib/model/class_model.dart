class ClassModel {
  int id;
  String? name;
  String? contact;
  int display;
  String createdAt;
  String updatedAt;

  ClassModel({
    required this.id,
    this.name,
    this.contact,
    required this.display,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id'],
      name: json['name'],
      contact: json['contact'],
      display: json['display'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'contact': contact,
      'display': display,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

}
