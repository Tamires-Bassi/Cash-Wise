import 'package:flutter/material.dart'; // Import do Flutter material
import 'package:http/http.dart' as http; // Import do HTTP
import 'dart:convert'; // Import do JSON

class CurrencyCard extends StatelessWidget {
  const CurrencyCard({super.key});

  // Função para buscar cotações de moedas
  Future<Map<String, dynamic>> fetchCurrencies() async {
    final response = await http.get(Uri.parse('https://economia.awesomeapi.com.br/last/USD-BRL,EUR-BRL'));
    
    // Verifica se a resposta foi bem-sucedida
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Falha ao carregar cotações');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Construção do widget com FutureBuilder
    return FutureBuilder<Map<String, dynamic>>(
      future: fetchCurrencies(),
      builder: (context, snapshot) {
        // Tratamento de estados
        if (snapshot.hasError) {
          return const SizedBox.shrink(); // Se der erro, esconde o card
        }
        
        // Valores padrão enquanto carrega
        String usd = '...';
        String eur = '...';

        // Se os dados foram carregados com sucesso
        if (snapshot.hasData) {
          usd = double.parse(snapshot.data!['USDBRL']['bid']).toStringAsFixed(2); 
          eur = double.parse(snapshot.data!['EURBRL']['bid']).toStringAsFixed(2);
        }

        // Card de moedas
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCurrencyItem('USD', 'R\$ $usd', Icons.attach_money),
              Container(width: 1, height: 30, color: Colors.white24), // Divisor
              _buildCurrencyItem('EUR', 'R\$ $eur', Icons.euro),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCurrencyItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.greenAccent, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ],
    );
  }
}