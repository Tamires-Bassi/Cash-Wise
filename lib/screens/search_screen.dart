import 'package:flutter/material.dart'; // Import do Flutter material
import 'package:provider/provider.dart'; // Import do Provider para gerenciamento de estado
import 'package:cloud_firestore/cloud_firestore.dart'; // Import do Firestore
import 'package:cash_wise/providers/transaction_provider.dart'; // Import do provider de transações
import 'package:cash_wise/models/transaction_model.dart'; // Necessário para o enum
import 'package:cash_wise/icons/custom_icons.dart'; // Import dos ícones customizados

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

// Tela para buscar transações
class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';
  bool _orderByValue = false; // Critério de ordenação (Data ou Valor)

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        title: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Pesquisar transação...',
            hintStyle: const TextStyle(color: Colors.white54),
            border: InputBorder.none,
            suffixIcon: _searchTerm.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white70),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchTerm = '');
                    },
                  )
                : null,
          ),
          onChanged: (value) {
            setState(() {
              _searchTerm = value.toLowerCase(); // Atualiza o termo de busca (case-insensitive)
            });
          },
        ),
        actions: [
          // Botão de Ordenação (Data ou Valor)
          PopupMenuButton<bool>(
            icon: const Icon(Icons.sort, color: Colors.white),
            onSelected: (bool byValue) {
              setState(() => _orderByValue = byValue);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: false, child: Text('Ordenar por Data')),
              const PopupMenuItem(value: true, child: Text('Ordenar por Valor')),
            ],
          ),
        ],
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
            return const Center(child: Text('Nenhum dado encontrado.', style: TextStyle(color: Colors.white54)));
          }

          // Filtra os documentos com base no termo de busca
          var docs = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final description = data['description'].toString().toLowerCase();
            return description.contains(_searchTerm);
          }).toList();

          // Ordenação dos resultados
          docs.sort((a, b) {
            final dataA = a.data() as Map<String, dynamic>;
            final dataB = b.data() as Map<String, dynamic>;

            if (_orderByValue) {
              // Ordena por Valor (do maior para o menor)
              double valA = (dataA['value'] as num).toDouble();
              double valB = (dataB['value'] as num).toDouble();
              return valB.compareTo(valA);
            } else {
              // Ordena por Data (mais recente primeiro)
              DateTime dateA = DateTime.parse(dataA['date']);
              DateTime dateB = DateTime.parse(dataB['date']);
              return dateB.compareTo(dateA);
            }
          });

          // Se nenhum resultado após o filtro
          if (docs.isEmpty) {
            return const Center(child: Text('Nenhum resultado para a busca.', style: TextStyle(color: Colors.white54)));
          }

          // Lista de transações filtradas e ordenadas
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final isExpense = data['type'] == TransactionType.despesa.toString();

              // Cartão de transação
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(12),
                ),
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
                    // Valor da transação
                    Text(
                      '${isExpense ? '-' : '+'} R\$ ${(data['value'] as num).toStringAsFixed(2)}',
                      style: TextStyle(
                        color: isExpense ? Colors.red[400] : Colors.green[400],
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
    );
  }
}