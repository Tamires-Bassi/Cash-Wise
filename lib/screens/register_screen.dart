import 'package:flutter/material.dart'; // Import do Flutter material
import 'package:firebase_auth/firebase_auth.dart'; // Import do Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Import do Firestore

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState(); // Cria o estado do widget
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>(); // Chave do formulário

  // Controladores
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false; // Indica se está carregando

  @override
  void dispose() { // Libera os controladores ao descartar o widget
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Mostra erros na tela
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title: const Text('Erro no Cadastro', style: TextStyle(color: Colors.white)),
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

  // Lógica de Cadastro com Firebase
  Future<void> _submitRegister() async {
    final isValid = _formKey.currentState?.validate() ?? false; // Valida o formulário
    if (!isValid) return; // Se inválido, retorna

    setState(() => _isLoading = true); // Indica que está carregando

    try {
      // Criar usuário no Authentication
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Salvar dados adicionais no Firestore
      await FirebaseFirestore.instance.collection('usuarios').doc(userCredential.user!.uid).set({
        'nome': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'telefone': _phoneController.text.trim(),
        'uid': userCredential.user!.uid,
        'criadoEm': DateTime.now().toIso8601String(),
      });

      if (mounted) { // Verifica se o widget ainda está montado
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cadastro realizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        // Volta para o Login
        Navigator.of(context).pop();
      }

      // Tratar erros específicos do Firebase Auth
    } on FirebaseAuthException catch (e) { 
      String msg = 'Ocorreu um erro ao cadastrar.';
      if (e.code == 'weak-password') {
        msg = 'A senha fornecida é muito fraca.';
      } else if (e.code == 'email-already-in-use') {
        msg = 'Já existe uma conta com este e-mail.';
      } else if (e.code == 'invalid-email') {
        msg = 'O e-mail é inválido.';
      }
      
      // Mostrar diálogo de erro
      _showErrorDialog(msg); 
    } catch (e) {
      _showErrorDialog('Erro inesperado: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false); // Para de carregar se o widget ainda estiver montado
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size; 
    
    // Construção da interface de registro
    return Scaffold( 
      backgroundColor: Colors.grey[900],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Image.asset(
                  'assets/images/Logo.png',
                  width: size.width * 0.5,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 30),

                // Nome
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('Nome'),
                  validator: (value) => (value == null || value.isEmpty) ? 'Informe seu nome.' : null,// Validação simples de nome
                ),
                const SizedBox(height: 15),

                // E-mail
                TextFormField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('E-mail'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || !value.contains('@')) return 'E-mail inválido.'; // Validação simples de e-mail
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // Telefone (Campo extra exigido no RF002)
                TextFormField(
                  controller: _phoneController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('Telefone'),
                  keyboardType: TextInputType.phone,
                  validator: (value) => (value == null || value.isEmpty) ? 'Informe seu telefone.' : null, // Validação simples de telefone
                ),
                const SizedBox(height: 15),

                // Senha
                TextFormField(
                  controller: _passwordController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('Senha'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Informe uma senha.';
                    // Validação de senha forte
                    // Pelo menos 8 chars, 1 maiúscula, 1 minúscula, 1 número, 1 especial
                    String pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
                    if (!RegExp(pattern).hasMatch(value)) {
                      return 'Mínimo 8 caracteres, letra Maiúscula, minúscula, número e símbolo (!@#).';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // Confirmar Senha
                TextFormField(
                  controller: _confirmPasswordController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('Confirmar Senha'),
                  obscureText: true,
                  validator: (value) {
                    if (value != _passwordController.text) return 'As senhas não conferem.';
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                // Botão Cadastrar
                SizedBox(
                  width: 250,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 71, 29, 97),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                        : const Text('Cadastrar', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                
                const SizedBox(height: 15),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Já tem uma conta? Entrar', style: TextStyle(color: Colors.white70)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Decoração dos campos de entrada
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.white12,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}