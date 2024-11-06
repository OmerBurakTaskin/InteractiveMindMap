import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hackathon/custom_colors.dart';
import 'package:hackathon/widgets/hero_dialog_route.dart';
import 'package:hackathon/screens/create_workspace_screen.dart';
import 'package:hackathon/screens/home_screen.dart';
import 'package:hackathon/screens/my_materials_screen.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final List<Widget> _screens = [const HomeScreen(), const MyMaterialsScreen()];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("MindStock"),
          actions: [
            IconButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  SystemNavigator.pop();
                },
                icon: const Icon(Icons.logout))
          ],
        ),
        body: _screens[_currentIndex],
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: _addWSButton(),
        bottomNavigationBar: BottomAppBar(
          color: deneme,
          shape:
              const CircularNotchedRectangle(), // FAB için dairesel bir çentik
          notchMargin: 6.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              TextButton.icon(
                label: Text(
                  "Ana Sayfa",
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: _currentIndex == 0
                          ? FontWeight.bold
                          : FontWeight.normal),
                ),
                icon: const Icon(Icons.home, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _currentIndex = 0;
                  });
                },
              ),
              TextButton.icon(
                label: Text(
                  "Materyallerim",
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: _currentIndex == 1
                          ? FontWeight.bold
                          : FontWeight.normal),
                ),
                icon: const Icon(Icons.book_rounded, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _currentIndex = 1;
                  });
                },
              ),
            ],
          ),
        ));
  }

  Widget _addWSButton() {
    return Container(
      decoration:
          BoxDecoration(color: color3, borderRadius: BorderRadius.circular(32)),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(HeroDialogRoute(builder: (context) {
            return CreateWorkspaceScreen();
          }));
        },
        child: Hero(
          tag: "createWS",
          child: Material(
            color: color3,
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            child: const Padding(
              padding: EdgeInsets.all(12.0),
              child: Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
