import 'package:flutter/material.dart'; // Import do Flutter material
import 'package:device_preview/device_preview.dart'; // Import do Device Preview
import 'package:firebase_core/firebase_core.dart'; // Import do Firebase
import 'package:provider/provider.dart'; // Import do Provider para gerenciamento de estado
import 'firebase_options.dart'; // Arquivo gerado automaticamente
import 'package:cash_wise/screens/login_screen.dart'; // Import das telas do aplicativo
import 'package:cash_wise/screens/register_screen.dart'; // Import das telas do aplicativo
import 'package:cash_wise/screens/forgot_password_screen.dart'; // Import das telas do aplicativo
import 'package:cash_wise/screens/home_screen.dart'; // Import das telas do aplicativo
import 'package:cash_wise/screens/categories_screen.dart'; // Import das telas do aplicativo
import 'package:cash_wise/screens/about_screen.dart'; // Import das telas do aplicativo
import 'package:cash_wise/screens/accounts_screen.dart'; // Import das telas do aplicativo
import 'package:cash_wise/screens/add_transaction_screen.dart'; // Import das telas do aplicativo
import 'package:cash_wise/screens/transactions_list_screen.dart'; // Import das telas do aplicativo
import 'package:cash_wise/providers/transaction_provider.dart'; // Import do provider de transações
import 'package:cash_wise/screens/search_screen.dart'; // Import das telas do aplicativo

void main() async {
  // Garante que o Flutter esteja pronto antes de iniciar o Firebase
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializa o Firebase com a configuração gerada
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp( // Inicia o aplicativo com Device Preview
    DevicePreview(
      enabled: true,
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget { // Widget raiz do aplicativo
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TransactionProvider(), // Provedor de transações
      child: MaterialApp(
        useInheritedMediaQuery: true,
        debugShowCheckedModeBanner: false,
        title: 'CashWise',
        builder: DevicePreview.appBuilder,
        locale: DevicePreview.locale(context),
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
        ),
        // Rota inicial
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/forgot_password': (context) => const ForgotPasswordScreen(),
          '/home': (context) => const HomeScreen(),
          '/categories': (context) => const CategoriesScreen(),
          '/about': (context) => const AboutScreen(),
          '/accounts': (context) => const AccountsScreen(),
          '/add_transaction': (context) => const AddTransactionScreen(),
          '/transactions_list': (context) => const TransactionsListScreen(),
          '/search': (context) => const SearchScreen(),
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget { // Widget de página inicial
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
