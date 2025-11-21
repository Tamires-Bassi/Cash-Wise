import 'package:flutter/material.dart'; // Importa o Flutter Material
import 'package:provider/provider.dart'; // Importe o provider
import 'package:cash_wise/providers/transaction_provider.dart'; // Importe o seu Provider
import 'package:cash_wise/icons/custom_icons.dart'; // Seus ícones customizados

class AccountsScreen extends StatelessWidget { // Tela para exibir as contas bancárias
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Consumindo os dados do Provider
    final provider = Provider.of<TransactionProvider>(context);
    final accounts = provider.accounts;
    final totalBalance = provider.totalBalance;

    return Scaffold( // Scaffold fornece a estrutura básica da tela
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        elevation: 0,
        title: const Text('Contas'),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Saldo Total',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 4),
            // Exibindo o saldo total real calculado pelo Provider
            Text(
              'R\$ ${totalBalance.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 32,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Suas Contas',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            const SizedBox(height: 16),
            
            Expanded( // Expande para preencher o espaço disponível
              child: ListView.separated(
                itemCount: accounts.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final account = accounts[index];
                  
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CustomIcons(
                           icon: account.icon,
                           backgroundColor: account.color,
                           iconColor: Colors.white,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            account.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        // Exibindo o saldo individual da conta
                        Text(
                          'R\$ ${account.balance.toStringAsFixed(2)}',
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}