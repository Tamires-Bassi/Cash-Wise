import 'package:flutter/material.dart'; // Import do Flutter material
import 'package:provider/provider.dart'; // Import do Provider para gerenciamento de estado
import 'package:cloud_firestore/cloud_firestore.dart'; // Import do Firestore 
import 'package:cash_wise/providers/transaction_provider.dart'; // Import do provider de transações
import 'package:cash_wise/models/transaction_model.dart'; // Necessário para o enum
// Import dos ícones customizados

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => AddTransactionScreenState(); // Cria o estado do widget
}

// Tela para adicionar nova transação
class AddTransactionScreenState extends State<AddTransactionScreen> {
  final _descriptionController = TextEditingController();
  final _valueController = TextEditingController();

  int _selectedTransactionType = 0; // 0 = Despesa, 1 = Receita
  
  // Armazena o nome da categoria selecionada (String) para evitar erros de referência no Dropdown
  String? _selectedCategoryName; 
  
  // Agora guardamos o ID do documento da conta, não o objeto inteiro
  String? _selectedAccountId; 

  // Lista estática de categorias
  final List<Map<String, dynamic>> categoriasEstaticas = [
    {'nome': 'Alimentação', 'iconData': Icons.fastfood, 'bgColor': const Color(0xFFFF7043)},
    {'nome': 'Transporte', 'iconData': Icons.directions_car, 'bgColor': const Color(0xFF66BB6A)},
    {'nome': 'Lazer', 'iconData': Icons.movie, 'bgColor': const Color(0xFF7E57C2)},
    {'nome': 'Educação', 'iconData': Icons.school, 'bgColor': const Color(0xFF42A5F5)},
    {'nome': 'Moradia', 'iconData': Icons.home, 'bgColor': const Color.fromARGB(255, 214, 27, 152)},
    {'nome': 'Outros', 'iconData': Icons.category, 'bgColor': const Color.fromARGB(255, 120, 119, 119)},
    {'nome': 'Salário', 'iconData': Icons.trending_up, 'bgColor': const Color.fromARGB(255, 10, 94, 45), 'iconColor': Colors.white},
  ];

  // Salva a transação usando o provider 
  // Recebe a lista completa de categorias para buscar os detalhes (cor/icone) pelo nome
  void _saveTransaction(List<Map<String, dynamic>> allCategories) {
    final description = _descriptionController.text;
    final value = double.tryParse(_valueController.text.replaceAll(',', '.'));

    // Validações básicas
    if (description.isEmpty || value == null || value <= 0 || _selectedCategoryName == null || _selectedAccountId == null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.grey[850],
          title: const Text('Inválido', style: TextStyle(color: Colors.white)),
          content: const Text('Preencha todos os campos.', style: TextStyle(color: Colors.white70)),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
        ),
      );
      return;
    }

    // Encontra o objeto da categoria selecionada na lista completa
    final selectedCategoryMap = allCategories.firstWhere(
      (cat) => cat['nome'] == _selectedCategoryName,
      orElse: () => categoriasEstaticas[0], // Fallback seguro
    );

    // Chama o provider para adicionar a transação
    Provider.of<TransactionProvider>(context, listen: false).addTransaction(
      description: description,
      value: value,
      type: _selectedTransactionType == 0 ? TransactionType.despesa : TransactionType.receita,
      categoryName: selectedCategoryMap['nome'],
      categoryIconCode: (selectedCategoryMap['iconData'] as IconData).codePoint,
      categoryColorValue: (selectedCategoryMap['bgColor'] as Color).value,
      accountId: _selectedAccountId!,
    );

    // Mostra confirmação e volta
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Salvo com sucesso!'), backgroundColor: Colors.green));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context, listen: false); // Acessa o provider

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        elevation: 0,
        title: const Text('Nova Transação'),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      // Envolvemos o corpo num StreamBuilder para ouvir as categorias personalizadas
      body: StreamBuilder<QuerySnapshot>(
        stream: provider.customCategoriesStream,
        builder: (context, snapshot) {
          
          // Começa com as categorias estáticas
          List<Map<String, dynamic>> allCategories = List.from(categoriasEstaticas);

          // Adiciona as categorias do Firebase se houver
          if (snapshot.hasData) {
            final customDocs = snapshot.data!.docs;
            for (var doc in customDocs) {
              final data = doc.data() as Map<String, dynamic>;
              allCategories.add({
                'nome': data['name'],
                'iconData': IconData(data['iconCode'], fontFamily: 'MaterialIcons'), // Reconstrói o ícone
                'bgColor': Color(data['colorValue']), // Reconstrói a cor
              });
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Toggle Receita/Despesa
                Center(
                  child: ToggleButtons(
                    isSelected: [_selectedTransactionType == 0, _selectedTransactionType == 1],
                    onPressed: (index) => setState(() => _selectedTransactionType = index),
                    borderRadius: BorderRadius.circular(8),
                    selectedColor: Colors.white,
                    color: Colors.white70,
                    fillColor: _selectedTransactionType == 0 ? Colors.red[700] : Colors.green[700],
                    children: const [
                      Padding(padding: EdgeInsets.symmetric(horizontal: 30), child: Text('Despesa')),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 30), child: Text('Receita')),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: _valueController,
                  decoration: _inputDecor('Valor (R\$)'),
                  style: const TextStyle(color: Colors.white, fontSize: 24),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: _descriptionController,
                  decoration: _inputDecor('Descrição'),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),

                // Dropdown Categorias
                DropdownButtonFormField<String>(
                  value: _selectedCategoryName, // Usa o nome como valor
                  hint: const Text('Categoria', style: TextStyle(color: Colors.white70)),
                  dropdownColor: Colors.grey[850],
                  decoration: _inputDecor(''),
                  items: allCategories.map((cat) => DropdownMenuItem(
                    value: cat['nome'] as String, // Valor é o nome
                    child: Row(children: [
                      Icon(cat['iconData'], color: cat['bgColor']),
                      const SizedBox(width: 10),
                      Text(cat['nome'], style: const TextStyle(color: Colors.white))
                    ]),
                  )).toList(),
                  onChanged: (val) => setState(() => _selectedCategoryName = val),
                ),
                const SizedBox(height: 20),

                // Dropdown Contas
                StreamBuilder<QuerySnapshot>(
                  stream: provider.accountsStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const LinearProgressIndicator(); // Enquanto carrega
                    
                    final accountsDocs = snapshot.data!.docs; // Documentos das contas 
                    
                    return DropdownButtonFormField<String>(
                      value: _selectedAccountId, // Value deve corresponder ao initialValue logicamente
                      hint: const Text('Conta', style: TextStyle(color: Colors.white70)),
                      dropdownColor: Colors.grey[850],
                      decoration: _inputDecor(''),
                      items: accountsDocs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>; // Dados da conta
                        return DropdownMenuItem(
                          value: doc.id, // O valor é o ID do Firestore
                          child: Text(data['name'], style: const TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedAccountId = val), // Atualiza o ID selecionado
                    );
                  },
                ),

                // Botão Salvar
                const SizedBox(height: 40),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    // Passamos a lista completa para a função de salvar encontrar os detalhes
                    onPressed: () => _saveTransaction(allCategories),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 71, 29, 97)),
                    child: const Text('Salvar', style: TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  // Decoração dos campos de entrada
  InputDecoration _inputDecor(String label) {
    return InputDecoration(
      labelText: label.isEmpty ? null : label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.white12,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}