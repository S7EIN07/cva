import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class Qrcode extends StatefulWidget {
  const Qrcode({super.key});

  @override
  State<Qrcode> createState() => _QrcodeState();
}

class _QrcodeState extends State<Qrcode> {
  final TextEditingController _controller = TextEditingController();
  String? qrText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gerar QR Code"),
        centerTitle: true,
        backgroundColor: const Color(0xFF198754),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: "ID do produto",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF198754),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  setState(() {
                    qrText = "https://github.com/S7EIN07/cva";
                  });
                }
              },
              child: const Text(
                "Gerar QR Code",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),

            const SizedBox(height: 40),

            if (qrText != null)
              QrImageView(
                data: qrText!,
                version: QrVersions.auto,
                size: 250.0,
                backgroundColor: Colors.white,
                // ignore: deprecated_member_use
                foregroundColor: const Color(0xFF198754),
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: Color(0xFF146C43),
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Color(0xFF198754),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
