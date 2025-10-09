import 'package:cva/ui/pages/qrcode/qrcode.dart';
import 'package:flutter/material.dart';

class DetalhesProduto extends StatelessWidget {
  final Map<String, dynamic> produto;
  const DetalhesProduto({super.key, required this.produto});

  // Helper function para exibir blocos de informação de forma consistente
  Widget _buildDetailBlock(String title, dynamic content) {
    // Converte o conteúdo para String, tratando valores nulos ou zero
    String contentString = content?.toString() ?? '';

    // Formata o peso se for um campo de peso/valor numérico
    if (title.contains('Peso') && content is double) {
      contentString = "${content.toStringAsFixed(2)} g/kg";
    }

    if (contentString.isEmpty || contentString == '0.0 g/kg') {
      return const SizedBox.shrink(); // Não mostra se o conteúdo for vazio ou zero
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF146C43),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          contentString,
          style: TextStyle(fontSize: 16, color: Colors.grey[800], height: 1.4),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // É crucial garantir que o ID seja um inteiro
    final int? produtoId = produto['id'] is int ? produto['id'] : null;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          produto['nome'],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF198754),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Imagem
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    produto['imagem'],
                    height: 250,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 250,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                          size: 60,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Nome
              Text(
                produto['nome'] ?? 'Produto Desconhecido',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF333333),
                ),
              ),

              const SizedBox(height: 10),

              // Preço
              Text(
                "R\$ ${produto['preco']?.toStringAsFixed(2).replaceAll('.', ',') ?? '0,00'}",
                style: const TextStyle(
                  fontSize: 32,
                  color: Color(0xFF198754),
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              // Descrição
              const Text(
                "Descrição do Produto",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const Divider(color: Colors.grey, height: 10),
              Text(
                produto['descricao'] ?? 'Sem descrição detalhada.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.grey[700],
                ),
              ),

              const SizedBox(height: 20),

              // Rastreamento
              const Text(
                "Especificações e Rastreamento",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const Divider(color: Colors.grey),
              _buildDetailBlock('Lote:', produto['lote'] ?? ''),
              _buildDetailBlock('Data de Validade:', produto['validade'] ?? ''),
              _buildDetailBlock('Peso:', produto['peso'] ?? 0.0),
              _buildDetailBlock('Origem/Fabricante:', produto['origem'] ?? ''),

              const SizedBox(height: 20),

              // Consumo
              const Text(
                "Informações de Consumo",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const Divider(color: Colors.grey),
              _buildDetailBlock('Ingredientes:', produto['ingredientes'] ?? ''),
              _buildDetailBlock(
                'Informações Nutricionais:',
                produto['informacoes_nutricionais'] ?? '',
              ),
              _buildDetailBlock(
                'Avisos de Alergia:',
                produto['avisos_alergia'] ?? '',
              ),
              _buildDetailBlock('Modo de Uso:', produto['modo_uso'] ?? ''),

              const SizedBox(height: 40),

              // Botão QR Code
              ElevatedButton.icon(
                onPressed: () {
                  if (produtoId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Qrcode(productId: produtoId),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('ID do produto inválido para o QR Code!'),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.qr_code, size: 28),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Text("Gerar QR Code", style: TextStyle(fontSize: 18)),
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

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
