class SectionModel {
  int id;
  String? name;
  String? img;

  int subjectId;

  int display;
  String createdAt;
  String updatedAt;

  SectionModel({
    required this.id,
    this.name,
    this.img,
    required this.subjectId,
    required this.display,
    required this.createdAt,
    required this.updatedAt,
  });
  factory SectionModel.fromJson(Map<String, dynamic> json) {
    return SectionModel(
      id: json['id'],
      name: json['name'],
      img: json['img'],
      subjectId: json['subject_id'],
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
      'subject_id': subjectId,
      'display': display,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}