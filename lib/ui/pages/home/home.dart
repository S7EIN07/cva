import 'package:cva/ui/pages/cadastro/cadastro.dart';
import 'package:cva/ui/pages/perfil/perfil.dart';
import 'package:cva/ui/pages/produtos/produtos.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
  }

  final PageController _pageController = PageController(initialPage: 0);
  int _paginaAtual = 0;

  void _mudarPagina(int index) {
    setState(() => _paginaAtual = index);
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF198754),
        title: Text("CVA", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _paginaAtual = index),
        children: [Produtos(), CadastroProduto(), Perfil()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _paginaAtual,
        onTap: _mudarPagina,
        backgroundColor: const Color(0xFF198754),
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 17,
        ),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: SizedBox(height: 0), label: "Produtos"),
          BottomNavigationBarItem(
            icon: SizedBox(height: 0),
            label: "Cadastrar",
          ),
          BottomNavigationBarItem(icon: SizedBox(height: 0), label: "Perfil"),
        ],
      ),
    );
  }
}
