import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Import the firebase_app_check plugin
import 'package:firebase_app_check/firebase_app_check.dart';

import 'bloc/notas_bloc.dart';
import 'provider/notas_api.dart';
import 'view/notas_page.dart';

// Configuração do app web, copiada do console do Firebase
// (Configurações do projeto → Seus apps → app Web → firebaseConfig).
const firebaseConfig = FirebaseOptions(
    apiKey: "AIzaSyCkdzPFnRidgDOMy9JHh12uzuaefQ-J5EA",
    authDomain: "si700aped.firebaseapp.com",
    projectId: "si700aped",
    storageBucket: "si700aped.firebasestorage.app",
    messagingSenderId: "579665041473",
    appId: "1:579665041473:web:ac5c8ddeab683fe17fcec0");

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseConfig);

  runApp(
    BlocProvider(
      create: (_) => NotasBloc(NotasApi())..add(CarregarNotas()),
      child: const MaterialApp(home: NotasPage()),
    ),
  );
}
