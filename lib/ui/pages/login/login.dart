import 'dart:convert';
import 'package:cva/ui/pages/home/home.dart';
import 'package:cva/ui/pages/registerUser/registerUser.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _loginUsuario() async {
    // 1. Validação do formulário
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    try {
      // API Call para validação no banco de dados
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/login'), // URL do seu backend
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      // 2. Validação da resposta do servidor (sucesso)
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access_token'];

        // Salvar token localmente
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        // ADIÇÃO DE DEBUG: Confirma se o token foi salvo
        debugPrint('Token SALVO: $token');

        // Mostrar mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login realizado com sucesso!'),
            backgroundColor: Color(0xFF198754),
          ),
        );

        // Navegar para a tela Home e remover a tela de login da pilha
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
        );
      }
      // 3. Validação da resposta do servidor (erro de credenciais)
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuário ou senha inválidos'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // 4. Validação de erro de conexão/servidor
      debugPrint('Erro de conexão: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Falha de conexão com o servidor'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Bem-vindo!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Entre na sua conta para continuar',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),

              Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset('assets/img/logo.png', height: 125),
                        const SizedBox(height: 20),

                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: 'Usuário',
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) =>
                              value!.isEmpty ? 'Informe o usuário' : null,
                        ),
                        const SizedBox(height: 20),

                        // Campo Senha
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            prefixIcon: const Icon(Icons.lock),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          obscureText: true,
                          validator: (value) =>
                              value!.isEmpty ? 'Informe a senha' : null,
                        ),
                        const SizedBox(height: 10),

                        // Link para Registro
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegistroPage(),
                                ),
                              );
                            },
                            child: const Text(
                              "Criar uma conta",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Botão de Login
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _loginUsuario,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: const Color(0xFF198754),
                            ),
                            child: const Text(
                              'Entrar',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
