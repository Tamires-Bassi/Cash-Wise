import 'package:flutter/material.dart'; // import do Flutter material
import 'package:provider/provider.dart'; // import do Provider para gerenciamento de estado
import 'package:cloud_firestore/cloud_firestore.dart'; // import do Firestore
import 'package:cash_wise/providers/transaction_provider.dart'; // import do provider de transações
import 'package:cash_wise/icons/custom_icons.dart'; // import dos ícones personalizados

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

// Tela de gerenciamento de contas bancárias
class _AccountsScreenState extends State<AccountsScreen> {
  
  // Lista de bancos pré-definidos
  final List<Map<String, dynamic>> bancos = [
    {'nome': 'Nubank', 'iconData': Icons.credit_card, 'color': const Color(0xFF820AD1)}, // Roxo
    {'nome': 'Itaú', 'iconData': Icons.credit_card, 'color': const Color(0xFFFF6200)}, // Laranja
    {'nome': 'Santander', 'iconData': Icons.credit_card, 'color': const Color(0xFFCC0000)}, // Vermelho
    {'nome': 'Banco do Brasil', 'iconData': Icons.credit_card, 'color': const Color(0xFFF6C324)}, // Amarelo
    {'nome': 'Outro', 'iconData': Icons.credit_card, 'color': Colors.grey},
  ];

  // Função para exibir o diálogo de adicionar conta
  void _showAddAccountDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final balanceController = TextEditingController();
    
    Map<String, dynamic>? selectedBank; // Banco selecionado

    // Exibe o diálogo
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.grey[850],
          title: const Text('Adicionar Conta', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dropdown de Bancos (Estilo visual limpo)
                  DropdownButtonFormField<Map<String, dynamic>>(
                    dropdownColor: Colors.grey[800],
                    decoration: InputDecoration(
                      labelText: 'Selecione o Banco',
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
                            Icon(banco['iconData'], color: banco['color']),
                            const SizedBox(width: 10),
                            Text(banco['nome']),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      selectedBank = value;
                      // Preenche o nome automaticamente se estiver vazio
                      if (nameController.text.isEmpty) {
                        nameController.text = value!['nome'];
                      }
                    },
                    // Validação para garantir que um banco seja selecionado
                    validator: (value) => value == null ? 'Selecione um banco' : null,
                  ),
                  const SizedBox(height: 15),

                  // Nome da Conta
                  TextFormField(
                    controller: nameController,
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
                    controller: balanceController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Saldo Inicial (R\$)',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white12,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    // Validação do campo de saldo
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Informe o saldo'; // Verifica se está vazio
                      if (double.tryParse(value.replaceAll(',', '.')) == null) return 'Valor inválido'; // Verifica se é um número válido
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            // Voltar e Salvar
            TextButton(
              onPressed: () => Navigator.pop(ctx), 
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)), // Botão de cancelar
            ),
            TextButton(
              onPressed: () {
                // Valida e salva a conta
                if (formKey.currentState!.validate()) {
                  final name = nameController.text;
                  final balance = double.parse(balanceController.text.replaceAll(',', '.'));
                  
                  // Salva no Firebase usando os dados simples
                  Provider.of<TransactionProvider>(context, listen: false).addAccount(
                    name,
                    balance,
                    (selectedBank!['iconData'] as IconData).codePoint, // Salva o ID do ícone
                    (selectedBank!['color'] as Color).value, // Salva a cor
                  );

                  Navigator.pop(ctx);
                }
              },
              child: const Text('Salvar', style: TextStyle(color: Color.fromARGB(255, 175, 47, 255))),
            ),
          ],
        );
      },
    );
  }

  // Diálogo para editar uma conta existente
  // Permite ao usuário atualizar dados na coleção 'accounts'

  void _showEditAccountDialog(BuildContext context, String accountId, String currentName) {
    final editController = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title: const Text('Editar Conta', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: editController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Nome da Conta',
            labelStyle: TextStyle(color: Colors.white70),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              if (editController.text.isNotEmpty) {
                // Chama o provider para atualizar no Firebase
                Provider.of<TransactionProvider>(context, listen: false)
                    .renameAccount(accountId, editController.text);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Conta atualizada!'), backgroundColor: Colors.green),
                );
              }
            },
            child: const Text('Salvar', style: TextStyle(color: Color.fromARGB(255, 175, 47, 255))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context, listen: false); // Acessa o provider de transações

    // Tela principal de contas
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
        backgroundColor: Color(0xFF6A1B9A),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showAddAccountDialog(context),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: provider.accountsStream,
                builder: (context, snapshot) {
                  // Tratamento de erros e estados de carregamento
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  // Verifica se há dados disponíveis
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'Nenhuma conta cadastrada.\nToque no + para adicionar.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  final docs = snapshot.data!.docs; // Documentos das contas

                  // Lista de contas
                  return ListView.separated(
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final accountId = docs[index].id; // ID do documento para edição

                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[850],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            // Ícone reconstruído de forma segura
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'R\$ ${(data['balance'] as num).toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                // Botão de Editar
                                GestureDetector(
                                  onTap: () => _showEditAccountDialog(context, accountId, data['name']),
                                  child: const Padding(
                                    padding: EdgeInsets.only(top: 4.0),
                                    child: Icon(Icons.edit, color: Colors.white54, size: 18),
                                  ),
                                ),
                              ],
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