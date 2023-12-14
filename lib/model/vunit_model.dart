class VUnitModel {
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

  String? sectionName;
  String? sectionImg;
  int? subjectId;
  String? subjectName;
  String? subjectImg;
  String? typeName;
  String? typeNameSingle;
  String? typeBannerColor;

  String? subsystemName;
  String? systemId;
  String? systemName;

  VUnitModel({
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

    this.sectionName,
    this.sectionImg,
    this.subjectId,
    this.subjectName,
    this.subjectImg,
    this.typeName,
    this.typeNameSingle,
    this.typeBannerColor,

    this.subsystemName,
    this.systemId,
    this.systemName,
  });
  factory VUnitModel.fromJson(Map<String, dynamic> json) {
    return VUnitModel(
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

      sectionName: json['section_name'],
      sectionImg: json['section_img'],
      subjectId: json['subject_id'],
      subjectName: json['subject_name'],
      subjectImg: json['subject_img'],
      typeName: json['type_name'],
      typeNameSingle: json['type_name_single'],
      typeBannerColor: json['type_banner_color'],

      subsystemName: json['subsystem_name'],
      systemId: json['system_id'],
      systemName: json['system_name'],
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

      'section_name': sectionName,
      'section_img': sectionImg,
      'subject_id': subjectId,
      'subject_name': subjectName,
      'subject_img': subjectImg,
      'type_name': typeName,
      'type_name_single': typeNameSingle,
      'type_banner_color': typeBannerColor,

      'subsystem_name': subsystemName,
      'system_id': systemId,
      'system_name': systemName,
    };
  }
}