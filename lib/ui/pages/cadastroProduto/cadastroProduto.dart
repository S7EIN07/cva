import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:flutter/foundation.dart';
// ignore: deprecated_member_use
import 'dart:html' as html; // usado somente quando kIsWeb == true

class CadastroProdutoPage extends StatefulWidget {
  const CadastroProdutoPage({super.key});

  @override
  State<CadastroProdutoPage> createState() => _CadastroProdutoPageState();
}

class _CadastroProdutoPageState extends State<CadastroProdutoPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers para campos
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _precoController = TextEditingController();
  final _loteController = TextEditingController();
  final _validadeController = TextEditingController();
  final _pesoController = TextEditingController();
  final _ingredientesController = TextEditingController();
  final _nutricionaisController = TextEditingController();
  final _alergiaController = TextEditingController();
  final _origemController = TextEditingController();
  final _modoUsoController = TextEditingController();

  File? _selectedImage;
  Uint8List?
  _selectedImageBytes; // usado em web e também para mostrar preview em mobile se baixado por URL
  String? _imageAsBase64;
  String? _imageMimeType;

  bool _isSaving = false;
  Future<void> _pickImage() async {
    try {
      if (kIsWeb) {
        // Abre um input file nativo do browser
        final html.FileUploadInputElement uploadInput =
            html.FileUploadInputElement();
        uploadInput.accept = 'image/*';
        uploadInput.click();

        // Espera o usuário selecionar
        await uploadInput.onChange.first;
        final files = uploadInput.files;
        if (files == null || files.isEmpty) return;

        final html.File file = files[0];
        final reader = html.FileReader();

        final completer = Completer<Uint8List>();
        reader.onLoad.listen((event) {
          final result = reader.result;
          if (result is Uint8List) {
            completer.complete(result);
          } else if (result is String) {
            // result pode vir como dataUrl string; decodifica
            final dataUrl = result;
            final commaIndex = dataUrl.indexOf(',');
            final base64Str = dataUrl.substring(commaIndex + 1);
            completer.complete(base64Decode(base64Str));
          } else {
            completer.completeError('Formato de arquivo desconhecido');
          }
        });
        reader.onError.listen((err) => completer.completeError(err));
        reader.readAsArrayBuffer(file);

        final bytes = await completer.future;

        setState(() {
          _selectedImageBytes = bytes;
          _selectedImage = null; // File não aplicável na web
        });

        _imageAsBase64 = base64Encode(bytes);
        _imageMimeType =
            file.type ?? lookupMimeType('', headerBytes: bytes) ?? 'image/png';
        debugPrint(
          'Imagem web selecionada: mime=$_imageMimeType size=${bytes.length}',
        );
      } else {
        // Mobile / Desktop: mantém ImagePicker
        final picker = ImagePicker();
        final pickedFile = await picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1600,
          maxHeight: 1600,
          imageQuality: 85,
        );
        if (pickedFile == null) return;

        final bytes = await pickedFile.readAsBytes();

        setState(() {
          _selectedImageBytes = bytes;
          _selectedImage = File(pickedFile.path);
        });

        _imageAsBase64 = base64Encode(bytes);
        _imageMimeType =
            lookupMimeType(pickedFile.path, headerBytes: bytes) ?? 'image/jpeg';
        debugPrint(
          'Imagem mobile selecionada: mime=$_imageMimeType size=${bytes.length}',
        );
      }
    } catch (e, st) {
      debugPrint('Erro ao selecionar imagem: $e\n$st');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao selecionar imagem: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Helper que abre um diálogo para o usuário colar a URL da imagem
  Future<String?> _askForImageUrl() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Colar URL da imagem'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(
            hintText:
                'Cole aqui o link direto da imagem (exemplo endsWith .jpg .png)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _salvarProduto() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final img = _selectedImage;
    final nome = _nomeController.text.trim();
    final descricao = _descricaoController.text.trim();
    final preco = double.tryParse(_precoController.text.trim()) ?? 0.0;
    final lote = _loteController.text.trim();
    final validade = _validadeController.text.trim();
    final peso = double.tryParse(_pesoController.text.trim()) ?? 0.0;
    final ingredientes = _ingredientesController.text.trim();
    final nutricionais = _nutricionaisController.text.trim();
    final avisosAlergia = _alergiaController.text.trim();
    final origem = _origemController.text.trim();
    final modoUso = _modoUsoController.text.trim();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    debugPrint('Token lido: $token');
    debugPrint('Token lido: $token');
    debugPrint('Token lido: $token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você precisa estar logado para cadastrar produtos.'),
          backgroundColor: Colors.orange,
        ),
      );
      setState(() {
        _isSaving = false;
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/products'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'nome': nome,
          'descricao': descricao,
          'preco': preco,
          'lote': lote,
          'validade': validade,
          'peso': peso,
          'ingredientes': ingredientes,
          'informacoes_nutricionais': nutricionais,
          'avisos_alergia': avisosAlergia,
          'origem': origem,
          'modo_uso': modoUso,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produto cadastrado com sucesso!'),
            backgroundColor: Color(0xFF198754),
          ),
        );
        // Limpa todos os campos
        _nomeController.clear();
        _descricaoController.clear();
        _precoController.clear();
        _loteController.clear();
        _validadeController.clear();
        _pesoController.clear();
        _ingredientesController.clear();
        _nutricionaisController.clear();
        _alergiaController.clear();
        _origemController.clear();
        _modoUsoController.clear();
      } else {
        String message = 'Erro ao cadastrar produto.';
        try {
          final data = jsonDecode(response.body);
          if (data['detail'] != null) {
            message = data['detail'].toString();
          }
        } catch (_) {}

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
        debugPrint('Erro: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Erro ao enviar produto: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Falha de conexão com o servidor.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: icon != null
              ? Icon(icon, color: const Color(0xFF198754))
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF198754), width: 2),
          ),
        ),
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(
              height: 30,
            ), // Espaço para não colidir com o AppBar da Home
            // Título
            const Text(
              'Cadastrar Novo Produto',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Insira as informações completas do produto.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_selectedImageBytes != null)
                        Image.memory(
                          _selectedImageBytes!,
                          height: 150,
                          fit: BoxFit.cover,
                        )
                      else if (_selectedImage != null)
                        Image.file(
                          _selectedImage!,
                          height: 150,
                          fit: BoxFit.cover,
                        )
                      else
                        Container(
                          height: 150,
                          color: Colors.grey[200],
                          child: const Center(
                            child: Text('Nenhuma imagem selecionada.'),
                          ),
                        ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Selecionar Imagem do Produto'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF198754),
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Informações Básicas',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF198754),
                        ),
                      ),
                      const Divider(color: Colors.grey),
                      const SizedBox(height: 10),

                      // Nome
                      _buildTextField(
                        controller: _nomeController,
                        labelText: 'Nome do Produto',
                        icon: Icons.inventory_2_outlined,
                        validator: (value) =>
                            value!.isEmpty ? 'Informe o nome' : null,
                      ),

                      // Descrição
                      _buildTextField(
                        controller: _descricaoController,
                        labelText: 'Descrição (opcional)',
                        icon: Icons.description_outlined,
                        maxLines: 3,
                      ),

                      // Preço
                      _buildTextField(
                        controller: _precoController,
                        labelText: 'Preço (R\$)',
                        icon: Icons.attach_money,
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value!.isEmpty ||
                                double.tryParse(value.replaceAll(',', '.')) ==
                                    null
                            ? 'Informe um preço válido'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Detalhes de Rastreamento e Logística',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF198754),
                        ),
                      ),
                      const Divider(color: Colors.grey),
                      const SizedBox(height: 10),

                      // Lote
                      _buildTextField(
                        controller: _loteController,
                        labelText: 'Número do Lote',
                        icon: Icons.qr_code_2,
                      ),

                      // Validade
                      _buildTextField(
                        controller: _validadeController,
                        labelText: 'Data de Validade (Ex: 01/01/2025)',
                        icon: Icons.calendar_month,
                      ),

                      // Peso
                      _buildTextField(
                        controller: _pesoController,
                        labelText: 'Peso (em gramas/Kg)',
                        icon: Icons.fitness_center,
                        keyboardType: TextInputType.number,
                      ),

                      const SizedBox(height: 20),
                      const Text(
                        'Informações Nutricionais e Consumo',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF198754),
                        ),
                      ),
                      const Divider(color: Colors.grey),
                      const SizedBox(height: 10),

                      // Ingredientes
                      _buildTextField(
                        controller: _ingredientesController,
                        labelText: 'Ingredientes',
                        icon: Icons.local_florist_outlined,
                        maxLines: 4,
                      ),

                      // Informações Nutricionais (Calorias e etc)
                      _buildTextField(
                        controller: _nutricionaisController,
                        labelText: 'Informações Nutricionais (Calorias, etc.)',
                        icon: Icons.analytics_outlined,
                        maxLines: 4,
                      ),

                      // Avisos de Alergia
                      _buildTextField(
                        controller: _alergiaController,
                        labelText: 'Avisos de Alergia',
                        icon: Icons.warning_amber_outlined,
                        maxLines: 3,
                      ),

                      // Origem
                      _buildTextField(
                        controller: _origemController,
                        labelText: 'Origem / Fabricante',
                        icon: Icons.location_on_outlined,
                      ),

                      // Modo de Uso
                      _buildTextField(
                        controller: _modoUsoController,
                        labelText: 'Modo de Uso (se necessário)',
                        icon: Icons.plumbing,
                        maxLines: 3,
                      ),

                      const SizedBox(height: 30),

                      // --- Botão de Salvar ---
                      ElevatedButton.icon(
                        onPressed: _isSaving ? null : _salvarProduto,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save, size: 28),
                        label: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                          child: Text(
                            _isSaving ? 'Salvando...' : 'Salvar Produto',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF198754),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
