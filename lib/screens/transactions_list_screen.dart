import 'package:flutter/material.dart'; // Import do Flutter material
import 'package:provider/provider.dart'; // Import do Provider para gerenciamento de estado
import 'package:cloud_firestore/cloud_firestore.dart'; // Import do Firestore
import 'package:cash_wise/providers/transaction_provider.dart'; // Import do provider de transações
import 'package:cash_wise/icons/custom_icons.dart'; // Import dos ícones customizados
import 'package:cash_wise/models/transaction_model.dart'; // Necessário para o enum

class TransactionsListScreen extends StatelessWidget {
  const TransactionsListScreen({super.key});

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
                    Text(
                      '${isExpense ? '-' : '+'} R\$ ${(data['value'] as num).toStringAsFixed(2)}',
                      style: TextStyle(color: isExpense ? Colors.red[400] : Colors.green[400], fontSize: 16, fontWeight: FontWeight.bold),
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