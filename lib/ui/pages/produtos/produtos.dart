import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cva/ui/pages/produtos/produtodetails.dart';

class Produtos extends StatefulWidget {
  const Produtos({super.key});

  @override
  State<Produtos> createState() => _ProdutosState();
}

class _ProdutosState extends State<Produtos> {
  List<Map<String, dynamic>> produtos = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchProdutos();
  }

  // Lógica de comunicação HTTP mantida conforme solicitado
  Future<void> _fetchProdutos() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/products'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        produtos = data.map<Map<String, dynamic>>((item) {
          return {
            'id': item['id'],
            'nome': item['nome'],
            'descricao': item['descricao'] ?? 'Sem descrição.',
            'preco': item['preco']?.toDouble() ?? 0.0,
            'imagem':
                'https://images.pexels.com/photos/349609/pexels-photo-349609.jpeg',
          };
        }).toList();
      } else {
        error = 'Erro ao carregar produtos: ${response.statusCode}';
      }
    } catch (e) {
      error = 'Erro ao conectar com o servidor';
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Remoção do AppBar, pois a tela Home já tem uma AppBar (Header)
    return Scaffold(
      backgroundColor: Colors.grey[100], // Fundo suave
      body: RefreshIndicator(
        onRefresh: _fetchProdutos,
        color: const Color(0xFF198754),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF198754)),
              )
            : error != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 50,
                    ),
                    const SizedBox(height: 10),
                    Text(error!, style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _fetchProdutos,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tentar Novamente'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF198754),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : produtos.isEmpty
            ? const Center(
                child: Text(
                  'Nenhum produto encontrado no momento.',
                  style: TextStyle(fontSize: 16),
                ),
              )
            // GridView para exibição de produtos (visual de cartão)
            : GridView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: produtos.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 itens por linha
                  childAspectRatio:
                      0.75, // Proporção para caber imagem, nome e preço
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  final produto = produtos[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetalhesProduto(produto: produto),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Imagem do Produto
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                            child: Image.network(
                              produto['imagem'],
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              // Placeholder de erro caso a imagem falhe
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    height: 120,
                                    color: Colors.grey[300],
                                    child: const Center(
                                      child: Icon(
                                        Icons.image_not_supported,
                                        color: Colors.grey,
                                        size: 40,
                                      ),
                                    ),
                                  ),
                            ),
                          ),

                          // Detalhes do Produto
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  produto['nome'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF333333),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'R\$ ${produto['preco'].toStringAsFixed(2).replaceAll('.', ',')}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18,
                                    color: Color(
                                      0xFF198754,
                                    ), // Cor de destaque para o preço
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  produto['descricao'],
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
