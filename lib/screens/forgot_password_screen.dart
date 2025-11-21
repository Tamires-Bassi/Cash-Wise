import 'package:flutter/material.dart'; // Importa o pacote Material do Flutter

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState(); // Cria o estado mutável da tela
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // Chave para controlar o formulário e ativar a validação
  final _formKey = GlobalKey<FormState>();
  // Controlador para ler o texto do campo
  final _emailController = TextEditingController();
  // Variável para mostrar o loading no botão
  bool _isLoading = false;

  //Limpa o controlador quando a tela é descartada
  @override
  void dispose() {
    _emailController.dispose(); // Libera os recursos do controlador
    super.dispose(); // Chama o dispose da superclasse
  }

  //Função para lidar com o clique no botão "Enviar"
  void _submitRecovery() {
    // Aciona a validação do formulário
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return; // Se inválido, não faz nada
    }

    setState(() { _isLoading = true; });
    // Simulação de delay da rede
    Future.delayed(const Duration(seconds: 1), () {
      setState(() { _isLoading = false; });

      // Mostra SnackBar de sucesso (RF006)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('E-mail de recuperação enviado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      // Volta para a tela de Login
      Navigator.of(context).pop();

    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size; // Obtém o tamanho da tela
    final screenHeight = size.height;
    final screenWidth = size.width;

    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey, // Conecta a chave ao formulário
            child: Column(
              children: [
                //Logo do app
                Image.asset(
                  'assets/images/Logo.png',
                  width: screenWidth * 0.65,
                  height: screenHeight * 0.18,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: screenHeight * 0.01),

                // Texto explicativo
                SizedBox(
                  width: screenWidth * 0.85,
                  child: const Text(
                    'Insira seu e-mail cadastrado para receber um link de recuperação de senha.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),

                // Formulário de recuperação de senha
                Container(
                  width: screenWidth * 0.70,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _emailController, // Controlador do campo
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
                          if (!value.contains('@') || !value.contains('.')) { // Verifica formato básico
                            return 'Por favor, insira um e-mail válido.';
                          }
                          return null; // Válido
                        },
                      ),
                      SizedBox(height: screenHeight * 0.015),

                      // Botão de enviar
                      Center(
                        child: SizedBox(
                          width: 250,
                          height: 48,
                          child: ElevatedButton(
                            // Chama a função _submitRecovery
                            onPressed: _isLoading ? null : _submitRecovery,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 71, 29, 97),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            // Mostra o texto ou um loading
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
                                    'Enviar e-mail', // Texto ajustado
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
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
                              'Voltar ao login',
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