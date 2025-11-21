import 'package:flutter/material.dart'; // Import do Flutter material
import 'package:provider/provider.dart'; // Import do Provider para gerenciamento de estado
import 'package:cloud_firestore/cloud_firestore.dart'; // Import do Firestore
import 'package:cash_wise/providers/transaction_provider.dart'; // Import do provider de transações
import 'package:cash_wise/icons/custom_icons.dart'; // Import dos ícones customizados
import 'package:cash_wise/icons/app_icons.dart'; // Import dos ícones do app

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState(); // Cria o estado do widget
}

// Tela para gerenciar contas
class _AccountsScreenState extends State<AccountsScreen> {
  
  // Função para abrir o Diálogo de Cadastro
  void _showAddAccountDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _balanceController = TextEditingController();
    
    // Lista de opções usando os ícones que você já criou
    final List<Map<String, dynamic>> bancos = [
      {'nome': 'Nubank', 'widget': AppIcons.cards_nubank},
      {'nome': 'Itaú', 'widget': AppIcons.cards_itau},
      {'nome': 'Santander', 'widget': AppIcons.cards_santander},
      {'nome': 'Banco do Brasil', 'widget': AppIcons.cards_banco_do_brasil},
      {'nome': 'Outro', 'widget': AppIcons.cards_others},
    ];

    Map<String, dynamic>? _selectedBank; // Banco selecionado

    // Exibe o diálogo
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.grey[850],
          title: const Text('Adicionar Conta', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. Seletor de Banco
                  DropdownButtonFormField<Map<String, dynamic>>(
                    dropdownColor: Colors.grey[800],
                    decoration: InputDecoration(
                      labelText: 'Banco',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white12,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    style: const TextStyle(color: Colors.white),
                    items: bancos.map((banco) {
                      return DropdownMenuItem(
                        value: banco,
                        child: Row(
                          children: [
                            // Exibe o ícone do AppIcons
                            banco['widget'] as Widget,
                            const SizedBox(width: 10),
                            Text(banco['nome']),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      _selectedBank = value;
                      // Preenche o nome automaticamente se o campo estiver vazio
                      if (_nameController.text.isEmpty) {
                        _nameController.text = value!['nome'];
                      }
                    },
                    // validator para garantir que um banco seja selecionado
                    validator: (value) => value == null ? 'Selecione um banco' : null,
                  ),
                  const SizedBox(height: 15),

                  // Nome da Conta (Editável)
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Nome da Conta',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white12,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    validator: (value) => value!.isEmpty ? 'Informe um nome' : null,
                  ),
                  const SizedBox(height: 15),

                  // Saldo Inicial
                  TextFormField(
                    controller: _balanceController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Saldo Inicial (R\$)',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white12,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    validator: (value) {
                      // Validação do saldo
                      if (value == null || value.isEmpty) return 'Informe o saldo'; // Obrigatório
                      if (double.tryParse(value.replaceAll(',', '.')) == null) return 'Valor inválido'; // Deve ser numérico
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            // Cancelar e Salvar
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                // Valida e salva a conta
                if (_formKey.currentState!.validate()) {
                  final name = _nameController.text; // Nome da conta
                  final balance = double.parse(_balanceController.text.replaceAll(',', '.')); // Saldo inicial
                  
                  // Extrai os dados do CustomIcons para salvar no banco
                  // Precisamos fazer um cast para acessar as propriedades do widget
                  final CustomIcons iconWidget = _selectedBank!['widget'] as CustomIcons;

                  // Chama o método do provider para adicionar a conta
                  Provider.of<TransactionProvider>(context, listen: false).addAccount(
                    name,
                    balance,
                    iconWidget.icon.codePoint, // Salva o ID do ícone
                    iconWidget.backgroundColor?.value ?? Colors.grey.value, // Salva a cor
                  );

                  Navigator.pop(ctx); // Fecha o diálogo
                }
              },
              child: const Text('Salvar', style: TextStyle(color: Colors.purpleAccent)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context, listen: false);

    // Construção da UI da tela
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        elevation: 0,
        title: const Text('Minhas Contas'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showAddAccountDialog(context), // Chama o diálogo
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: provider.accountsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'Nenhuma conta cadastrada.\nToque em + para adicionar.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  // Dados disponíveis
                  final docs = snapshot.data!.docs;

                  // Lista de contas
                  return ListView.separated(
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[850],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            // Recria o ícone com os dados do Firebase
                            CustomIcons(
                              icon: IconData(data['iconCode'], fontFamily: 'MaterialIcons'),
                              backgroundColor: Color(data['colorValue']),
                              iconColor: Colors.white,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                data['name'],
                                style: const TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ),
                            Text(
                              'R\$ ${(data['balance'] as num).toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}