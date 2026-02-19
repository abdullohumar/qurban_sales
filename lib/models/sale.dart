class Sale {
  final int? id;
  final String nomor;
  final String nama;
  final String noHp;
  final String alamat;
  final String createdAt;
  final String type;
  final int price;
  final String? weight; // Nullable because old data might not have it
  final String? gender;

  Sale({
    this.id,
    required this.nomor,
    required this.nama,
    required this.noHp,
    required this.alamat,
    required this.createdAt,
    required this.type,
    required this.price,
    this.weight,
    this.gender,
  });

  // Mengubah data dari Database (Map) ke bentuk Object Dart
  factory Sale.fromMap(Map<String, dynamic> json) => Sale(
    id: json['id'],
    nomor: json['nomor'],
    nama: json['nama'],
    noHp: json['noHp'],
    alamat: json['alamat'],
    createdAt: json['createdAt'],
    type: json['type'] ?? 'Akad Salam',
    price: json['price'] ?? 2500000,
    weight: json['weight'],
    gender: json['gender'],
  );

  // Mengubah Object Dart ke bentuk Map (agar bisa disimpan ke Database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nomor': nomor,
      'nama': nama,
      'noHp': noHp,
      'alamat': alamat,
      'createdAt': createdAt,
      'type': type,
      'price': price,
      'weight': weight,
      'gender': gender,
    };
  }
}
