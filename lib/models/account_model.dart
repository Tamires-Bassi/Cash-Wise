import 'package:flutter/material.dart'; // Importa o Flutter Material

class Account { // Modelo de Conta Bancária
  final String id;
  final String name;
  double balance; // O saldo não é final, pois vai mudar
  final IconData icon;
  final Color color;

  Account({
    required this.id,
    required this.name,
    required this.balance,
    required this.icon,
    required this.color,
  });
}