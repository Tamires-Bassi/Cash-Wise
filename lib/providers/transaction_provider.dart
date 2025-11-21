import 'package:flutter/material.dart'; // Import do Flutter material
import 'package:cloud_firestore/cloud_firestore.dart'; // Import do Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Import do Firebase Auth
import 'package:cash_wise/models/transaction_model.dart'; // Import do modelo de transação

class TransactionProvider with ChangeNotifier {
  // Obtém o ID do usuário logado para garantir que cada um veja só seus dados
  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  // Monitora a coleção de contas do usuário
  Stream<QuerySnapshot> get accountsStream { 
    if (_uid == null) return const Stream.empty(); // Se não houver usuário logado, retorna stream vazia
    return FirebaseFirestore.instance 
        .collection('accounts')
        .where('userId', isEqualTo: _uid)
        .snapshots();
  }

  // Monitora a coleção de transações do usuário
  Stream<QuerySnapshot> get transactionsStream {
    if (_uid == null) return const Stream.empty(); // Se não houver usuário logado, retorna stream vazia
    return FirebaseFirestore.instance
        .collection('transactions')
        .where('userId', isEqualTo: _uid)
        .orderBy('date', descending: true) // Mais recentes primeiro
        .snapshots();
  }

  // Adicionar uma nova transação
  Future<void> addTransaction({
    required String description,
    required double value,
    required TransactionType type,
    required String categoryName,
    required int categoryIconCode, // Guardamos o código do ícone (int)
    required int categoryColorValue, // Guardamos o valor da cor (int)
    required String accountId, // ID da conta vinculada
  }) async {
    if (_uid == null) return; // Se não houver usuário logado, não faz nada

    final txRef = FirebaseFirestore.instance.collection('transactions').doc(); // Cria uma nova referência de documento

    // Salva a transação no Firestore
    await txRef.set({
      'id': txRef.id,
      'userId': _uid,
      'description': description,
      'value': value,
      'type': type.toString(), // Ex: "TransactionType.despesa"
      'categoryName': categoryName,
      'categoryIconCode': categoryIconCode,
      'categoryColorValue': categoryColorValue,
      'accountId': accountId,
      'date': DateTime.now().toIso8601String(),
    });

    // Atualiza o saldo da conta correspondente
    await _updateAccountBalance(accountId, value, type);
  }

  // Função auxiliar para atualizar o saldo da conta
  Future<void> _updateAccountBalance(String accountId, double value, TransactionType type) async {
    final accountRef = FirebaseFirestore.instance.collection('accounts').doc(accountId);

    // Usa Transaction do Firestore para segurança
    await FirebaseFirestore.instance.runTransaction((transaction) async { 
      final snapshot = await transaction.get(accountRef);
      if (!snapshot.exists) return; // Se a conta não existir, sai

      double currentBalance = (snapshot.data()?['balance'] ?? 0.0).toDouble(); // Saldo atual
      
      // Calcula novo saldo
      double newBalance = type == TransactionType.despesa 
          ? currentBalance - value 
          : currentBalance + value;

      transaction.update(accountRef, {'balance': newBalance}); // Atualiza o saldo
    });
  }

  // Adicionar uma conta inicial (Útil para o primeiro uso)
  Future<void> addAccount(String name, double initialBalance, int iconCode, int colorValue) async {
    if (_uid == null) return; // Se não houver usuário logado, não faz nada
    
    // Cria uma nova conta no Firestore
    final docRef = FirebaseFirestore.instance.collection('accounts').doc();
    await docRef.set({
      'id': docRef.id,
      'userId': _uid,
      'name': name,
      'balance': initialBalance,
      'iconCode': iconCode,
      'colorValue': colorValue,
    });
  }
}