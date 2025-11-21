import 'package:flutter/material.dart'; // Importa o pacote Material, que contém todos os widgets básicos do Flutter
import 'custom_icons.dart'; // Importa o arquivo custom_icons.dart

class AppIcons {

  // ICONES PRINCIPAIS

  // Icone home
  static const home = CustomIcons(
    icon: Icons.home, // Ícone de casa
    backgroundColor:Color(0xFF6A1B9A), // Cor de fundo roxa
    iconColor: Colors.white, // Cor do ícone branca
  );

  // Icone de transação
  static const transaction = CustomIcons(
    icon: Icons.add, // Ícone de adicionar
    backgroundColor: Color(0xFF6A1B9A), // Cor de fundo roxa
    iconColor: Colors.white, // Cor do ícone branco
  );

  // icone contas
  static const accounts = CustomIcons(
    icon: Icons.account_balance_wallet, // Ícone de carteira
    backgroundColor: Color(0xFF6A1B9A), // Cor de fundo roxa
    iconColor: Colors.white, // Cor do ícone branca
  );

  // Icone sobre
  static const about = CustomIcons(
    icon: Icons.info, // Ícone de informação
    backgroundColor: Color(0xFF6A1B9A), // Cor de fundo roxa
    iconColor: Colors.white, // Cor do ícone branca
  );

  // Icone categorias
  static const categories = CustomIcons(
    icon: Icons.category, // Ícone de categoria
    backgroundColor: Color(0xFF6A1B9A), // Cor de fundo roxa
    iconColor: Colors.white, // Cor do ícone branca
  );

  // ICONES FINANCEIROS

  // Icone de receita
  static const income = CustomIcons(
    icon: Icons.trending_up, // Ícone de tendência para cima
    showBackground: false, // Sem fundo
    iconColor: Color.fromARGB(255, 10, 94, 45), // verde
  );

  // Icone de despesa
  static const expense = CustomIcons(
    icon: Icons.trending_down, // Ícone de tendência para baixo
    showBackground: false, // Sem fundo
    iconColor: Color.fromARGB(255, 136, 8, 8), // vermelho
  );

  // Icone dos cartões
  static const cards_nubank = CustomIcons(
    icon: Icons.credit_card, // Ícone de cartão de crédito
    backgroundColor: Color(0xFF8A05BE), // roxo Nubank
    iconColor: Colors.white, // Cor do ícone branca
  );

  static const cards_itau = CustomIcons(
    icon: Icons.credit_card, // Ícone de cartão de crédito
    backgroundColor: Color(0xFFED8B00), // laranja Itaú
    iconColor: Colors.white, // Cor do ícone branca
  );

  static const cards_santander = CustomIcons(
    icon: Icons.credit_card, // Ícone de cartão de crédito
    backgroundColor: Color(0xFFE60014), // vermelho Santander
    iconColor: Colors.white, // Cor do ícone branca
  );

  static const cards_banco_do_brasil = CustomIcons(
    icon: Icons.credit_card, // Ícone de cartão de crédito
    backgroundColor: Color(0xFFffde00), // amarelo Banco do Brasil
    iconColor: Colors.black, // Cor do ícone preta
  );

  static const cards_others = CustomIcons(
    icon: Icons.credit_card, // Ícone de cartão de crédito
    backgroundColor: Color.fromARGB(255, 56, 55, 56), // cinza escuro
    iconColor: Colors.white, // Cor do ícone branca
  );

  // ICONES DE CATEGORIAS

  //cone alimentação
  static const category_food = CustomIcons(
    icon: Icons.fastfood, // Ícone de comida
    backgroundColor: Color(0xFFFF7043), // laranja
    iconColor: Colors.white, // Cor do ícone branca
  );

  // Icone educação
  static const category_education = CustomIcons(
    icon: Icons.school, // Ícone de escola
    backgroundColor: Color(0xFF42A5F5), // azul
    iconColor: Colors.white, // Cor do ícone branca
  );

  // Icone transporte
  static const category_transport = CustomIcons(
    icon: Icons.directions_car, // Ícone de carro
    backgroundColor: Color(0xFF66BB6A), // verde
    iconColor: Colors.white, // Cor do ícone branca
  );

  // Icone lazer
  static const category_leisure = CustomIcons(
    icon: Icons.movie, // Ícone de filme
    backgroundColor: Color(0xFF7E57C2), // roxo
    iconColor: Colors.white, // Cor do ícone branca
  );

  // Icone saúde
  static const category_health = CustomIcons(
    icon: Icons.health_and_safety, // Ícone de saúde
    backgroundColor: Color.fromARGB(255, 231, 57, 54), // vermelho
    iconColor: Colors.white, // Cor do ícone branca
  );

  // Icone moradia
  static const category_housing = CustomIcons(
    icon: Icons.home, // Ícone de casa
    backgroundColor: Color.fromARGB(255, 214, 27, 152), // rosa
    iconColor: Colors.white, // Cor do ícone branca
  );

  // Icone outros
  static const category_others = CustomIcons(
    icon: Icons.category, // Ícone de categoria
    backgroundColor: Color.fromARGB(255, 120, 119, 119), // cinza
    iconColor: Colors.white, // Cor do ícone branca
  );
}