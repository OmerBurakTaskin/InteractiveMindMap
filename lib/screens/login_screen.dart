import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hackathon/custom_widgets/custom_textfield.dart';
import 'package:hackathon/screens/home_screen.dart';
import 'package:hackathon/screens/sign_up_screen.dart';
import 'package:hackathon/services/authentication_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authtenticationService = AuthenticationService();
  final _emailTextField = CustomTextField(10, "Email", false);
  final _passwordTextField = CustomTextField(10, "Password", true);
  @override
  Widget build(BuildContext context) {
    List<CustomTextField> textFields = [_emailTextField, _passwordTextField];
    return Scaffold(
      body: Expanded(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...textFields,
              ElevatedButton(
                  onPressed: () async {
                    try {
                      final userCredentials =
                          await _authtenticationService.signIn(
                              email: _emailTextField.getText().trim(),
                              password: _passwordTextField.getText().trim());
                      if (userCredentials.user!.emailVerified) {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomeScreen(),
                            ));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Row(
                          children: [
                            const Text("Email doğrulanmamış"),
                            TextButton(
                                onPressed: () async {
                                  userCredentials.user!.sendEmailVerification();
                                },
                                child: const Text("Mail gönder"))
                          ],
                        )));
                      }
                    } on FirebaseAuthException catch (e) {
                      if (e.code == "user-not-found") {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Kullanıcı bulunamadı")));
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Bir hata oluştu")));
                    }
                  },
                  child: const Text("Giriş Yap")),
              Row(
                children: [
                  const Text("Hesabnız yok mu?"),
                  TextButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignUpScreen(),
                          )),
                      child: const Text(
                        "Üye Ol",
                        style: TextStyle(decoration: TextDecoration.underline),
                      ))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
