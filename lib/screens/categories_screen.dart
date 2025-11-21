import 'package:flutter/material.dart'; // Importa o pacote Material, que contém todos os widgets básicos do Flutter
import 'package:fl_chart/fl_chart.dart'; // Pacote de gráfico
import 'package:provider/provider.dart'; // Importa o Provider
import 'package:cash_wise/providers/transaction_provider.dart'; // Importa o TransactionProvider
import 'package:cash_wise/models/transaction_model.dart'; // Importa o modelo de transação
import 'package:cash_wise/icons/custom_icons.dart'; // Importa o widget CustomIcons

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => CategoriasScreenState(); // Cria o estado mutável da tela
}

class CategoriasScreenState extends State<CategoriesScreen> {
  int? categoriaSelecionada; // índice da categoria tocada

  // Esta função irá agrupar as transações e calcular os totais
  Map<String, Map<String, dynamic>> _processarTransacoes(
      List<Transaction> transacoes) {
    // Filtra apenas as despesas
    final despesas =
        transacoes.where((tx) => tx.type == TransactionType.despesa).toList(); // Lista de despesas

    // Agrupa as despesas por categoria
    Map<String, Map<String, dynamic>> gastosPorCategoria = {}; // Mapa para armazenar os gastos por categoria

    for (var tx in despesas) { // Itera sobre cada despesa
      if (gastosPorCategoria.containsKey(tx.categoryName)) { 
        // Se a categoria já existe no mapa, soma o valor
        gastosPorCategoria[tx.categoryName]!['valor'] += tx.value; 
      } else {
        // Se é a primeira vez, adiciona a categoria ao mapa
        gastosPorCategoria[tx.categoryName] = {
          'valor': tx.value,
          // Recria o CustomIcons com base nos dados do modelo
          'icone': CustomIcons(
            icon: tx.categoryIconData,
            backgroundColor: tx.categoryColor,
            iconColor: Colors.white,
          ),
          'nome': tx.categoryName,
          'cor': tx.categoryColor,
        };
      }
    }
    return gastosPorCategoria;
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context); // Obtém o provedor de transações
    final gastosAgrupados = _processarTransacoes(transactionProvider.transactions); // Agrupa as transações
    final categorias = gastosAgrupados.values.toList(); // Converte os valores do mapa em uma lista
    final total = categorias.fold(0.0, (sum, c) => sum + (c['valor'] as double)); // Calcula o total geral

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        surfaceTintColor: Colors.grey[900],
        elevation: 0,
        title: const Text('Gastos por categoria'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context); // Volta para a tela anterior
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Gráfico de pizza
            SizedBox(
              height: 220,
              child: categorias.isEmpty // Verifica se há categorias
                  ? const Center(
                      child: Text('Nenhuma despesa registrada.',
                          style: TextStyle(color: Colors.white54, fontSize: 16)))
                  : PieChart( // Exibe o gráfico de pizza
                      PieChartData(
                        sectionsSpace: 2, // Espaço entre as seções
                        centerSpaceRadius: 40, // Raio do espaço central
                        pieTouchData: PieTouchData( // Dados de toque no gráfico
                          touchCallback: (event, response) { // Callback de toque
                            if (!event.isInterestedForInteractions || // Se o toque não é relevante
                                response == null || // Se a resposta é nula
                                response.touchedSection == null) { // Se nenhuma seção foi tocada
                              setState(() => categoriaSelecionada = null); // Reseta a seleção
                              return;
                            }
                            setState(() { // Atualiza o estado com a seção tocada
                              categoriaSelecionada =
                                  response.touchedSection!.touchedSectionIndex;
                            });
                          },
                        ),
                        sections: List.generate(categorias.length, (i) { // Gera as seções do gráfico
                          final categoria = categorias[i]; // Categoria atual
                          final valor = categoria['valor'] as double; // Valor da categoria
                          // Evita divisão por zero se o total for 0
                          final porcentagem = total > 0 ? (valor / total * 100) : 0.0;
                          final bool selecionada = i == categoriaSelecionada; // Verifica se a categoria está selecionada

                          return PieChartSectionData( // Dados da seção do gráfico
                            color: categoria['cor'] as Color,
                            value: valor,
                            title: '${porcentagem.toStringAsFixed(1)}%',
                            titleStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            radius: selecionada ? 70 : 55,
                          );
                        }),
                      ),
                    ),
            ),

            const SizedBox(height: 20),

            // Texto da categoria selecionada
            if (categoriaSelecionada != null && // Verifica se há uma categoria selecionada
                categoriaSelecionada! >= 0 && // Verifica se o índice é válido
                categoriaSelecionada! < categorias.length) ...[ // Evita erro de índice fora do intervalo
              Text(
                categorias[categoriaSelecionada!]['nome'], // Nome da categoria selecionada
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'R\$ ${categorias[categoriaSelecionada!]['valor'].toStringAsFixed(2)}', // Valor formatado
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Lista de categorias
            Expanded(
              child: ListView.separated( // Lista de categorias com separadores
                itemCount: categorias.length, // Número de categorias
                separatorBuilder: (context, index) => // Separador entre os itens
                    const SizedBox(height: 12),
                itemBuilder: (context, index) { // Constrói cada item da lista
                  final categoria = categorias[index]; // Categoria atual
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: categoriaSelecionada == index // Destaque se selecionada
                            ? (categoria['cor'] as Color)
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        categoria['icone'] as Widget, // Ícone da categoria
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            categoria['nome'] as String, // Nome da categoria
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Text(
                          'R\$ ${(categoria['valor'] as double).toStringAsFixed(2)}', // Valor formatado
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
      ),
    );
  }
}