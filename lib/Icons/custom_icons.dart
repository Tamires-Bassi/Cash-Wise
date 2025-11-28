import 'package:flutter/material.dart'; // Importa o pacote Material, que contém todos os widgets básicos do Flutter

class CustomIcons extends StatelessWidget { // Define a classe CustomIcons que não vai guardar estado interno
  final IconData icon; // Ícone personalizado
  final Color? backgroundColor; // Cor de fundo do ícone
  final Color iconColor; // Cor do ícone
  final double size; // Tamanho do ícone
  final double padding; // Espaçamento interno do ícone
  final bool showBackground; // Se deve mostrar o fundo

  const CustomIcons({
    super.key, // Construtor da classe
    required this.icon, // Ícone obrigatório
    this.backgroundColor, // Cor de fundo opcional
    this.iconColor = Colors.white, // Cor do ícone padrão branca
    this.size = 24.0, // Tamanho padrão do ícone
    this.padding = 10.0, // Espaçamento interno padrão
    this.showBackground = true, // Mostrar fundo por padrão
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding), // Espaçamento interno
      decoration: showBackground // Se deve mostrar o fundo
         ? BoxDecoration(
            color: backgroundColor ?? Colors.transparent, // Cor de fundo ou transparente
            shape: BoxShape.circle, // Formato circular
         )
        : null, // Sem decoração se não mostrar o fundo 

        child: Icon(
          icon, // Ícone personalizado
          color: iconColor, // Cor do ícone
          size: size, // Tamanho do ícone
        ),
    );
  }
}