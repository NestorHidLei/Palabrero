import 'package:Palabraro/exports.dart'; // Importa todas las dependencias desde un solo archivo

/// Página principal del Dashboard
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  /// Función para cerrar sesión del usuario en Firebase
  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut(); // Cierra la sesión del usuario

      // Redirige al usuario a la página de inicio de sesión
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } catch (e) {
      // Imprime el error en la consola si está en modo depuración
      if (kDebugMode) {
        print("Error al cerrar sesión: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser; // Obtiene el usuario actual autenticado

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        // Eliminamos el IconButton que abre el Drawer
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Créditos',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: const Text('Desarrollador: Néstor'),
              onTap: () {
                // Cierra el Drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Diseñador: Néstor'),
              onTap: () {
                // Cierra el Drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Versión: 1.0.0'),
              onTap: () {
                // Cierra el Drawer
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background dashboard.png'), // Imagen de fondo
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            // Header con el nombre del usuario y el botón de cerrar sesión
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 80.0, vertical: 40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    user?.displayName ?? 'Invitado', // Muestra el nombre del usuario o "Invitado" si no tiene nombre
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Icono para cerrar sesión
                  GestureDetector(
                    onTap: () => _signOut(context),
                    child: const CircleAvatar(
                      radius: 20.0,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.logout,
                        size: 24.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),

            // Botón para jugar en modo SOLO
            Transform.rotate(
              angle: 0.45, // Gira el botón en diagonal
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GameScreen(isSoloMode: true),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10.0),
                  width: 250,
                  height: 60,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 107, 31, 24),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: const Text(
                    'SOLO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            // Botón para jugar en modo DUEL
            Transform.rotate(
              angle: 0.45, // Gira el botón en diagonal
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GameScreenDuel(isDuelMode: true),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 25.0),
                  width: 250,
                  height: 60,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.blue[900],
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: const Text(
                    'DUEL',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            const Spacer(),

            // Mensaje de bienvenida con el correo del usuario
            Text(
              'Bienvenido, ${user?.email ?? 'No disponible'}', // Muestra el correo o "No disponible" si no hay usuario
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20.0), // Espacio adicional al final
          ],
        ),
      ),
    );
  }
}