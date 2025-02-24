import 'package:Palabraro/exports.dart'; // Importa todas las dependencias desde un solo archivo
import 'package:Palabraro/screens/dashboard_page.dart';
import 'package:firebase_core/firebase_core.dart'; // Importa Firebase Core para la inicialización


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
