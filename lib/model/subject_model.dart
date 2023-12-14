class SubjectModel {
  int id;
  String name;
  String? img;

  int? display;
  String? createdAt;
  String? updatedAt;

  SubjectModel({
    required this.id,
    required this.name,
    this.img,

    this.display,
    this.createdAt,
    this.updatedAt
  });
  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['id'],
      name: json['name'],
      img: json['img'],

      display: json['display'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'img': img,

      'display': display,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}