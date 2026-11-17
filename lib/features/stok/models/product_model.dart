class ProductModel {
  final int id;
  final String namaBarang;
  final String satuan;
  final int hargaModal;
  final int hargaJual;
  final int jumlahStok;
  final int batasStokMenipis;

  const ProductModel({
    this.id = 0,
    required this.namaBarang,
    this.satuan = 'pcs',
    required this.hargaModal,
    required this.hargaJual,
    required this.jumlahStok,
    this.batasStokMenipis = 5,
  });

  bool get isLowStock => jumlahStok <= batasStokMenipis;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final rawSatuan = json['satuan']?.toString().trim() ?? '';
    return ProductModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      namaBarang: json['nama_barang']?.toString() ?? '',
      satuan: rawSatuan.isEmpty ? 'pcs' : rawSatuan,
      hargaModal: int.tryParse(json['harga_modal'].toString()) ?? 0,
      hargaJual: int.tryParse(json['harga_jual'].toString()) ?? 0,
      jumlahStok: int.tryParse(json['jumlah_stok'].toString()) ?? 0,
      batasStokMenipis:
          int.tryParse(json['batas_stok_menipis'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id > 0) 'id': id,
      'nama_barang': namaBarang,
      'satuan': satuan,
      'harga_modal': hargaModal,
      'harga_jual': hargaJual,
      'jumlah_stok': jumlahStok,
      'batas_stok_menipis': batasStokMenipis,
    };
  }

  Map<String, String> toFormMap() {
    return {
      if (id > 0) 'id': id.toString(),
      'nama_barang': namaBarang,
      'satuan': satuan,
      'harga_modal': hargaModal.toString(),
      'harga_jual': hargaJual.toString(),
      'jumlah_stok': jumlahStok.toString(),
      'batas_stok_menipis': batasStokMenipis.toString(),
    };
  }
}
