import 'package:flutter/material.dart';
import '../models/produk_model.dart';
import '../api/api_service.dart';
import '../utils/constants.dart';

class SubmitPage extends StatefulWidget {
  const SubmitPage({super.key});

  @override
  State<SubmitPage> createState() => _SubmitPageState();
}

class _SubmitPageState extends State<SubmitPage> {
  final _cNama = TextEditingController();
  final _cHarga = TextEditingController();
  final _cDesk = TextEditingController();
  final _cGithub = TextEditingController();
  final _api = ApiService();
  bool _loading = false;

  Future<void> _submit() async {
    if (_cNama.text.isEmpty || _cHarga.text.isEmpty || _cGithub.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Isi semua data!')));
      return;
    }

    setState(() => _loading = true);
    final p = ProdukModel(
      nama: _cNama.text,
      harga: int.tryParse(_cHarga.text) ?? 0,
      deskripsi: _cDesk.text,
      urlGithub: _cGithub.text,
    );

    if (await _api.submitFinal(p)) {
      if (!mounted) return;
      showDialog(context: context, builder: (c) => AlertDialog(
        title: const Text('Berhasil!'),
        content: const Text('Tugas telah dikirim.'),
        actions: [TextButton(onPressed: () {
          Navigator.pop(c);
          Navigator.pop(context);
        }, child: const Text('OK'))],
      ));
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Tugas'), 
        backgroundColor: AppConstants.primaryColor, 
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInput('Nama Produk', _cNama, TextInputType.text),
            const SizedBox(height: 12),
            _buildInput('Harga', _cHarga, TextInputType.number),
            const SizedBox(height: 12),
            _buildInput('Deskripsi', _cDesk, TextInputType.text, maxLines: 3),
            const SizedBox(height: 12),
            _buildInput('Github URL', _cGithub, TextInputType.url),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.successColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.defaultRadius)),
                  elevation: 0,
                ),
                child: _loading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text('SUBMIT SEKARANG', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController c, TextInputType type, {int maxLines = 1}) {
    return TextField(
      controller: c,
      keyboardType: type,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.defaultRadius)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
