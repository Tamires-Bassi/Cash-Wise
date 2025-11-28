import 'package:flutter/material.dart'; // Importação do Flutter material
import 'package:firebase_auth/firebase_auth.dart'; // Importação do Firebase Auth

class LoginScreen extends StatefulWidget { // Tela de Login
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState(); // Cria o estado da tela
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
        backgroundColor: Colors.grey[850],
        title: const Text('Erro no Login', style: TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK', style: TextStyle(color: Color.fromARGB(255, 183, 137, 212))),
          ),
        ],
      ),
    );
  }

  // Função para lidar com o clique no botão "Entrar"
  Future<void> _submitLogin() async {
    // Aciona a validação do formulário
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return; // Se inválido, não faz nada
    }

    setState(() { _isLoading = true; }); // Mostra o loading

    try {
      // Tenta fazer login no Firebase
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Se o login funcionar e o widget ainda estiver na tela
      if (mounted) {
        // Navega para a Home e remove a tela de login da pilha (para não voltar ao login ao apertar "voltar")
        Navigator.of(context).pushReplacementNamed('/home');
      }

    } on FirebaseAuthException catch (e) {
      // Tratamento de erros específicos do Firebase
      String msg = 'Ocorreu um erro ao fazer login.';
  
      // Mapeia os códigos de erro para mensagens amigáveis
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') { 
        msg = 'E-mail ou senha incorretos.';
      } else if (e.code == 'wrong-password') {
        msg = 'Senha incorreta.';
      } else if (e.code == 'invalid-email') {
        msg = 'O endereço de e-mail não é válido.';
      } else if (e.code == 'too-many-requests') {
        msg = 'Muitas tentativas falhas. Tente novamente mais tarde.';
      }

      _showErrorDialog(msg); // Mostra o diálogo de erro

    } catch (e) {
      // Erro genérico
      _showErrorDialog('Ocorreu um erro inesperado. Tente novamente.');
    } finally {
      // Garante que o loading pare, independente do resultado
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
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
          child: Form(
            key: _formKey,
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
                SizedBox(
                  width: screenWidth * 0.70,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Campo de E-mail
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
                        validator: (value) { // Validação do e-mail
                          if (value == null || value.trim().isEmpty) { // Campo vazio
                            return 'Por favor, insira seu e-mail.';
                          }
                          if (!value.contains('@') || !value.contains('.')) { // Formato básico de e-mail
                             return 'Por favor, insira um e-mail válido.';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: screenHeight * 0.015),

                      // Campo de Senha
                      TextFormField(
                        controller: _passwordController,
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
                        validator: (value) { // Validação da senha
                          if (value == null || value.trim().isEmpty) { // Campo vazio
                            return 'Por favor, insira sua senha.';
                          }
                          if (value.length < 8) { // Senha mínima de 8 caracteres
                            return 'Por favor, insira uma senha válido.';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: screenHeight * 0.015),

                      // Botão de entrar
                      Center(
                        child: SizedBox(
                          width: 250,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 71, 29, 97),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: _isLoading
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