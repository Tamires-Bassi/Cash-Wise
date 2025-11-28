import 'package:flutter/material.dart'; // Importa o pacote Material, que contém todos os widgets básicos do Flutter

// Define a tela Sobre como um widget sem estado
class AboutScreen extends StatelessWidget { 
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900], // Cor de fundo da tela
      appBar: AppBar(
        backgroundColor: Colors.grey[900], // Cor de fundo da AppBar
        elevation: 0,
        title: const Text('Sobre o CashWise'), 
        centerTitle: true, // Centraliza o título da AppBar
        leading: IconButton( 
          icon: const Icon(Icons.arrow_back), // Ícone de voltar
          color: Colors.white,
          onPressed: () { // Ação ao pressionar o botão
            Navigator.pop(context); // Volta para a tela anterior
          },
        ),
      ),
      body: SingleChildScrollView( // Permite rolagem caso o conteúdo seja maior que a tela
        padding: const EdgeInsets.all(24.0), // Espaçamento interno da tela
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/Logo.png', // Reutilizando seu logo 
                width: 250,
                fit: BoxFit.contain, // Garante que a imagem não estique, ela só diminui/aumenta mantendo a proporção
              ),
              const SizedBox(height: 32),
              const Text(
                'Objetivo do Aplicativo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'O CashWise é um aplicativo de controle financeiro multiplataforma desenvolvido como projeto prático. O objetivo é ajudar usuários a gerenciar suas receitas e despesas de forma simples e intuitiva.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Integrantes da Equipe',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tamires Bassi', // Adicione os nomes conforme o PDF 
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                ),
              ),
              // Adicione mais nomes aqui se necessário
            ],
          ),
        ),
      ),
    );
  }
}