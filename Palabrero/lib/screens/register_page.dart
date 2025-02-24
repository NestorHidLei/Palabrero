import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatear fechas
import 'package:firebase_auth/firebase_auth.dart'; // Para autenticación de usuarios
import 'package:cloud_firestore/cloud_firestore.dart'; // Para almacenamiento de datos en Firestore
import 'login_page.dart'; // Asegúrate de importar la página de login

// Definición de la pantalla de registro como un StatefulWidget
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegisterPageState createState() => _RegisterPageState();
}

// Estado de la pantalla de registro
class _RegisterPageState extends State<RegisterPage> {
  // Controladores para los campos del formulario
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  // Clave global para el formulario (para validaciones)
  final _formKey = GlobalKey<FormState>();

  // Función para registrar el usuario y guardar sus datos en Firebase
  Future<void> _registerUser() async {
    try {
      // Registrar usuario en Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Obtener UID del usuario recién registrado
      String uid = userCredential.user!.uid;

      // Guardar datos del usuario en Firestore
      await FirebaseFirestore.instance.collection('Client').doc(uid).set({
        'email': _emailController.text.trim(),
        'username': _usernameController.text.trim(),
        'birthDate': _dobController.text.trim(),
        'createdAt': DateTime.now(),
      });

      // Mostrar mensaje de éxito
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario registrado exitosamente')),
      );

      // Redirigir al usuario a la pantalla de inicio de sesión
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } catch (e) {
      // Mostrar mensaje de error en caso de fallo
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFFF65259), // Fondo de la pantalla
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Encabezado
              Container(
                padding: const EdgeInsets.only(top: 120.0),
                child: const Column(
                  children: [
                    Text(
                      'CREAR CUENTA',
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

              const SizedBox(height: 75.0),

              // Formulario de registro
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Campo de Email
                      const Text(
                        'EMAIL',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      TextFormField(
                        controller: _emailController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[800],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide.none,
                          ),
                          hintText: 'Ingresa tu email',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          errorStyle: const TextStyle(color: Colors.white),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese su email';
                          } else if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                              .hasMatch(value)) {
                            return 'Ingrese un email válido';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20.0),

                      // Campo de Fecha de Nacimiento
                      const Text(
                        'FECHA DE NACIMIENTO',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      TextFormField(
                        controller: _dobController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[800],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide.none,
                          ),
                          hintText: 'Selecciona tu fecha de nacimiento',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          suffixIcon: Icon(Icons.calendar_today, color: Colors.grey[500]),
                          errorStyle: const TextStyle(color: Colors.white),
                        ),
                        readOnly: true,
                        onTap: () async {
                          // Mostrar selector de fecha
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null) {
                            String formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
                            setState(() {
                              _dobController.text = formattedDate;
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 20.0),

                      // Campo de Usuario
                      const Text(
                        'USUARIO',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      TextFormField(
                        controller: _usernameController,
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
                          errorStyle: const TextStyle(color: Colors.white),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese su usuario';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20.0),

                      // Campo de Contraseña
                      const Text(
                        'CONTRASEÑA',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      TextFormField(
                        controller: _passwordController,
                        style: const TextStyle(color: Colors.white),
                        obscureText: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[800],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide.none,
                          ),
                          hintText: 'Ingresa tu contraseña',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          suffixIcon: Icon(Icons.visibility, color: Colors.grey[500]),
                          errorStyle: const TextStyle(color: Colors.white),
                        ),
                      ),

                      const SizedBox(height: 40.0),

                      // Botón de Registro
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _registerUser();
                            }
                          },
                          child: const Text('CREAR CUENTA'),
                        ),
                      ),

                      const SizedBox(height: 20.0),

                      // Enlace al Login
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginPage()),
                            );
                          },
                          child: const Text('¿Ya tienes una cuenta? Inicia sesión'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
