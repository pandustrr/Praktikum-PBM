class ProdukModel {
  final int? id;
  final String nama;
  final int harga;
  final String deskripsi;
  final String? urlGithub;
  final String? dibuatPada;

  ProdukModel({
    this.id,
    required this.nama,
    required this.harga,
    required this.deskripsi,
    this.urlGithub,
    this.dibuatPada,
  });

  factory ProdukModel.dariJson(Map<String, dynamic> json) {
    return ProdukModel(
      id: json['id'],
      nama: json['name'] ?? '',
      harga: json['price'] ?? 0,
      deskripsi: json['description'] ?? '',
      urlGithub: json['github_url'],
      dibuatPada: json['created_at'],
    );
  }

  Map<String, dynamic> keJson() {
    return {
      'name': nama,
      'price': harga,
      'description': deskripsi,
      if (urlGithub != null) 'github_url': urlGithub,
    };
  }
}
