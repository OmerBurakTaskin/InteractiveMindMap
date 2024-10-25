import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:hackathon/custom_widgets/custom_textfield.dart';
import 'package:hackathon/models/user.dart';
import 'package:hackathon/screens/login_screen.dart';
import 'package:hackathon/services/user_db_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _auth = auth.FirebaseAuth.instance;
  final _userDbService = UserDbService();
  final nameTextField = CustomTextField(10, "Name", false);
  final surnameTextField = CustomTextField(10, "SurName", false);
  final userNamePasswordTextField = CustomTextField(10, "User Name", false);
  final emailTextField = CustomTextField(10, "Email", false);
  final passwordTextField = CustomTextField(10, "Password", false);
  final confirmPasswordTextField =
      CustomTextField(10, "Confirm Password", false);
  @override
  Widget build(BuildContext context) {
    List<CustomTextField> textFields = [
      nameTextField,
      surnameTextField,
      userNamePasswordTextField,
      emailTextField,
      passwordTextField,
      confirmPasswordTextField
    ];

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...textFields,
              ElevatedButton(
                  onPressed: () async {
                    for (CustomTextField textField in textFields) {
                      if (textField.getText().trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text("Lütfen tüm alanları doldurunuz")));
                        return;
                      }
                    }
                    if (passwordTextField.getText() !=
                        confirmPasswordTextField.getText()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Şifreler uyuşmuyor")));
                      return;
                    }
                    try {
                      final auth.UserCredential userCredential =
                          await _auth.createUserWithEmailAndPassword(
                        email: emailTextField.getText(),
                        password: passwordTextField.getText(),
                      );
                      final user = User(
                          userId: userCredential.user!.uid,
                          name: nameTextField.getText(),
                          surName: surnameTextField.getText(),
                          userName: userNamePasswordTextField.getText(),
                          email: emailTextField.getText());
                      _userDbService.createUser(user);
                      userCredential.user!.sendEmailVerification();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Doğrulama maili gönderildi")));
                    } on auth.FirebaseAuthException catch (e) {
                      if (e.code == 'weak-password') {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Şifre zayıf")));
                      } else if (e.code == 'email-already-in-use') {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Email zaten kullanımda")));
                      }
                    } catch (e) {
                      print(e);
                    }
                  },
                  child: const Text("Üye Ol")),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Zaten hesabın var mı?"),
                  TextButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          )),
                      child: const Text(
                        "Giriş Yap",
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
