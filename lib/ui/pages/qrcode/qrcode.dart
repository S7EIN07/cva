import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:universal_html/html.dart' as html;

// A GlobalKey é usada para acessar o widget do QR Code
final GlobalKey _qrKey = GlobalKey();

class Qrcode extends StatefulWidget {
  // A página Qrcode agora recebe o ID do produto
  final int? productId;
  const Qrcode({super.key, this.productId});

  @override
  State<Qrcode> createState() => _QrcodeState();
}

class _QrcodeState extends State<Qrcode> {
  String? qrText;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    // Inicia a geração do QR Code automaticamente se o ID for válido
    if (widget.productId != null) {
      _generateQrCode(widget.productId!);
    } else {
      // Caso o widget seja chamado sem um ID (de alguma outra tela)
      setState(() {
        qrText = null;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro: ID do produto não fornecido.')),
        );
      });
    }
  }

  Future<void> _saveQrCodeForMobile() async {
    try {
      final boundary =
          _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // Salvar a imagem no diretório apropriado do dispositivo
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/${widget.productId}_qrcode.png';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);

      // Salvar a imagem na galeria do dispositivo
      final result = await ImageGallerySaver.saveFile(file.path);

      if (result['isSuccess']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('QR Code salvo na galeria com sucesso! ✅'),
            backgroundColor: Color(0xFF198754),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao salvar o QR Code. 😔'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('Erro ao salvar o QR Code: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro inesperado ao salvar. Tente novamente.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _downloadQrCodeForWeb() async {
    try {
      final boundary =
          _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // Cria um link de download para a imagem
      final blob = html.Blob([Uint8List.fromList(pngBytes)]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", "qrcode_produto_${widget.productId}.png")
        ..click();
      html.Url.revokeObjectUrl(url);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Download do QR Code iniciado! ✅'),
          backgroundColor: Color(0xFF198754),
        ),
      );
    } catch (e) {
      debugPrint('Erro ao salvar o QR Code na web: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro inesperado ao iniciar o download.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Método que faz a requisição do produto e gera o QR Code
  Future<void> _generateQrCode(int productId) async {
    setState(() {
      _isGenerating = true;
      qrText = null;
    });

    try {
      // 1. Requisita os dados do produto por ID
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/products/$productId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final nomeProduto = data['nome'] ?? 'Produto Desconhecido';

        // 2. Define a URL de rastreamento/detalhes
        // A URL agora usa o ID obtido
        final productUrl = "http://seuapp.com/detalhes?id=$productId";

        setState(() {
          qrText = productUrl;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('QR Code gerado com sucesso!'),
            backgroundColor: Color(0xFF198754),
          ),
        );
      } else if (response.statusCode == 404) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro: Produto não encontrado.'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao buscar produto: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('Erro de conexão: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Falha na conexão com a API.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Fundo suave
      appBar: AppBar(
        title: const Text(
          "QR Code do Produto",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF198754),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Código Gerado',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF333333),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // --- Visualização do QR Code ou Indicador de Carregamento ---
              if (_isGenerating)
                const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: Color(0xFF198754)),
                      SizedBox(height: 20),
                      Text(
                        "Buscando produto e gerando código...",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              else if (qrText != null && qrText!.isNotEmpty)
                Center(
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: RepaintBoundary(
                        key: _qrKey,
                        child: QrImageView(
                          data: qrText!,
                          version: QrVersions.auto,
                          size: 250.0,
                          backgroundColor: Colors.white,
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
                      ),
                    ),
                  ),
                )
              else
                const Padding(
                  padding: EdgeInsets.only(top: 50.0),
                  child: Center(
                    child: Text(
                      'Não foi possível gerar o QR Code. Verifique o ID do produto.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.red),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  if (kIsWeb) {
                    _downloadQrCodeForWeb();
                  } else {
                    _saveQrCodeForMobile();
                  }
                },
                icon: const Icon(Icons.download, color: Colors.white),
                label: const Text(
                  'Baixar QR Code',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF146C43),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
