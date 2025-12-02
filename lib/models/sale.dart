class Sale {
  final int? id;
  final String nomor;
  final String nama;
  final String noHp;
  final String alamat;
  final String createdAt;

  Sale({
    this.id,
    required this.nomor,
    required this.nama,
    required this.noHp,
    required this.alamat,
    required this.createdAt,
  });

  // Mengubah data dari Database (Map) ke bentuk Object Dart
  factory Sale.fromMap(Map<String, dynamic> json) => Sale(
    id: json['json'],
    nomor: json['nomor'],
    nama: json['nama'],
    noHp: json['noHp'],
    alamat: json['alamat'],
    createdAt: json['createdAt']
  );

  // Mengubah Object Dart ke bentuk Map (agar bisa disimpan ke Database)
  Map<String, dynamic> toMap() {
    return {
      'id' : id,
      'nomor' : nomor,
      'nama' : nama,
      'noHp' : noHp,
      'alamat' : alamat,
      'createdAt' : createdAt
    };
  }
}