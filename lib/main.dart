import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pantalla_inicial.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _inicializarFirebase = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestor de Tareas',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: FutureBuilder(
        future: _inicializarFirebase,
        builder: (context, snapshot) {
          // ✅ Firebase listo
          if (snapshot.connectionState == ConnectionState.done) {
            return PantallaInicial();
          }

          // ❌ Error al iniciar Firebase
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text(
                  '❌ Error al iniciar Firebase:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          // ⏳ Mientras se inicializa Firebase
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }
}
