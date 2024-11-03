import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hackathon/firebase_options.dart';
import 'package:hackathon/home_page.dart';
import 'package:hackathon/providers/workspace_provider.dart';
import 'package:hackathon/screens/get_started_screen.dart';
import 'package:hackathon/screens/login_screen.dart';
import 'package:hackathon/services/user_db_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

bool gotInitialInfo = false;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  gotInitialInfo = await UserDbService()
      .userHasPersonalInfo(FirebaseAuth.instance.currentUser!.uid);
  FirebaseFirestore.instance.settings =
      const Settings(persistenceEnabled: true);
  await Hive.initFlutter();
  await Hive.openBox("userpersonalinfo");
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _auth = FirebaseAuth.instance;

  Widget getInitialScreen() {
    final bool mailVerified =
        _auth.currentUser == null ? false : _auth.currentUser!.emailVerified;
    if (mailVerified) {
      if (gotInitialInfo) {
        return HomePage();
      }
      return const GetStartedScreen();
    }
    return const LoginScreen();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => WorkSpaceProvider())
      ],
      child: MaterialApp(
        title: 'Hackathon24',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
          useMaterial3: true,
        ),
        home: getInitialScreen(),
      ),
    );
  }
}
