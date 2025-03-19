class UserModel {
  final int id;
  final String name;
  final String uuid;

  UserModel({
    required this.id,
    required this.name,
    required this.uuid,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      uuid: json['uuid'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'uuid': uuid,
      };
}
