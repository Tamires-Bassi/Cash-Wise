import 'package:flutter/material.dart'; // Importa o pacote Material, que contém todos os widgets básicos do Flutter

// MUDANÇA: Convertido para StatefulWidget
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState(); // Cria o estado mutável da tela
}

class _LoginScreenState extends State<LoginScreen> {
  // Chave para controlar o formulário e ativar a validação
  final _formKey = GlobalKey<FormState>();

  // Controladores para ler o texto dos campos
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Variável para mostrar o loading no botão
  bool _isLoading = false;

  // Limpa os controladores quando a tela é descartada
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Função para exibir o diálogo de erro
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[850], // Combinando com seu tema
        title: const Text('Erro no Login', style: TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            // Estilo do botão do app
            child: const Text('OK', style: TextStyle(color: Color.fromARGB(255, 183, 137, 212))), 
          ),
        ],
      ),
    );
  }

  //Função para lidar com o clique no botão "Entrar"
  void _submitLogin() {
    // Aciona a validação
    final isValid = _formKey.currentState?.validate() ?? false; // Validação do formulário
    if (!isValid) {
      return; // Se inválido, não faz nada 
    }

    // Mostra o loading
    setState(() { _isLoading = true; });

    // Obtém os valores dos campos
    final email = _emailController.text;
    final password = _passwordController.text;

    // Simulação de delay da rede
    Future.delayed(const Duration(seconds: 1), () {
      // Simulação simples:
      if (email == 'teste@teste.com' && password == '123') {
        // Sucesso
        // pushReplacementNamed para que o usuário não possa "voltar" para o login
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        // Falha
        _showErrorDialog('E-mail ou senha incorretos.');
      }
      
      // Esconde o loading
      if (mounted) { // Verifica se a tela ainda existe
        setState(() { _isLoading = false; });
      }
    });
  }

  @override
  Widget build(BuildContext context) { // Constrói a interface da tela
    final size = MediaQuery.of(context).size; // Obtém o tamanho da tela
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
                // Logo do app
                Image.asset(
                  'assets/images/Logo.png',
                  width: screenWidth * 0.65,
                  height: screenHeight * 0.18,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: screenHeight * 0.03),

                // Formulário de login
                Container(
                  width: screenWidth * 0.70,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // TextFormField para validação
                      TextFormField(
                        controller: _emailController,
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
                        // Validador 
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) { // Verifica se está vazio
                            return 'Por favor, insira seu e-mail.';
                          }
                          // Verificação simples de e-mail válido
                          if (!value.contains('@') || !value.contains('.')) {
                             return 'Por favor, insira um e-mail válido.';
                          }
                          return null; // Válido
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
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) { // Verifica se está vazio
                            return 'Por favor, insira sua senha.';
                          }
                          return null; // Válido
                        },
                      ),
                      SizedBox(height: screenHeight * 0.015),

                      // Botão de entrar
                      Center(
                        child: SizedBox(
                          width: 250,
                          height: 48,
                          child: ElevatedButton(
                            // MUDANÇA: Chama a função _submitLogin
                            onPressed: _isLoading ? null : _submitLogin, // Desativa se estiver carregando
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
                                    'Entrar',
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

                      // Link para "Esqueci minha senha"
                      Center(
                        child: SizedBox(
                          width: 250,
                          height: 40,
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/forgot_password');
                            },
                            child: const Text(
                              'Esqueci minha senha',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Link para "Criar conta"
                      Center(
                        child: SizedBox(
                          width: 250,
                          height: 40,
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/register');
                            },
                            child: const Text(
                              'Não tenho cadastro',
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