import 'package:flutter/material.dart'; // Importa o Flutter Material
import 'package:provider/provider.dart'; // Importa o Provider
import 'package:cash_wise/providers/transaction_provider.dart'; // Importa o Provider de Transações
import 'package:cash_wise/models/transaction_model.dart'; // Importa o modelo de transação
import 'package:cash_wise/models/account_model.dart'; // Importe o modelo de conta criado
import 'package:cash_wise/icons/custom_icons.dart'; // Importa os ícones personalizados

class AddTransactionScreen extends StatefulWidget { // Tela para adicionar transações
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => AddTransactionScreenState(); // Cria o estado da tela
}

class AddTransactionScreenState extends State<AddTransactionScreen> {
  // Controladores para ler o texto dos campos
  final _descriptionController = TextEditingController();
  final _valueController = TextEditingController();

  int _selectedTransactionType = 0; // 0 = Despesa, 1 = Receita
  Map<String, dynamic>? _selectedCategoryMap; // Categoria selecionada como mapa
  Account? _selectedAccount; // Alterado para armazenar o objeto Account diretamente

  // Lista de categorias (Mantida localmente pois é estática por enquanto)
  final List<Map<String, dynamic>> categorias = [
    {
      'nome': 'Alimentação',
      'iconData': Icons.fastfood,
      'bgColor': const Color(0xFFFF7043)
    },
    {
      'nome': 'Transporte',
      'iconData': Icons.directions_car,
      'bgColor': const Color(0xFF66BB6A)
    },
    {
      'nome': 'Lazer',
      'iconData': Icons.movie,
      'bgColor': const Color(0xFF7E57C2)
    },
    {
      'nome': 'Educação',
      'iconData': Icons.school,
      'bgColor': const Color(0xFF42A5F5)
    },
    {
      'nome': 'Moradia',
      'iconData': Icons.home,
      'bgColor': const Color.fromARGB(255, 214, 27, 152)
    },
    {
      'nome': 'Outros',
      'iconData': Icons.category,
      'bgColor': const Color.fromARGB(255, 120, 119, 119)
    },
    {
      'nome': 'Salário',
      'iconData': Icons.trending_up,
      'bgColor': const Color.fromARGB(255, 10, 94, 45),
      'iconColor': Colors.white,
    },
  ];

