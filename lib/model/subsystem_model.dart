class SubsystemModel {
  int id;
  String? name;

  int systemId;

  int display;
  String createdAt;
  String updatedAt;

  SubsystemModel({required this.id, this.name, required this.systemId, required this.display, required this.createdAt, required this.updatedAt});
  factory SubsystemModel.fromJson(Map<String, dynamic> json) {
    return SubsystemModel(
      id: json['id'],
      name: json['name'],
      systemId: json['system_id'],
      display: json['display'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'system_id': systemId,
      'display': display,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

}