import 'package:flutter/material.dart';
import 'package:hackathon/providers/workspace_provider.dart';
import 'package:provider/provider.dart';

class WorkspaceScreen extends StatefulWidget {
  const WorkspaceScreen({super.key});

  @override
  State<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends State<WorkspaceScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WorkSpaceProvider>(context);
    return InteractiveViewer(
        constrained: false,
        boundaryMargin: const EdgeInsets.all(5000),
        minScale: 0.5,
        maxScale: 2.0,
        child: Stack(
          clipBehavior: Clip.none,
          children: provider.getWorkspaceElements,
        ));
  }
}
