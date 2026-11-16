import 'package:flutter/material.dart';

class ProductFormScreen extends StatefulWidget {
  final bool isEdit;
  final String? initialBarcode;
  final String? initialName;
  final String? initialCostPrice;
  final String? initialSellPrice;
  final int initialStock;
  final int initialMinStock;

  const ProductFormScreen({
    super.key,
    this.isEdit = false,
    this.initialBarcode,
    this.initialName,
    this.initialCostPrice,
    this.initialSellPrice,
    this.initialStock = 24,
    this.initialMinStock = 5,
  });

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _barcodeController;
  late final TextEditingController _nameController;
  late final TextEditingController _costPriceController;
  late final TextEditingController _sellPriceController;
  late final TextEditingController _stockController;
  late final TextEditingController _minStockController;

  @override
  void initState() {
    super.initState();
    _barcodeController = TextEditingController(
      text: widget.initialBarcode ?? '',
    );
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _costPriceController = TextEditingController(
      text: widget.initialCostPrice ?? '',
    );
    _sellPriceController = TextEditingController(
      text: widget.initialSellPrice ?? '',
    );
    _stockController = TextEditingController(
      text: widget.isEdit ? '${widget.initialStock}' : '',
    );
    _minStockController = TextEditingController(
      text: '${widget.initialMinStock}',
    );
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _nameController.dispose();
    _costPriceController.dispose();
    _sellPriceController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    super.dispose();
  }

  void _adjustStock(int delta) {
    final current = int.tryParse(_stockController.text) ?? 0;
    final next = (current + delta).clamp(0, 999999);
    setState(() {
      _stockController.text = '$next';
    });
  }

  InputDecoration _inputDecoration({required String hint, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF69736D), fontSize: 15),
      suffixIcon: suffixIcon,
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
          onPressed: () => Navigator.pop(context),
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
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFDEE3DF)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // const _FieldLabel('Kode Barcode'),
                        // const SizedBox(height: 8),
                        // Row(
                        //   children: [
                        //     Expanded(
                        //       child: TextFormField(
                        //         controller: _barcodeController,
                        //         keyboardType: TextInputType.number,
                        //         decoration: _inputDecoration(
                        //           hint: '89927419...',
                        //         ),
                        //       ),
                        //     ),
                        //     const SizedBox(width: 8),
                        //     InkWell(
                        //       onTap: () {
                        //         ScaffoldMessenger.of(context).showSnackBar(
                        //           const SnackBar(
                        //             content: Text('Scanner barcode dibuka'),
                        //           ),
                        //         );
                        //       },
                        //       borderRadius: BorderRadius.circular(10),
                        //       child: Container(
                        //         width: 50,
                        //         height: 50,
                        //         decoration: BoxDecoration(
                        //           color: const Color(0xFFE8F1E9),
                        //           borderRadius: BorderRadius.circular(10),
                        //           border: Border.all(
                        //             color: const Color(0xFF1B5E20),
                        //           ),
                        //         ),
                        //         child: const Icon(
                        //           Icons.qr_code_scanner,
                        //           color: Color(0xFF1B5E20),
                        //         ),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        const SizedBox(height: 18),
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
                            hint: 'Minyak Goreng 2L',
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const _FieldLabel('Harga Modal'),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _costPriceController,
                                    keyboardType: TextInputType.number,
                                    decoration: _inputDecoration(
                                      hint: 'Rp 35.000',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const _FieldLabel('Harga Jual'),
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
                                      hint: 'Rp 40.000',
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
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      Navigator.pop(context);
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
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'SIMPAN BARANG',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
