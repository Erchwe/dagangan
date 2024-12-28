import 'package:flutter/material.dart';

class SuccessScreen extends StatefulWidget {
  const SuccessScreen({super.key});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showSuccessModal();
    });
  }

  /// Fungsi untuk menampilkan modal sukses transaksi
  void _showSuccessModal() {
    showDialog(
      context: context,
      barrierDismissible: false, // Modal tidak bisa ditutup manual
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: SizedBox(
            height: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Transaksi Berhasil!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                // Animasi Garis yang Memendek
                SizedBox(
                  width: 200,
                  child: TweenAnimationBuilder(
                    tween: Tween<double>(begin: 1.0, end: 0.0),
                    duration: const Duration(seconds: 2),
                    builder: (context, double value, child) {
                      return LinearProgressIndicator(
                        value: value,
                        backgroundColor: Colors.grey[300],
                        color: Colors.deepPurple,
                      );
                    },
                    onEnd: () {
                      Navigator.of(context).pop(); // Tutup Modal
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Mengalihkan ke Dashboard...',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(),
    );
  }
}
