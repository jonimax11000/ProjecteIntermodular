import 'dart:convert';
import '../core/api_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:exercici_disseny_responsiu_stateful/features/presentation/menu/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:exercici_disseny_responsiu_stateful/config/api_config.dart';
import 'dart:io';
import 'package:http/io_client.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FlutterSecureStorage storage = const FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        centerTitle: true,
        title: Image.asset(
          "assets/img/justflix.png",
          height: 55,
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Card(
            color: const Color(0xFF1E1E1E),
            elevation: 20,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Inicia sesión",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 35),

                  /// EMAIL
                  TextFormField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration(
                      label: "Email",
                      icon: Icons.email,
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// PASSWORD
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration(
                      label: "Contraseña",
                      icon: Icons.lock,
                    ),
                  ),
                  const SizedBox(height: 24),

                  /// BOTÓN LOGIN
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        _login(
                          _emailController.text,
                          _passwordController.text,
                        );

                        /*Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                        );*/
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "INICIAR SESIÓN",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 255, 255, 255)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: Column(
                      children: [
                        // Aquí puedes agregar más widgets dentro de la columna si quieres
                        const SizedBox(height: 10), // ejemplo de espacio
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              openBrowser("https://10.0.2.2:8069/web/signup");
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E1E1E),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              "REGISTRARSE",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 255, 255, 255),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 🎨 DECORACIÓN INPUT (reutilizable)
  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.white54),
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: const Color(0xFF2A2A2A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }

  Future<void> _login(String email, String password) async {
    final params = {
      "params": {"login": email, "password": password, "db": "Justflix"}
    };

    try {
      final ioc = HttpClient();
      ioc.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      final client = IOClient(ioc);

      final response = await client.post(
        Uri.parse(ApiConfig.urls["login"]!),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
        body: jsonEncode(params),
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Handle Odoo JSON-RPC response wrapper
        final result = data['result'] ?? data;

        if (result['error'] != null) {
          debugPrint("Login error from API: ${result['error']}");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['error'].toString())),
          );
          return;
        }

        final token = result['token'];

        if (token != null) {
          await storage.write(key: 'jwt', value: token);
          print("TOKEN: $token");

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          }
        } else {
          debugPrint("Token is null in response");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error: No token received")),
          );
        }
      } else {
        debugPrint("Login failed with status: ${response.statusCode}");
      }
    } catch (err) {
      debugPrint("Error de red: $err");
    }
  }

  Future<void> openBrowser(String url) async {
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw 'No se pudo abrir la URL: $url';
    }
  }
}
