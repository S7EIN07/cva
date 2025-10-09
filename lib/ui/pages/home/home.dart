import 'package:cva/ui/pages/cadastroProduto/cadastroProduto.dart';
import 'package:cva/ui/pages/login/login.dart';
import 'package:cva/ui/pages/perfil/perfil.dart';
import 'package:cva/ui/pages/produtos/produtos.dart';
import 'package:cva/ui/pages/registerUser/registerUser.dart';
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
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF198754),
        elevation: 0,

        leading: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Image.asset('assets/img/logo_branca.png', height: 30),
        ),
        title: const Text(
          "CVA",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _paginaAtual = index),
        children: [
          const Produtos(),
          const CadastroProdutoPage(),
          const Perfil(),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _paginaAtual,
        onTap: _mudarPagina,

        backgroundColor: Colors.white,
        elevation: 10,

        selectedItemColor: const Color(0xFF198754),
        unselectedItemColor: Colors.grey[500],
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 12,
        ),

        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined, size: 28),
            activeIcon: Icon(Icons.storefront, size: 28),
            label: 'Produtos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline, size: 28),
            activeIcon: Icon(Icons.add_circle, size: 28),
            label: 'Cadastrar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline, size: 28),
            activeIcon: Icon(Icons.person, size: 28),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
