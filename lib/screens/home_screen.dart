import 'package:flutter/material.dart'; // Import do Flutter material
import 'package:provider/provider.dart'; // Import do Provider para gerenciamento de estado
import 'package:cloud_firestore/cloud_firestore.dart'; // Import do Firestore
import 'package:cash_wise/providers/transaction_provider.dart'; // Import do provider de transações
import 'package:cash_wise/icons/custom_icons.dart'; // Import dos ícones customizados
import 'package:cash_wise/icons/app_icons.dart'; // Import dos ícones do app
import 'package:cash_wise/models/transaction_model.dart'; // Necessário para o enum
import 'package:cash_wise/widgets/currency_card.dart'; // Importe o widget de moeda

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState(); // Cria o estado do widget
}

// Tela inicial do aplicativo
class HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final provider = Provider.of<TransactionProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: size.height * 0.06,
              left: 20,
              right: 20,
              bottom: 20,
            ),
            child: Column(
              children: [
                // Botão de Pesquisa no topo à direita
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.search, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pushNamed(context, '/search'),
                  ),
                ),
                
                const Text('Saldo em Conta', style: TextStyle(fontSize: 14, color: Colors.white70)),
                const SizedBox(height: 5),
                
                // Valor total das contas
                StreamBuilder<QuerySnapshot>(
                  stream: provider.accountsStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) return const Text('Erro', style: TextStyle(color: Colors.white)); // Tratamento de erro
                    if (snapshot.connectionState == ConnectionState.waiting) { // Enquanto carrega
                      return const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2));
                    }

                    // Cálculo do saldo total
                    final total = snapshot.data!.docs.fold(0.0, (sum, doc) { 
                      return sum + (doc['balance'] as num).toDouble();
                    });

                    return Text(
                      'R\$ ${total.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                    );
                  },
                ),
              ],
            ),
          ),

          // Widget do cartão de moedas
          const CurrencyCard(), 

          const SizedBox(height: 10),

          // Cabeçalho da lista de transações recentes
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Transações Recentes', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/transactions_list'),
                  child: const Text('Ver todas', style: TextStyle(color: Colors.white70)),
                )
              ],
            ),
          ),

          // Lista de transações recentes
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: provider.transactionsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) { // Enquanto carrega
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) { // Se não houver dados
                  return const Center(child: Text('Nenhuma transação.', style: TextStyle(color: Colors.white54)));
                }

                final docs = snapshot.data!.docs.take(5).toList(); // Pega as 5 transações mais recentes

                // Lista de transações recentes
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: docs.length,
                  itemBuilder: (ctx, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final isExpense = data['type'] == TransactionType.despesa.toString();

                    // Cartão de transação
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12.0),
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
                          Text(
                            '${isExpense ? '-' : '+'} R\$ ${(data['value'] as num).toStringAsFixed(2)}',
                            style: TextStyle(
                              color: isExpense ? Colors.red[400] : Colors.green[400],
                              fontSize: 16, 
                              fontWeight: FontWeight.bold
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

      // Barra de navegação inferior
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[850],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          // Evita reabrir a mesma tela
          if (index == _currentIndex && index != 0) return;
          setState(() => _currentIndex = index);

          // Navegação para outras telas
          if (index == 1) {
            Navigator.pushNamed(context, '/accounts');
          } else if (index == 2) Navigator.pushNamed(context, '/add_transaction');
          else if (index == 3) Navigator.pushNamed(context, '/about');
          else if (index == 4) Navigator.pushNamed(context, '/categories');

          // Reseta o índice para Home após navegar
          if (index != 0) {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) setState(() => _currentIndex = 0);
            });
          }
        },
        // Itens da barra de navegação
        items: const [
          BottomNavigationBarItem(icon: AppIcons.home, label: 'Home'),
          BottomNavigationBarItem(icon: AppIcons.accounts, label: 'Contas'),
          BottomNavigationBarItem(icon: AppIcons.transaction, label: 'Transação'),
          BottomNavigationBarItem(icon: AppIcons.about, label: 'Sobre'),
          BottomNavigationBarItem(icon: AppIcons.categories, label: 'Categorias'),
        ],
      ),
    );
  }
}