import 'package:flutter/material.dart'; // Importa o pacote Material, que contém todos os widgets básicos do Flutter

enum TransactionType { // Define os tipos de transação
  despesa,
  receita,
}

class Transaction { // Modelo de dados para uma transação
  final String id; // Identificador único da transação
  final String description; // Descrição da transação
  final double value; // Valor da transação
  final TransactionType type; // Tipo da transação (despesa ou receita)
  final String categoryName; // Nome da categoria da transação
  final IconData categoryIconData; // Para exibir o ícone
  final Color categoryColor; // Para exibir a cor do ícone
  final String accountName; // Nome da conta associada à transação
  final DateTime date; // Data da transação

  Transaction({ // Construtor da classe Transaction
    required this.id, // Identificador único
    required this.description, // Descrição
    required this.value, // Valor
    required this.type, // Tipo
    required this.categoryName, // Nome da categoria
    required this.categoryIconData, // Ícone da categoria
    required this.categoryColor, // Cor da categoria
    required this.accountName, // Nome da conta
    required this.date, // Data
  });
}