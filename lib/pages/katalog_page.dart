import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/produk_model.dart';
import '../api/api_service.dart';
import '../utils/constants.dart';
import 'login_page.dart';
import 'submit_page.dart';

class KatalogPage extends StatefulWidget {
  const KatalogPage({super.key});

  @override
  State<KatalogPage> createState() => _KatalogPageState();
}

class _KatalogPageState extends State<KatalogPage> {
  final _api = ApiService();
  List<ProdukModel> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _items = await _api.fetchProducts();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
    setState(() => _loading = false);
  }

  void _showAdd() {
    final cName = TextEditingController();
    final cPrice = TextEditingController();
    final cDesc = TextEditingController();

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Add Draft'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: cName, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: cPrice, decoration: const InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number),
            TextField(controller: cDesc, decoration: const InputDecoration(labelText: 'Desc')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final p = ProdukModel(nama: cName.text, harga: int.tryParse(cPrice.text) ?? 0, deskripsi: cDesc.text);
              if (await _api.saveDraft(p)) {
                Navigator.pop(c);
                _load();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog Produk'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
          IconButton(onPressed: () async {
            await _api.logout();
            if (!mounted) return;
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const LoginPage()));
          }, icon: const Icon(Icons.logout)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _items.length,
              itemBuilder: (c, i) {
                final item = _items[i];
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.defaultRadius)),
                  child: ListTile(
                    title: Text(item.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(fmt.format(item.harga)),
                    trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () async {
                      if (await _api.deleteProduct(item.id!)) _load();
                    }),
                  ),
                );
              },
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'f1', 
            onPressed: _showAdd, 
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.defaultRadius)),
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'f2',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const SubmitPage())),
            label: const Text('SUBMIT TUGAS'),
            icon: const Icon(Icons.send),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.defaultRadius)),
            backgroundColor: AppConstants.successColor,
          ),
        ],
      ),
    );
  }
}
