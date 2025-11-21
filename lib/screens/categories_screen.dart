import 'package:flutter/material.dart'; // Import do Flutter material
import 'package:fl_chart/fl_chart.dart'; // Import do fl_chart para gráficos
import 'package:provider/provider.dart'; // Import do Provider para gerenciamento de estado
import 'package:cloud_firestore/cloud_firestore.dart'; // Import do Firestore
import 'package:cash_wise/providers/transaction_provider.dart'; // Import do provider de transações
import 'package:cash_wise/models/transaction_model.dart'; // Import do modelo de transação
import 'package:cash_wise/icons/custom_icons.dart'; // Import dos ícones personalizados

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => CategoriesScreenState(); // Cria o estado da tela
}

// Tela de categorias com gráfico de pizza e lista de categorias
class CategoriesScreenState extends State<CategoriesScreen> {
  int? categoriaSelecionada;
  
  // Variável para armazenar o Stream e evitar recargas desnecessárias
  late Stream<QuerySnapshot> _transactionsStream;

  @override
  void initState() {
    super.initState();
    // Inicializa o Stream apenas uma vez quando a tela abre
    _transactionsStream = Provider.of<TransactionProvider>(context, listen: false).transactionsStream;
  }

  // Função para agrupar dados por categoria
  List<Map<String, dynamic>> _agruparDados(List<QueryDocumentSnapshot> docs) {
    Map<String, Map<String, dynamic>> agrupado = {};

    // Agrupa os dados por categoria
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['type'] != TransactionType.despesa.toString()) continue; // Considera apenas despesas

      String catName = data['categoryName'];
      double valor = (data['value'] as num).toDouble();

      // Soma os valores por categoria
      if (agrupado.containsKey(catName)) {
        agrupado[catName]!['valor'] += valor;
      } else { // Cria nova entrada se a categoria não existir
        agrupado[catName] = {
          'valor': valor,
          'nome': catName,
          'colorValue': data['categoryColorValue'],
          'iconCode': data['categoryIconCode'],
        };
      }
    }
    return agrupado.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        elevation: 0,
        title: const Text('Gastos por Categoria'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // Usa a variável _transactionsStream em vez de chamar o provider direto
      body: StreamBuilder<QuerySnapshot>(
        stream: _transactionsStream, 
        builder: (context, snapshot) {
          // Tratamento de erros e estados de carregamento
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar dados.', style: TextStyle(color: Colors.white54)));
          }

          // Exibe indicador de carregamento enquanto aguarda os dados
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // Verifica se há dados disponíveis
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Nenhuma despesa registrada.', style: TextStyle(color: Colors.white54)));
          }
 
          final categorias = _agruparDados(snapshot.data!.docs); // Agrupa os dados por categoria

          // Verifica se há categorias após o agrupamento
          if (categorias.isEmpty) {
            return const Center(child: Text('Nenhuma despesa registrada.', style: TextStyle(color: Colors.white54)));
          }

          final total = categorias.fold(0.0, (sum, c) => sum + (c['valor'] as double)); // Calcula o total das despesas

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  height: 220,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, PieTouchResponse? response) {
                          // Só atualiza a tela se a seleção realmente mudar
                          if (!event.isInterestedForInteractions || response == null || response.touchedSection == null) {
                            if (categoriaSelecionada != null) {
                              setState(() => categoriaSelecionada = null);
                            }
                            return;
                          }
                          
                          // Atualiza a categoria selecionada
                          final newIndex = response.touchedSection!.touchedSectionIndex;
                          if (categoriaSelecionada != newIndex) {
                            setState(() => categoriaSelecionada = newIndex);
                          }
                        },
                      ),
                      sections: List.generate(categorias.length, (i) {
                        final cat = categorias[i];
                        final valor = cat['valor'] as double;
                        final porcentagem = total > 0 ? (valor / total * 100) : 0.0;
                        final isSelected = i == categoriaSelecionada;

                        return PieChartSectionData(
                          color: Color(cat['colorValue']),
                          value: valor,
                          title: '${porcentagem.toStringAsFixed(1)}%',
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          radius: isSelected ? 70 : 55,
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.separated(
                    itemCount: categorias.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final cat = categorias[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[850],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: categoriaSelecionada == index ? Color(cat['colorValue']) : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            CustomIcons(
                              icon: IconData(cat['iconCode'], fontFamily: 'MaterialIcons'),
                              backgroundColor: Color(cat['colorValue']),
                              iconColor: Colors.white,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                cat['nome'],
                                style: const TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ),
                            Text(
                              'R\$ ${(cat['valor'] as double).toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white70,
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
          );
        },
      ),
    );
  }
}