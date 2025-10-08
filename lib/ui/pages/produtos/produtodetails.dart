import 'package:cva/ui/pages/qrcode/qrcode.dart';
import 'package:flutter/material.dart';

class DetalhesProduto extends StatelessWidget {
  final Map<String, dynamic> produto;
  const DetalhesProduto({super.key, required this.produto});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(produto['nome'])),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  produto['imagem'],
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                produto['nome'],
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(produto['descricao']),
              const SizedBox(height: 20),
              Text(
                "Preço: R\$ ${produto['preco'].toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 10),
              FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Qrcode()),
                  );
                },
                child: const Icon(Icons.qr_code),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
