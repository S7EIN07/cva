import 'package:cva/ui/pages/produtos/produtodetails.dart';
import 'package:flutter/material.dart';

class Produtos extends StatefulWidget {
  const Produtos({super.key});

  @override
  State<Produtos> createState() => _ProdutosState();
}

class _ProdutosState extends State<Produtos> {
  final List<Map<String, dynamic>> produtos = [
    {
      'id': 1,
      'nome': 'Salsicha do Salsicha',
      'descricao': 'Salsichona bala.',
      'preco': 4.50,
      'imagem':
          'https://media.istockphoto.com/id/1316134499/pt/foto/a-concept-image-of-a-magnifying-glass-on-blue-background-with-a-word-example-zoom-inside-the.jpg?s=2048x2048&w=is&k=20&c=eOlrw2emTUBuhGaWgOCIyJ0UTn842-gS2Bn8_n9_vK0=',
    },
    {
      'id': 2,
      'nome': 'Queijo Artesanal Mezzo',
      'descricao': 'Queijo nhamenhame.',
      'preco': 4.20,
      'imagem':
          'https://media.istockphoto.com/id/1316134499/pt/foto/a-concept-image-of-a-magnifying-glass-on-blue-background-with-a-word-example-zoom-inside-the.jpg?s=2048x2048&w=is&k=20&c=eOlrw2emTUBuhGaWgOCIyJ0UTn842-gS2Bn8_n9_vK0=',
    },
    {
      'id': 3,
      'nome': 'Queijo Minas',
      'descricao': 'Queijo pros cria.',
      'preco': 5.00,
      'imagem':
          'https://media.istockphoto.com/id/1316134499/pt/foto/a-concept-image-of-a-magnifying-glass-on-blue-background-with-a-word-example-zoom-inside-the.jpg?s=2048x2048&w=is&k=20&c=eOlrw2emTUBuhGaWgOCIyJ0UTn842-gS2Bn8_n9_vK0=',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Recomendações")),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: produtos.length,
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
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                    child: Image.network(
                      produto['imagem'],
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            produto['nome'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            produto['descricao'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "${produto['preco'].toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
