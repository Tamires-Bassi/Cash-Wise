import 'package:flutter/material.dart'; // Importa o pacote Material, que contém todos os widgets básicos do Flutter
import 'package:provider/provider.dart'; // Importa o Provider
import 'package:cash_wise/providers/transaction_provider.dart'; // Importa o TransactionProvider
import 'package:cash_wise/models/transaction_model.dart'; // Importa o modelo de transação
import 'package:cash_wise/icons/custom_icons.dart'; // Importa o widget CustomIcons

class TransactionsListScreen extends StatelessWidget {
  const TransactionsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtém a lista de transações do provedor
    final transactions =
        Provider.of<TransactionProvider>(context).transactions; // Lista de transações

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        elevation: 0,
        title: const Text('Todas as Transações'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // Verifica se a lista de transações está vazia
        child: transactions.isEmpty
            ? const Center(
                child: Text(
                  'Nenhuma transação registrada.',
                  style: TextStyle(color: Colors.white54, fontSize: 16),
                ),
              )
            : ListView.separated( // Lista de transações
                itemCount: transactions.length, // Número de transações
                separatorBuilder: (context, index) => // Separador entre os itens
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  //
                  final tx = transactions[index]; // Transação atual
                  final bool isExpense = tx.type == TransactionType.despesa; // Verifica se é despesa

                  return Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        // Ícone da categoria
                        CustomIcons(
                          icon: tx.categoryIconData,
                          backgroundColor: tx.categoryColor,
                          iconColor: Colors.white,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tx.description,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500),
                              ),
                              Text(
                                tx.categoryName,
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        // Valor
                        Text(
                          '${isExpense ? '-' : '+'} R\$ ${tx.value.toStringAsFixed(2)}', // Formata o valor com 2 casas decimais
                          style: TextStyle(
                            color: isExpense
                                ? Colors.red[400]
                                : Colors.green[400],
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}