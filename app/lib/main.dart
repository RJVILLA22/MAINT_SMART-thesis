import 'package:app/auth_wrapper.dart';
import 'package:app/pages/inventory.dart';
import 'package:app/pages/admin.dart';
import 'package:app/pages/borrow.dart';
import 'package:app/pages/borrow_success.dart';
import 'package:app/pages/home.dart';
import 'package:app/pages/inventory_admin.dart';

import 'package:app/pages/return.dart';
import 'package:app/pages/return_success.dart';
import 'package:app/pages/signup1.dart';
import 'package:app/pages/terms_and_conditions.dart';
import 'package:app/provider/auth_provider.dart';
import 'package:app/provider/inventory_provider.dart';
import 'package:app/provider/sign_up_provider.dart';
import 'package:app/provider/tools_provider.dart';
import 'package:app/provider/transaction_provider.dart';
import 'package:app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:app/provider/user_directory_provider.dart';
import 'package:app/pages/user_list.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ToolsProvider()),
        ChangeNotifierProvider(create: (context) => UserAuthProvider()),
        ChangeNotifierProvider(create: (context) => SignUpProvider()),
        ChangeNotifierProvider(create: (context) => InventoryProvider()),
        ChangeNotifierProvider(create: (context) => TransactionProvider()),
        ChangeNotifierProvider(create: (context) => UserDirectoryProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: maintTheme.defaultTheme,
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
      routes: {
        '/home': (context) => HomeScreen(),
        '/admin': (context) => AdminScreen(),
        '/borrow': (context) => Borrow(),
        '/return': (context) => Return(),
        '/borrow_success': (context) => BorrowSuccess(),
        '/return_success': (context) => ReturnSuccess(),
        '/sign_up_1': (context) => SignUpPage1(),
        '/inventory': (context) => Inventory(),
        '/inventory_admin': (context) => InventoryAdmin(),
        '/user_list': (context) => UserList(),
      },
    );
  }
}
