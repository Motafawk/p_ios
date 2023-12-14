class VSubsystemModel {
  int id;
  String? name;

  int systemId;

  int display;
  String createdAt;
  String updatedAt;

  String? systemName;

  VSubsystemModel({
    required this.id,
    this.name,
    required this.systemId,
    required this.display,
    required this.createdAt,
    required this.updatedAt,
    required this.systemName,
  });
  factory VSubsystemModel.fromJson(Map<String, dynamic> json) {
    return VSubsystemModel(
      id: json['id'],
      name: json['name'],
      systemId: json['system_id'],
      display: json['display'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      systemName: json['system_name'],
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
      'system_name': systemName,
    };
  }

}