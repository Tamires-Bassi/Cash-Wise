import 'package:flutter/material.dart'; // Import do Flutter material
import 'package:provider/provider.dart'; // Import do Provider para gerenciamento de estado
import 'package:cloud_firestore/cloud_firestore.dart'; // Import do Firestore
import 'package:cash_wise/providers/transaction_provider.dart'; // Import do provider de transações
import 'package:cash_wise/icons/custom_icons.dart'; // Import dos ícones customizados
import 'package:cash_wise/models/transaction_model.dart'; // Necessário para o enum

class TransactionsListScreen extends StatelessWidget {
  const TransactionsListScreen({super.key});

  // Diálogo para editar uma transação
  // Permite atualizar dados na coleção 'transactions'
  void _showEditTransactionDialog(BuildContext context, String docId, String currentDesc) {
    final descController = TextEditingController(text: currentDesc);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title: const Text('Editar Transação', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: descController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Descrição',
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
              if (descController.text.isNotEmpty) {
                Provider.of<TransactionProvider>(context, listen: false)
                    .updateTransaction(docId, descController.text);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Transação atualizada!'), backgroundColor: Colors.green),
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
    final provider = Provider.of<TransactionProvider>(context, listen: false); // Acessa o provider

   // Construção da UI da tela 
   return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        elevation: 0,
        title: const Text('Todas as Transações'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: provider.transactionsStream,
        builder: (context, snapshot) {
          // Tratamento de estados 
          if (snapshot.connectionState == ConnectionState.waiting) { // Enquanto carrega
            return const Center(child: CircularProgressIndicator()); // Indicador de carregamento
          }
          // Se não houver dados ou estiver vazio
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) { 
            return const Center(child: Text('Nenhuma transação registrada.', style: TextStyle(color: Colors.white54)));
          }

          // Dados disponíveis
          final docs = snapshot.data!.docs;

          // Lista de transações
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final docId = docs[index].id; // ID para edição
              final isExpense = data['type'] == TransactionType.despesa.toString();

              return Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(color: Colors.grey[850], borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    CustomIcons(
                      icon: IconData(data['categoryIconCode'], fontFamily: 'MaterialIcons'),
                      backgroundColor: Color(data['categoryColorValue']),
                      iconColor: Colors.white,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data['description'], style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                          Text(data['categoryName'], style: const TextStyle(color: Colors.white70, fontSize: 14)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${isExpense ? '-' : '+'} R\$ ${(data['value'] as num).toStringAsFixed(2)}',
                          style: TextStyle(color: isExpense ? Colors.red[400] : Colors.green[400], fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        // Botão de Editar Transação
                        GestureDetector(
                          onTap: () => _showEditTransactionDialog(context, docId, data['description']),
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
    );
  }
}