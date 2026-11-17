import 'package:flutter/material.dart';
import 'package:kelontongku/features/kasir/widgets/payment_bottom_sheet.dart';
import 'package:kelontongku/features/pengaturan/screens/settings_screen.dart';
import 'package:kelontongku/features/stok/models/product_model.dart';
import 'package:kelontongku/features/stok/services/product_service.dart';

class _CartItem {
  final int? productId;
  final String name;
  final int unitPrice;
  int quantity;

  _CartItem({
    this.productId,
    required this.name,
    required this.unitPrice,
    required this.quantity,
  });

  int get subtotal => unitPrice * quantity;
}

class KasirScreen extends StatefulWidget {
  const KasirScreen({super.key});

  @override
  State<KasirScreen> createState() => _KasirScreenState();
}

class _KasirScreenState extends State<KasirScreen> {
  final _searchController = TextEditingController();
  final _productService = ProductService();

  List<ProductModel> _catalogProducts = [];
  bool _isSearchingProducts = false;

  final List<_CartItem> _cartItems = [
    _CartItem(name: 'Beras 5kg', unitPrice: 65000, quantity: 1),
    _CartItem(name: 'Minyak Goreng 2L', unitPrice: 20000, quantity: 2),
    _CartItem(name: 'Telur 1kg', unitPrice: 20000, quantity: 1),
  ];

  @override
  void initState() {
    super.initState();
    _loadCatalog();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCatalog() async {
    setState(() => _isSearchingProducts = true);
    try {
      final items = await _productService.fetchProducts();
      if (!mounted) return;
      setState(() {
        _catalogProducts = items;
        _isSearchingProducts = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSearchingProducts = false);
    }
  }

  List<ProductModel> get _matchingProducts {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return const [];
    return _catalogProducts
        .where((p) => p.namaBarang.toLowerCase().contains(query))
        .toList();
  }

  void _addProductToCart(ProductModel product) {
    setState(() {
      final existingIndex = _cartItems.indexWhere(
        (item) =>
            (item.productId != null && item.productId == product.id) ||
            item.name.toLowerCase() == product.namaBarang.toLowerCase(),
      );
      if (existingIndex != -1) {
        _cartItems[existingIndex].quantity++;
      } else {
        _cartItems.add(
          _CartItem(
            productId: product.id,
            name: product.namaBarang,
            unitPrice: product.hargaJual,
            quantity: 1,
          ),
        );
      }
      _searchController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.namaBarang} ditambahkan ke keranjang'),
        backgroundColor: const Color(0xFF1B5E20),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  int get _totalAmount =>
      _cartItems.fold(0, (sum, item) => sum + item.subtotal);

  String _formatRupiah(int amount) {
    final digits = amount.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(digits[i]);
    }
    return 'Rp ${buffer.toString()}';
  }

  void _openPaymentSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PaymentBottomSheet(totalAmount: _totalAmount),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = _searchController.text.trim();
    final searchResults = _matchingProducts;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text(
                        'Kasir',
                        style: TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F1E9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check,
                              color: Color(0xFF1B5E20),
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Tersimpan',
                              style: TextStyle(
                                color: Color(0xFF1B5E20),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SettingsScreen(),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.settings_outlined,
                          color: Color(0xFF1A1A1A),
                          size: 26,
                        ),
                        tooltip: 'Pengaturan',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFDEE3DF)),
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Omzet Hari Ini',
                                  style: TextStyle(
                                    color: Color(0xFF59615D),
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Rp 450.000',
                                  style: TextStyle(
                                    color: Color(0xFF1A1A1A),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 1,
                            color: const Color(0xFFDEE3DF),
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Estimasi Laba',
                                  style: TextStyle(
                                    color: Color(0xFF59615D),
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Rp 85.000',
                                  style: TextStyle(
                                    color: Color(0xFF1B5E20),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Scanner barcode siap digunakan'),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF1B5E20)),
                          ),
                          child: const Icon(
                            Icons.qr_code_scanner,
                            color: Color(0xFF1B5E20),
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Cari nama barang...',
                            hintStyle: const TextStyle(
                              color: Color(0xFF69736D),
                              fontSize: 15,
                            ),
                            suffixIcon: searchQuery.isNotEmpty
                                ? IconButton(
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {});
                                    },
                                    icon: const Icon(Icons.close, size: 20),
                                  )
                                : null,
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFDEE3DF),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF1B5E20),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: _loadCatalog,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B5E20),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: _isSearchingProducts
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.search,
                                  color: Colors.white,
                                  size: 24,
                                ),
                        ),
                      ),
                    ],
                  ),
                  if (searchQuery.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFDEE3DF)),
                      ),
                      child: searchResults.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(14),
                              child: Center(
                                child: Text(
                                  'Barang tidak ditemukan di database',
                                  style: TextStyle(
                                    color: Color(0xFF59615D),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              itemCount: searchResults.length,
                              separatorBuilder: (_, _) => const Divider(
                                height: 1,
                                color: Color(0xFFDEE3DF),
                              ),
                              itemBuilder: (context, index) {
                                final product = searchResults[index];
                                return ListTile(
                                  dense: true,
                                  title: Text(
                                    product.namaBarang,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${_formatRupiah(product.hargaJual)} • Stok: ${product.jumlahStok} ${product.satuan}',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  trailing: const Icon(
                                    Icons.add_circle,
                                    color: Color(0xFF1B5E20),
                                  ),
                                  onTap: () => _addProductToCart(product),
                                );
                              },
                            ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Keranjang',
                        style: TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${_cartItems.length} barang',
                        style: const TextStyle(
                          color: Color(0xFF59615D),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            Expanded(
              child: _cartItems.isEmpty
                  ? const Center(
                      child: Text(
                        'Keranjang masih kosong',
                        style: TextStyle(
                          color: Color(0xFF59615D),
                          fontSize: 16,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: _cartItems.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = _cartItems[index];
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFDEE3DF)),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.name,
                                      style: const TextStyle(
                                        color: Color(0xFF1A1A1A),
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      setState(
                                        () => _cartItems.removeAt(index),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: const Padding(
                                      padding: EdgeInsets.all(4),
                                      child: Icon(
                                        Icons.delete_outline,
                                        color: Color(0xFF59615D),
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  _QtyButton(
                                    icon: Icons.remove,
                                    filled: false,
                                    onTap: () {
                                      setState(() {
                                        if (item.quantity > 1) {
                                          item.quantity--;
                                        } else {
                                          _cartItems.removeAt(index);
                                        }
                                      });
                                    },
                                  ),
                                  SizedBox(
                                    width: 40,
                                    child: Text(
                                      '${item.quantity}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Color(0xFF1A1A1A),
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  _QtyButton(
                                    icon: Icons.add,
                                    filled: true,
                                    onTap: () {
                                      setState(() => item.quantity++);
                                    },
                                  ),
                                  const Spacer(),
                                  Text(
                                    _formatRupiah(item.subtotal),
                                    style: const TextStyle(
                                      color: Color(0xFF1A1A1A),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Color(0xFFDEE3DF), width: 1),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Belanja:',
                        style: TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _formatRupiah(_totalAmount),
                        style: const TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _cartItems.isEmpty ? null : _openPaymentSheet,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B5E20),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'BAYAR',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  const _QtyButton({
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: filled ? const Color(0xFFE8F1E9) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: filled ? null : Border.all(color: const Color(0xFFDEE3DF)),
        ),
        child: Icon(icon, color: const Color(0xFF1B5E20), size: 22),
      ),
    );
  }
}
