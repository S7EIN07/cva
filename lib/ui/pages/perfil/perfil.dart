import 'package:flutter/material.dart';

class Perfil extends StatefulWidget {
  const Perfil({super.key});

  @override
  State<Perfil> createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 70,
              backgroundImage: NetworkImage(
                'https://media.istockphoto.com/id/1316134499/pt/foto/a-concept-image-of-a-magnifying-glass-on-blue-background-with-a-word-example-zoom-inside-the.jpg?s=2048x2048&w=is&k=20&c=eOlrw2emTUBuhGaWgOCIyJ0UTn842-gS2Bn8_n9_vK0=',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Pyam podnejnf",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Criador de queijo bao pra krlh",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
              child: ListTile(
                leading: const Icon(Icons.email, color: Color(0xFF198754)),
                title: const Text("E-mail"),
                subtitle: const Text("lambimia@email.com"),
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
                subtitle: const Text("(49) 99999-9999"),
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
                subtitle: const Text("Concórdia - SC, Brasil"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
