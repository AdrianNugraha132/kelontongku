import 'package:flutter/material.dart';
import 'package:kelontongku/features/stok/models/product_model.dart';
import 'package:kelontongku/features/stok/services/product_service.dart';

class ProductFormScreen extends StatefulWidget {
  final ProductModel? product;

  const ProductFormScreen({super.key, this.product});

  bool get isEdit => product != null;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productService = ProductService();

  late final TextEditingController _nameController;
  late final TextEditingController _satuanController;
  late final TextEditingController _costPriceController;
  late final TextEditingController _sellPriceController;
  late final TextEditingController _stockController;
  late final TextEditingController _minStockController;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _nameController = TextEditingController(text: product?.namaBarang ?? '');
    _satuanController = TextEditingController(text: product?.satuan ?? 'pcs');
    _costPriceController = TextEditingController(
      text: product != null ? '${product.hargaModal}' : '',
    );
    _sellPriceController = TextEditingController(
      text: product != null ? '${product.hargaJual}' : '',
    );
    _stockController = TextEditingController(
      text: product != null ? '${product.jumlahStok}' : '0',
    );
    _minStockController = TextEditingController(
      text: product != null ? '${product.batasStokMenipis}' : '5',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _satuanController.dispose();
    _costPriceController.dispose();
    _sellPriceController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    super.dispose();
  }

  void _adjustStock(int delta) {
    final current = int.tryParse(_stockController.text.trim()) ?? 0;
    final next = (current + delta).clamp(0, 999999);
    setState(() {
      _stockController.text = '$next';
    });
  }

  int _parseInt(String text) {
    final digitsOnly = text.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digitsOnly) ?? 0;
  }

  Future<void> _submitForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    final satuanText = _satuanController.text.trim();
    final payload = ProductModel(
      id: widget.product?.id ?? 0,
      namaBarang: _nameController.text.trim(),
      satuan: satuanText.isEmpty ? 'pcs' : satuanText,
      hargaModal: _parseInt(_costPriceController.text),
      hargaJual: _parseInt(_sellPriceController.text),
      jumlahStok: _parseInt(_stockController.text),
      batasStokMenipis: _parseInt(_minStockController.text),
    );

    try {
      if (widget.isEdit) {
        await _productService.updateProduct(payload);
      } else {
        await _productService.createProduct(payload);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEdit
                ? 'Barang berhasil diperbarui'
                : 'Barang berhasil disimpan',
          ),
          backgroundColor: const Color(0xFF1B5E20),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: const Color(0xFFC62828),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _confirmAndDelete() async {
    final product = widget.product;
    if (product == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Barang?'),
        content: Text(
          'Barang "${product.namaBarang}" akan dihapus permanen dari daftar stok.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC62828),
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSubmitting = true);
    try {
      await _productService.deleteProduct(product.id);
      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Barang berhasil dihapus'),
          backgroundColor: Color(0xFF1B5E20),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: const Color(0xFFC62828),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF69736D), fontSize: 15),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFADB7B0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF1B5E20), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFC62828)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFC62828), width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
        ),
        title: Text(
          widget.isEdit ? 'Edit Barang' : 'Tambah Barang',
          style: const TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFDEE3DF)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _FieldLabel('Nama Barang'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _nameController,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Nama barang wajib diisi';
                                }
                                return null;
                              },
                              decoration: _inputDecoration(
                                hint: 'Contoh: Minyak Goreng 2L',
                              ),
                            ),
                            const SizedBox(height: 18),
                            const _FieldLabel('Satuan'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _satuanController,
                              decoration: _inputDecoration(
                                hint: 'Contoh: pcs, kg, liter, dus',
                              ),
                            ),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const _FieldLabel('Harga Modal (Rp)'),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller: _costPriceController,
                                        keyboardType: TextInputType.number,
                                        decoration: _inputDecoration(
                                          hint: '35000',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const _FieldLabel('Harga Jual (Rp)'),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller: _sellPriceController,
                                        keyboardType: TextInputType.number,
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return 'Wajib diisi';
                                          }
                                          return null;
                                        },
                                        decoration: _inputDecoration(
                                          hint: '40000',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            const _FieldLabel('Jumlah Stok'),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _StockStepButton(
                                  icon: Icons.remove,
                                  onTap: () => _adjustStock(-1),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextFormField(
                                    controller: _stockController,
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    decoration: _inputDecoration(hint: '24'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                _StockStepButton(
                                  icon: Icons.add,
                                  filled: true,
                                  onTap: () => _adjustStock(1),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            const _FieldLabel('Batas Peringatan Stok Menipis'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _minStockController,
                              keyboardType: TextInputType.number,
                              decoration: _inputDecoration(hint: '5'),
                            ),
                          ],
                        ),
                      ),
                      if (widget.isEdit) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton.icon(
                            onPressed: _isSubmitting ? null : _confirmAndDelete,
                            icon: const Icon(Icons.delete_outline),
                            label: const Text(
                              'Hapus Barang',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFC62828),
                              side: const BorderSide(color: Color(0xFFC62828)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'SIMPAN BARANG',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF1A1A1A),
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _StockStepButton extends StatelessWidget {
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  const _StockStepButton({
    required this.icon,
    this.filled = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: filled ? const Color(0xFFE8F1E9) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: filled ? const Color(0xFF1B5E20) : const Color(0xFFADB7B0),
          ),
        ),
        child: Icon(icon, color: const Color(0xFF1B5E20)),
      ),
    );
  }
}