  // Lógica para salvar a transação
  void _saveTransaction() {
    final description = _descriptionController.text; // Obtém a descrição
    final value = double.tryParse(_valueController.text.replaceAll(',', '.')); // Obtém o valor

    // Validação dos campos
    if (description.isEmpty ||
        value == null ||
        value <= 0 ||
        _selectedCategoryMap == null ||
        _selectedAccount == null) { // Verifica se a conta (Account) foi selecionada
      
      showDialog( // Mostra um alerta se os campos forem inválidos
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.grey[850],
          title: const Text('Campos inválidos', style: TextStyle(color: Colors.white)),
          content: const Text(
              'Por favor, preencha todos os campos (Valor, Descrição, Categoria e Conta) para salvar.',
              style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK', style: TextStyle(color: Colors.purpleAccent)),
            ),
          ],
        ),
      );
      return;
    }

    // Chama o provider para adicionar
    Provider.of<TransactionProvider>(context, listen: false).addTransaction(
      description: description,
      value: value,
      type: _selectedTransactionType == 0
          ? TransactionType.despesa
          : TransactionType.receita,
      categoryName: _selectedCategoryMap!['nome'],
      categoryIconData: _selectedCategoryMap!['iconData'],
      categoryColor: _selectedCategoryMap!['bgColor'],
      accountName: _selectedAccount!.name, // Passa o nome da conta selecionada
    );

    ScaffoldMessenger.of(context).showSnackBar( // Mostra uma mensagem de sucesso
      const SnackBar(
        content: Text('Transação salva com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.of(context).pop(); // Fecha a tela após salvar
  }

  @override
  void dispose() { // Limpa os controladores ao descartar a tela
    _descriptionController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) { // Constrói a interface da tela
    final size = MediaQuery.of(context).size;
    final screenHeight = size.height;

    // Obtendo a lista de contas atualizada do Provider
    final accountProvider = Provider.of<TransactionProvider>(context);
    final accountsList = accountProvider.accounts;
 
    return Scaffold( // Estrutura básica da tela
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        elevation: 0,
        title: const Text('Adicionar Transação'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              // Seletor de Receita/Despesa
              child: ToggleButtons(
                isSelected: [
                  _selectedTransactionType == 0,
                  _selectedTransactionType == 1
                ],
                onPressed: (index) {
                  setState(() {
                    _selectedTransactionType = index; // Atualiza o tipo selecionado
                  });
                },
                borderRadius: BorderRadius.circular(8),
                selectedColor: Colors.white,
                color: Colors.white70,
                fillColor: _selectedTransactionType == 0
                    ? Colors.red[700]
                    : Colors.green[700],
                selectedBorderColor: _selectedTransactionType == 0
                    ? Colors.red[700]
                    : Colors.green[700],
                borderColor: Colors.grey[700],
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 40, vertical: 12),
                    child: Text('Despesa',
                        style: TextStyle(fontSize: 16)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 40, vertical: 12),
                    child: Text('Receita',
                        style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.03),

            // Campo de Valor
            TextField(
              controller: _valueController,
              decoration: InputDecoration(
                labelText: 'Valor (R\$)',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.white12,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
                contentPadding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.02,
                  horizontal: 16,
                ),
              ),
              style: const TextStyle(color: Colors.white, fontSize: 24),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: screenHeight * 0.02),

            // Campo de Descrição
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Descrição',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.white12,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
                contentPadding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.015,
                  horizontal: 16,
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            SizedBox(height: screenHeight * 0.02),

            // Seletor de Categoria
            DropdownButtonFormField<Map<String, dynamic>>(
              value: _selectedCategoryMap,
              hint: const Text('Selecione uma categoria',
                  style: TextStyle(color: Colors.white70)),
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Categoria',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.white12,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
              ),
              dropdownColor: Colors.grey[850],
              style: const TextStyle(color: Colors.white),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
              menuMaxHeight: 175,

              selectedItemBuilder: (context) {
                return categorias.map<Widget>((cat) {
                  return Row(
                    children: [
                      CustomIcons(
                        icon: cat['iconData'],
                        backgroundColor: cat['bgColor'],
                        iconColor: cat['iconColor'] ?? Colors.white,
                        padding: 0,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(cat['nome']),
                    ],
                  );
                }).toList();
              },
              
              items: categorias.map((cat) { // Itens da lista de categorias
                return DropdownMenuItem<Map<String, dynamic>>(
                  value: cat,
                  child: Row(
                    children: [
                      CustomIcons(
                        icon: cat['iconData'],
                        backgroundColor: cat['bgColor'],
                        iconColor: cat['iconColor'] ?? Colors.white,
                      ),
                      const SizedBox(width: 12),
                      Text(cat['nome']),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategoryMap = value;
                });
              },
            ),

            SizedBox(height: screenHeight * 0.02),

            // Seletor de Conta fluter
            DropdownButtonFormField<Account>(
              value: _selectedAccount,
              hint: const Text('Selecione uma conta',
                  style: TextStyle(color: Colors.white70)),
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Conta',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.white12,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
              ),
              dropdownColor: Colors.grey[850],
              style: const TextStyle(color: Colors.white),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
              menuMaxHeight: 175,

              // Construtor do item selecionado (Account)
              selectedItemBuilder: (context) {
                return accountsList.map<Widget>((account) {
                  return Row(
                    children: [
                      CustomIcons(
                        icon: account.icon,
                        backgroundColor: account.color,
                        iconColor: Colors.white,
                        padding: 0,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(account.name),
                    ],
                  );
                }).toList();
              },
              
              // Itens da lista (agora usando a lista do Provider)
              items: accountsList.map((account) {
                return DropdownMenuItem<Account>(
                  value: account, // O valor agora é o objeto Account completo
                  child: Row(
                    children: [
                      CustomIcons(
                        icon: account.icon,
                        backgroundColor: account.color,
                        iconColor: Colors.white,
                      ),
                      const SizedBox(width: 12),
                      Text(account.name),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedAccount = value; // Atualiza com o objeto Account
                });
              },
            ),

            SizedBox(height: screenHeight * 0.04),

            // Botão Salvar
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _saveTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color.fromARGB(255, 71, 29, 97),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Salvar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}