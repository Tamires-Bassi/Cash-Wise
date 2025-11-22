import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cash_wise/models/transaction_model.dart';

class TransactionProvider with ChangeNotifier {
  
  // Obtém o ID do usuário logado para garantir que cada um veja só seus dados (Segurança)
  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  // Monitora a coleção de contas do usuário em tempo real
  Stream<QuerySnapshot> get accountsStream {
    if (_uid == null) return const Stream.empty();
    return FirebaseFirestore.instance
        .collection('accounts')
        .where('userId', isEqualTo: _uid)
        .snapshots();
  }

  // Monitora a coleção de transações do usuário em tempo real
  // Ordena por data para mostrar as mais recentes primeiro
  Stream<QuerySnapshot> get transactionsStream {
    if (_uid == null) return const Stream.empty();
    return FirebaseFirestore.instance
        .collection('transactions')
        .where('userId', isEqualTo: _uid)
        .orderBy('date', descending: true)
        .snapshots();
  }

  // Adicionar uma nova transação e atualizar o saldo
  Future<void> addTransaction({
    required String description,
    required double value,
    required TransactionType type,
    required String categoryName,
    required int categoryIconCode, // Guardamos o código do ícone (int) para salvar no banco
    required int categoryColorValue, // Guardamos o valor da cor (int) para salvar no banco
    required String accountId, // ID da conta vinculada para descontar/somar o valor
  }) async {
    if (_uid == null) return;

    final txRef = FirebaseFirestore.instance.collection('transactions').doc();

    // Insere o documento na coleção 'transactions' (RF003)
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

    // tualiza o saldo da conta correspondente (RF004 - Atualização Automática)
    await _updateAccountBalance(accountId, value, type);
  }

  // Adicionar uma nova conta bancária
  Future<void> addAccount(String name, double initialBalance, int iconCode, int colorValue) async {
    if (_uid == null) return;
    
    final docRef = FirebaseFirestore.instance.collection('accounts').doc();
    // Insere o documento na coleção 'accounts' (RF003)
    await docRef.set({
      'id': docRef.id,
      'userId': _uid,
      'name': name,
      'balance': initialBalance,
      'iconCode': iconCode,
      'colorValue': colorValue,
    });
  }

  // Função auxiliar: Atualiza o saldo da conta quando uma transação é criada
  Future<void> _updateAccountBalance(String accountId, double value, TransactionType type) async {
    final accountRef = FirebaseFirestore.instance.collection('accounts').doc(accountId);

    // Usa "Transaction" do Firestore para garantir atomicidade (segurança dos dados)
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(accountRef);
      if (!snapshot.exists) return;

      double currentBalance = (snapshot.data()?['balance'] ?? 0.0).toDouble();
      
      // Calcula o novo saldo
      double newBalance = type == TransactionType.despesa 
          ? currentBalance - value 
          : currentBalance + value;

      // Realiza o update no campo 'balance'
      transaction.update(accountRef, {'balance': newBalance});
    });
  }

  // Função para renomear uma conta
  Future<void> renameAccount(String accountId, String newName) async {
    if (_uid == null) return;

    await FirebaseFirestore.instance
        .collection('accounts')
        .doc(accountId)
        .update({'name': newName});
  }
}