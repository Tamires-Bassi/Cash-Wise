import 'package:flutter/material.dart'; // Importa o pacote Material, que contém todos os widgets básicos do Flutter

// MUDANÇA: Convertido para StatefulWidget
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState(); // Cria o estado mutável da tela
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Chave para controlar o formulário e ativar a validação
  final _formKey = GlobalKey<FormState>();

  // Controladores para ler o texto dos campos
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController(); // <<< NOVO CAMPO (RF002)
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Variável para mostrar o loading no botão
  bool _isLoading = false;

  // Limpa os controladores quando a tela é descartada
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Função para exibir o AlertDialog de erro
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[850], 
        title: const Text('Erro no Cadastro', style: TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(), // Fecha o diálogo
            child: const Text('OK', style: TextStyle(color: Color.fromARGB(255, 183, 137, 212))),
          ),
        ],
      ),
    );
  }

  // Função para lidar com o clique no botão "Cadastrar"
  void _submitRegister() {
    // Aciona a validação do formulário
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return; // Se inválido, não faz nada
    }

    setState(() { _isLoading = true; }); // Mostra o loading

  
    final email = _emailController.text;
    final password = _passwordController.text;

    // Simulação de delay da rede
    Future.delayed(const Duration(seconds: 1), () {
      // Simulação de sucesso
      setState(() { _isLoading = false; });

      // Mostra SnackBar de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cadastro realizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      // Volta para a tela de Login
      Navigator.of(context).pop();

    });
  }

  @override
  Widget build(BuildContext context) { // Constrói a interface da tela
    final size = MediaQuery.of(context).size;
    final screenHeight = size.height;
    final screenWidth = size.width;

    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Center(
        child: SingleChildScrollView(
          // Adicionado o widget Form
          child: Form(
            key: _formKey, // Conecta a chave ao formulário
            child: Column(
              children: [
                // Logo
                Image.asset(
                  'assets/images/Logo.png',
                  width: screenWidth * 0.65,
                  height: screenHeight * 0.18,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: screenHeight * 0.03),

                // Fomulário de cadastro
                Container(
                  width: screenWidth * 0.70,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField( 
                        controller: _nameController, // Controlador do nome
                        decoration: InputDecoration(
                          labelText: 'Nome',
                          labelStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white12,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.01,
                            horizontal: 12,
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) { // Verifica se está vazio
                            return 'Por favor, insira seu nome.';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: screenHeight * 0.015),

                      TextFormField(
                        controller: _emailController, // Controlador do e-mail
                        decoration: InputDecoration(
                          labelText: 'E-mail',
                          labelStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white12,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.01,
                            horizontal: 12,
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) { // Verifica se está vazio
                            return 'Por favor, insira seu e-mail.';
                          }
                          if (!value.contains('@') || !value.contains('.')) { // Verificação simples de e-mail válido
                            return 'Por favor, insira um e-mail válido.';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: screenHeight * 0.015),

                      TextFormField(
                        controller: _phoneController, // Controlador do telefone
                        decoration: InputDecoration(
                          labelText: 'Telefone',
                          labelStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white12,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.01,
                            horizontal: 12,
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) { // Verifica se está vazio
                            return 'Por favor, insira seu telefone.';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: screenHeight * 0.015),

                      TextFormField(
                        controller: _passwordController, // Controlador da senha
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          labelStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white12,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.01,
                            horizontal: 12,
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        obscureText: true,
                        // MUDANÇA: Validador (RF002)
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) { // Verifica se está vazio
                            return 'Por favor, insira uma senha.';
                          }
                          if (value.length < 6) { // Verifica tamanho mínimo
                            return 'A senha deve ter no mínimo 6 caracteres.';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: screenHeight * 0.015),

                      TextFormField(
                        controller: _confirmPasswordController, // Controlador da confirmação de senha
                        decoration: InputDecoration(
                          labelText: 'Confirmar Senha',
                          labelStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white12,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.01,
                            horizontal: 12,
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        obscureText: true,
                        // MUDANÇA: Validador (RF002)
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) { // Verifica se está vazio
                            return 'Por favor, confirme sua senha.';
                          }
                          if (value != _passwordController.text) { // Verifica se as senhas coincidem
                            return 'As senhas não coincidem.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Botão de cadastrar
                      Center(
                        child: SizedBox(
                          width: 250,
                          height: 48,
                          child: ElevatedButton(
                            // MUDANÇA: Chama a função _submitRegister
                            onPressed: _isLoading ? null : _submitRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 71, 29, 97),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: _isLoading // Mostra o loading ou o texto
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  )
                                : const Text(
                                    'Cadastrar',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Link para voltar ao login
                      Center(
                        child: SizedBox(
                          width: 250,
                          height: 40,
                          child: TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Volta para a tela anterior
                            },
                            child: const Text(
                              'Já tem uma conta', // Texto do link
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}