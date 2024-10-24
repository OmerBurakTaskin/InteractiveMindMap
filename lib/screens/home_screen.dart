import 'package:flutter/material.dart';
import 'package:hackathon/providers/workspace_provider.dart';
import 'package:hackathon/screens/workspace_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WorkSpaceProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hackathon24"),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.add))],
      ),
      body: WorkspaceScreen(),
    );
  }
}
