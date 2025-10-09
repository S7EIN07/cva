// lib/ui/pages/perfil.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Importe shared_preferences

class Perfil extends StatefulWidget {
  const Perfil({Key? key}) : super(key: key);

  @override
  _PerfilState createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  Map<String, dynamic>? usuario;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchUsuario();
  }

  Future<void> _fetchUsuario() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    // 1. Carregar o token salvo no dispositivo
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(
      'token',
    ); // Usa a mesma chave que a página de login

    if (token == null || token.isEmpty) {
      // 2. Se o token não existir, exibe um erro e para a execução
      setState(() {
        isLoading = false;
        error = "Você não está logado. Faça login para ver seu perfil.";
      });
      // Opcional: navegar para a tela de login
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
      return;
    }

    try {
      // 3. Fazer a requisição com o token carregado
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        usuario = jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        error = "Sessão expirada. Faça login novamente.";
        // Opcional: remover o token inválido
        await prefs.remove('token');
      } else {
        error = "Erro ao carregar perfil: ${response.statusCode}";
      }
    } catch (e) {
      error = "Falha de conexão com o servidor.";
      debugPrint('Erro de conexão: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(error!),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _fetchUsuario,
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (usuario == null) {
      return const Scaffold(
        body: Center(child: Text('Dados do usuário não disponíveis.')),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 70,
              backgroundImage: NetworkImage(
                usuario!['imagem'] ??
                    'https://images.pexels.com/photos/349609/pexels-photo-349609.jpeg',
              ),
            ),
            const SizedBox(height: 16),
            Text(
              usuario!['username'] ?? 'Usuário',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              usuario!['email'] ?? 'Sem e-mail',
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
              child: ListTile(
                leading: const Icon(
                  Icons.description,
                  color: Color(0xFF198754),
                ),
                title: const Text("Bio"),
                subtitle: Text(usuario!['bio'] ?? 'Nenhuma bio informada.'),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
              child: ListTile(
                leading: const Icon(Icons.phone, color: Color(0xFF198754)),
                title: const Text("Telefone"),
                subtitle: Text(
                  usuario!['telefone'] ?? 'Telefone não informado.',
                ),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
              child: ListTile(
                leading: const Icon(
                  Icons.location_on,
                  color: Color(0xFF198754),
                ),
                title: const Text("Localização"),
                subtitle: Text(
                  usuario!['localizacao'] ?? 'Localização não informada.',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
