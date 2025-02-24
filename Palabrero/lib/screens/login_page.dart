import 'package:Palabraro/screens/dashboard_page.dart'; // Importa la pantalla de dashboard
import 'package:Palabraro/screens/register_page.dart'; // Importa la pantalla de registro
import 'package:firebase_auth/firebase_auth.dart'; // Importa Firebase Authentication
import 'package:flutter/material.dart'; // Importa Flutter para UI
import 'package:google_sign_in/google_sign_in.dart'; // Importa Google Sign-In

// Definición de la clase LoginPage como StatefulWidget
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

// Estado de la pantalla de login
class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController(); // Controlador para el email
  final TextEditingController _passwordController = TextEditingController(); // Controlador para la contraseña
  bool _isLoading = false; // Estado para mostrar indicador de carga
  bool _obscureText = true; // Controla la visibilidad de la contraseña

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'), // Imagen de fondo
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Sección del logo
              Container(
                padding: const EdgeInsets.only(top: 60.0),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/logo.png', // Logo de la app
                      height: 150,
                    ),
                    const SizedBox(height: 20.0),
                    const Text(
                      'INICIAR SESIÓN',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 150.0),

              // Formulario de login
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Campo de usuario (email)
                    const Text(
                      'USUARIO',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 10.0),
                    TextField(
                      controller: _emailController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[800],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide.none,
                        ),
                        hintText: 'Ingresa tu usuario',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                      ),
                    ),
                    const SizedBox(height: 20.0),

                    // Campo de contraseña
                    const Text(
                      'CONTRASEÑA',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 10.0),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscureText, // Muestra u oculta la contraseña
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[800],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide.none,
                        ),
                        hintText: 'Ingresa tu contraseña',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText ? Icons.visibility : Icons.visibility_off,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText; // Cambia la visibilidad de la contraseña
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),

                    // Enlace para ir a la pantalla de registro
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RegisterPage()),
                          );
                        },
                        child: const Text(
                          'NO TIENES CUENTA, CREA UNA',
                          style: TextStyle(color: Colors.blue, fontSize: 14, decoration: TextDecoration.underline),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40.0),

                    // Botón de inicio de sesión
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login, // Llama a la función de login
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF65259),
                          padding: const EdgeInsets.symmetric(vertical: 15.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white))
                            : const Text(
                                'ENTRAR',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20.0),

                    // Botón para iniciar sesión con Google
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.login, color: Colors.white),
                        label: const Text(
                          'Iniciar sesión con Google',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        onPressed: _isLoading ? null : _signInWithGoogle, // Llama a la función de Google Sign-In
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4285F4),
                          padding: const EdgeInsets.symmetric(vertical: 15.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 150.0),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Función para iniciar sesión con Firebase Authentication
  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Redirigir al dashboard si el inicio de sesión es exitoso
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
    } on FirebaseAuthException catch (e) {
      // Manejo de errores en la autenticación
      String errorMsg = '';
      if (e.code == 'user-not-found') {
        errorMsg = 'Usuario no encontrado';
      } else if (e.code == 'wrong-password') {
        errorMsg = 'Contraseña incorrecta';
      } else {
        errorMsg = 'Error: ${e.message}';
      }

      // Mostrar mensaje de error
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg)));
    } finally {
      setState(() {
        _isLoading = false; // Restablece el estado de carga
      });
    }
  }

  // Función para iniciar sesión con Google
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      if (googleAuth?.idToken != null && googleAuth?.accessToken != null) {
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken,
        );

        await FirebaseAuth.instance.signInWithCredential(credential);

        // Redirigir al dashboard si el inicio de sesión es exitoso
        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => const DashboardPage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al iniciar sesión con Google: ${e.message}')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
