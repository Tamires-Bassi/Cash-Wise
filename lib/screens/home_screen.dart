import 'package:flutter/material.dart'; // Importa o Flutter Material
import 'package:provider/provider.dart'; // Importa o Provider
import 'package:cash_wise/providers/transaction_provider.dart'; // Importa o seu Provider
import 'package:cash_wise/models/transaction_model.dart'; // Importa o Modelo de Transação
import 'package:cash_wise/icons/custom_icons.dart'; // Importa seus ícones personalizados
import 'package:cash_wise/icons/app_icons.dart'; // Importa seus ícones do App

class HomeScreen extends StatefulWidget {// Define um widget com estado para a tela inicial
  const HomeScreen({super.key}); 

  @override
  State<HomeScreen> createState() => HomeScreenState(); // Cria o estado do widget
}

class HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; // Índice para a navegação inferior

  @override
  Widget build(BuildContext context) { // Método build para construir a interface do usuário
    final size = MediaQuery.of(context).size;
    final screenHeight = size.height;
    final screenWidth = size.width;

    // Obtém a instância do TransactionProvider
    final transactionProvider = Provider.of<TransactionProvider>(context);
    
    // Obtém o saldo total calculado no Provider (soma de todas as contas)
    final saldoTotal = transactionProvider.totalBalance; 
    
    // Obtém a lista de transações recentes (limitada a 5)
    final recentTransactions = transactionProvider.transactions.take(5).toList();

    return Scaffold( // Scaffold fornece a estrutura básica da tela
      backgroundColor: Colors.grey[900],
      body: Column(
        children: [
          // Cabeçalho com Saldo Total
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.05,
              horizontal: screenWidth * 0.07,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.06),
                Center(
                  child: Column(
                    children: [
                      const Text(
                        'Saldo em Conta',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Exibe o saldo total formatado
                      Text(
                        'R\$ ${saldoTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 10), // Espaçamento

          // Seção de Transações Recentes
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Transações Recentes',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600),
                ),
                TextButton(
                  onPressed: () {
                    // Navega para a tela com a lista completa de transações
                    Navigator.pushNamed(context, '/transactions_list');
                  },
                  child: const Text(
                    'Ver todas',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              ],
            ),
          ),

          // Lista de Transações Recentes
          Expanded(
            child: recentTransactions.isEmpty // Verifica se não há transações recentes
                ? const Center(
                    child: Text(
                      'Nenhuma transação recente.',
                      style: TextStyle(color: Colors.white54, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: recentTransactions.length,
                    itemBuilder: (ctx, index) {
                      final tx = recentTransactions[index]; // Obtém a transação atual
                      final bool isExpense = tx.type == TransactionType.despesa; // Verifica se é despesa

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12.0),
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[850],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            // Ícone da Categoria
                            CustomIcons(
                              icon: tx.categoryIconData,
                              backgroundColor: tx.categoryColor,
                              iconColor: Colors.white,
                            ),
                            const SizedBox(width: 16),
                            // Detalhes da Transação
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
                            // Valor da Transação
                            Text(
                              '${isExpense ? '-' : '+'} R\$ ${tx.value.toStringAsFixed(2)}', // Formata o valor com sinal
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
        ],
      ),

      // Barra de Navegação Inferior
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[850],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          // Evita recarregar a mesma aba se já estiver selecionada 
          if (index == _currentIndex && index != 0) return;
          
          setState(() {
            _currentIndex = index;
          });

          // Lógica de Navegação
          if (index == 1) {
            Navigator.pushNamed(context, '/accounts');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/add_transaction');
          } else if (index == 3) {
            Navigator.pushNamed(context, '/about');
          } else if (index == 4) {
            Navigator.pushNamed(context, '/categories');
          }

          // Reseta o índice para a Home (0) após navegar para outra tela e voltar
          if (index != 0) {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                setState(() {
                  _currentIndex = 0;
                });
              }
            });
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: AppIcons.home,
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: AppIcons.accounts,
            label: 'Contas',
          ),
          BottomNavigationBarItem(
            icon: AppIcons.transaction,
            label: 'Transação',
          ),
          BottomNavigationBarItem(
            icon: AppIcons.about,
            label: 'Sobre',
          ),
          BottomNavigationBarItem(
            icon: AppIcons.categories,
            label: 'Categorias',
          ),
        ],
      ),
    );
  }
}