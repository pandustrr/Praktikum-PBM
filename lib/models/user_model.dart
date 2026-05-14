class UserModel {
  final int id;
  final String nama;
  final String username;
  final String role;
  final String kelas;

  UserModel({
    required this.id,
    required this.nama,
    required this.username,
    required this.role,
    required this.kelas,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      nama: json['name'],
      username: json['username'],
      role: json['role']['name'],
      kelas: json['class']['name'],
    );
  }
}
