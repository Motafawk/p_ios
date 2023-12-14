class UnitModel {
  int id;
  String? name;
  String? img;
  String? file;
  String? indexes;
  String? country;

  int sectionId;

  int classId;
  int termId;
  int typeId;
  int? subsystemId;

  int favorite;

  int display;
  String createdAt;
  String updatedAt;

  UnitModel({
    required this.id,
    this.name,
    this.img,
    this.file,
    this.indexes,
    this.country,
    required this.sectionId,
    required this.classId,
    required this.termId,
    required this.typeId,
    this.subsystemId,
    required this.favorite,
    required this.display,
    required this.createdAt,
    required this.updatedAt,
  });
  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      id: json['id'],
      name: json['name'],
      img: json['img'],
      file: json['file'],
      indexes: json['indexes'],
      country: json['country'],
      sectionId: json['section_id'],
      classId: json['class_id'],
      termId: json['term_id'],
      typeId: json['type_id'],
      subsystemId: json['subsystem_id'],
      favorite: json['favorite'],
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
      'file': file,
      'indexes': indexes,
      'country': country,
      'section_id': sectionId,
      'class_id': classId,
      'term_id': termId,
      'type_id': typeId,
      'subsystem_id': subsystemId,
      'favorite': favorite,
      'display': display,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}