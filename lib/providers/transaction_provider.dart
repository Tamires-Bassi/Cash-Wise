import 'package:flutter/material.dart'; // Importa o Flutter Material
import 'package:cash_wise/models/transaction_model.dart'; // Importe o modelo criado acima
import 'package:cash_wise/models/account_model.dart'; // Importe o modelo criado acima
import 'dart:math'; // Para gerar IDs aleatórios

class TransactionProvider with ChangeNotifier { // Provider para gerenciar o estado das transações e contas
  
  // Dados simulados de contas bancárias
  final List<Account> _accounts = [
    Account(
      id: '1',
      name: 'Nubank',
      balance: 12.30,
      icon: Icons.credit_card,
      color: const Color(0xFF8A05BE),
    ),
    Account(
      id: '2',
      name: 'Itaú',
      balance: 340.10,
      icon: Icons.credit_card,
      color: const Color(0xFFED8B00),
    ),
    Account(
      id: '3',
      name: 'Santander',
      balance: 80.00,
      icon: Icons.credit_card,
      color: const Color(0xFFE60014),
    ),
    Account(
      id: '4',
      name: 'Outro',
      balance: 0.00,
      icon: Icons.account_balance_wallet,
      color: const Color.fromARGB(255, 56, 55, 56),
    ),
  ];

  // Lista privada de transações
  final List<Transaction> _transactions = [
    Transaction( // Exemplo de transação 1
      id: 't1',
      description: 'Bolsa Monitoria',
      value: 700.00,
      type: TransactionType.receita,
      categoryName: 'Salário',
      categoryIconData: Icons.trending_up,
      categoryColor: const Color.fromARGB(255, 10, 94, 45),
      accountName: 'Nubank',
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Transaction( // Exemplo de transação 2
      id: 't2',
      description: 'Almoço IFSP',
      value: 15.00,
      type: TransactionType.despesa,
      categoryName: 'Alimentação',
      categoryIconData: Icons.fastfood,
      categoryColor: const Color(0xFFFF7043),
      accountName: 'Nubank',
      date: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    Transaction( // Exemplo de transação 3
      id: 't3',
      description: 'Gasolina',
      value: 100.00,
      type: TransactionType.despesa,
      categoryName: 'Transporte',
      categoryIconData: Icons.directions_car,
      categoryColor: const Color(0xFF66BB6A),
      accountName: 'Itaú',
      date: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  // Getters para acessar as listas de transações e contas
  List<Transaction> get transactions {
    final sortedList = List.of(_transactions);
    sortedList.sort((a, b) => b.date.compareTo(a.date)); // Ordena por data decrescente
    return sortedList;
  }

  List<Account> get accounts => _accounts; // Retorna a lista de contas

  // Calcula o saldo total de todas as contas
  double get totalBalance {
    return _accounts.fold(0.0, (sum, account) => sum + account.balance); // Soma os saldos de todas as contas
  }

  // Função para adicionar transação e atualizar saldo da conta
  void addTransaction({
    required String description,
    required double value,
    required TransactionType type,
    required String categoryName,
    required IconData categoryIconData,
    required Color categoryColor,
    required String accountName,
  }) {
    
    // Encontrar o índice da conta associada à transação
    final accountIndex = _accounts.indexWhere((a) => a.name == accountName); // Encontrar a conta pelo nome

    if (accountIndex != -1) { // Se a conta for encontrada
      if (type == TransactionType.despesa) { // Se for despesa, subtrai do saldo
        _accounts[accountIndex].balance -= value; // Atualiza o saldo da conta
      } else {
        _accounts[accountIndex].balance += value; // Se for receita, adiciona ao saldo
      }
    }

    // Cria uma nova transação
    final newTransaction = Transaction(
      id: Random().nextDouble().toString(), // Gera um ID aleatório simples
      description: description,
      value: value,
      type: type,
      categoryName: categoryName,
      categoryIconData: categoryIconData,
      categoryColor: categoryColor,
      accountName: accountName,
      date: DateTime.now(),
    );

    // Adiciona a nova transação à lista
    _transactions.add(newTransaction);
    notifyListeners(); // Notifica os ouvintes sobre a mudança de estado
  }
}