import 'package:Palabraro/screens/dashboard_page.dart'; // Importa la pantalla principal (Dashboard)
import 'package:Palabraro/screens/login_page.dart'; // Importa la pantalla de inicio de sesión
import 'package:firebase_core/firebase_core.dart'; // Importa Firebase Core para la inicialización
import 'package:firebase_auth/firebase_auth.dart'; // Importa Firebase Auth para la autenticación de usuarios
import 'package:flutter/material.dart'; // Importa Flutter Material para la construcción de la interfaz

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Asegura que Flutter esté inicializado antes de ejecutar código asíncrono
  await Firebase.initializeApp(); // Inicializa Firebase de manera asíncrona
  runApp(const MyApp()); // Ejecuta la aplicación
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Oculta la etiqueta de "Debug" en la esquina superior derecha
      home: FirebaseAuth.instance.currentUser == null 
          ? const LoginPage()  // Si no hay usuario autenticado, muestra la pantalla de inicio de sesión
          : const DashboardPage(), // Si hay un usuario autenticado, muestra la pantalla principal
    );
  }
}
