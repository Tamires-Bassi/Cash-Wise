import 'package:flutter/material.dart'; // Import do Flutter material
import 'package:fl_chart/fl_chart.dart'; // Import do fl_chart para gráficos
import 'package:provider/provider.dart'; // Import do Provider para gerenciamento de estado
import 'package:cloud_firestore/cloud_firestore.dart'; // Import do Firestore
import 'package:cash_wise/providers/transaction_provider.dart'; // Import do provider de transações
import 'package:cash_wise/models/transaction_model.dart'; // Necessário para o enum
import 'package:cash_wise/icons/custom_icons.dart'; // Import dos ícones customizados

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => CategoriasScreenState(); // Cria o estado do widget
}

// Tela para visualizar gastos por categoria
class CategoriasScreenState extends State<CategoriesScreen> {
  int? categoriaSelecionada; 

  // Função auxiliar para agrupar dados do Firestore
  List<Map<String, dynamic>> _agruparDados(List<QueryDocumentSnapshot> docs) {
    Map<String, Map<String, dynamic>> agrupado = {}; // Mapa temporário

    // Agrupa os dados por categoria
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      // Filtra apenas despesas (pois gráfico de gastos geralmente é só despesa)
      if (data['type'] != TransactionType.despesa.toString()) continue;

      String catName = data['categoryName'];
      double valor = (data['value'] as num).toDouble();

      // Agrupa os valores por categoria
      if (agrupado.containsKey(catName)) {
        agrupado[catName]!['valor'] += valor;
      } else { // Nova categoria
        agrupado[catName] = {
          'valor': valor,
          'nome': catName,
          'colorValue': data['categoryColorValue'],
          'iconCode': data['categoryIconCode'],
        };
      }
    }
    return agrupado.values.toList(); // Retorna como lista
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
        title: const Text('Gastos por Categoria'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: provider.transactionsStream,
        builder: (context, snapshot) {
          // Verifica se houve erro na conexão
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Erro ao carregar dados.',
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
            );
          }

          // Mostra loading apenas se estiver aguardando e não tiver dados ainda
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Verifica se a lista de documentos está vazia ou nula
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Nenhuma despesa registrada.',
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
            );
          }

          // Processa os dados
          final categorias = _agruparDados(snapshot.data!.docs);

          // Verifica se após filtrar (só despesas) a lista ficou vazia
          if (categorias.isEmpty) {
            return const Center(
              child: Text(
                'Nenhuma despesa registrada.',
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
            );
          }

          final total = categorias.fold(0.0, (sum, c) => sum + (c['valor'] as double)); // Calcula o total

          // Construção do gráfico e da lista
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
                        touchCallback: (event, response) {
                          // Atualiza a categoria selecionada ao tocar
                          if (!event.isInterestedForInteractions || response == null || response.touchedSection == null) {
                            setState(() => categoriaSelecionada = null); // Deseleciona se tocar fora
                            return;
                          }
                          // Seleciona a categoria tocada
                          setState(() {
                            categoriaSelecionada = response.touchedSection!.touchedSectionIndex;
                          });
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
                
                // Lista de Legenda
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