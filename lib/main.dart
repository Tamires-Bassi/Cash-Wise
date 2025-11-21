import 'package:flutter/material.dart'; // Importa o pacote Material, que contém todos os widgets básicos do Flutter
import 'package:device_preview/device_preview.dart'; // Importa o DevicePreview
import 'package:cash_wise/screens/login_screen.dart'; // Importa a tela de login
import 'package:cash_wise/screens/register_screen.dart'; // Importa a tela de cadastro
import 'package:cash_wise/screens/forgot_password_screen.dart'; // Importa a tela de recuperação de senha
import 'package:cash_wise/screens/home_screen.dart'; // Importa a tela inicial (home)
import 'package:cash_wise/screens/categories_screen.dart'; // Importa a tela de categorias
import 'package:cash_wise/screens/about_screen.dart'; // Importa a tela Sobre
import 'package:cash_wise/screens/accounts_screen.dart'; // Importa a tela Contas
import 'package:cash_wise/screens/add_transaction_screen.dart'; // Importa a tela Adicionar Transação
import 'package:cash_wise/screens/transactions_list_screen.dart'; // Importa a tela Lista de Transações
import 'package:provider/provider.dart'; // Importa o Provider
import 'package:cash_wise/providers/transaction_provider.dart' ; // Importa o TransactionProvider
void main() { 
  runApp(  
    DevicePreview( // Inicia o DevicePreview
      enabled: true, // Habilita o DevicePreview
      builder: (context) => const MyApp(), // Passa o widget raiz do app para o DevicePreview
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TransactionProvider(), // Cria o nosso gerenciador
      child: MaterialApp(
        useInheritedMediaQuery: true, // Permite que o DevicePreview controle a mídia
        debugShowCheckedModeBanner: false, // Remove a faixa de debug
        title: 'CashWise', // Título do app
        builder: DevicePreview.appBuilder, // Configura o DevicePreview
        locale: DevicePreview.locale(context), //
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
        ),

        initialRoute: '/login', // Define a rota inicial do app, a tela que aparece primeiro
        routes: { // Define as rotas do app, cada rota é uma tela
          '/login': (context) => const LoginScreen(), // Rota para a tela de login
          '/register': (context) => const RegisterScreen(), // Rota para a tela de cadastro
          '/forgot_password': (context) => const ForgotPasswordScreen(),
          '/home': (context) => const HomeScreen(), // Rota para a tela de recuperação de senha
          '/categories': (context) => const CategoriesScreen(), // Rota para a tela inicial (home)
          '/about': (context) => const AboutScreen(), // Rota para a tela Sobre
          '/accounts': (context) => const AccountsScreen(), // Rota para a tela Contas
          '/add_transaction': (context) => const AddTransactionScreen(), // Rota para a tela Adicionar Transação
          '/transactions_list': (context) => const TransactionsListScreen(),  // Rota para a tela Lista de Transações
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
