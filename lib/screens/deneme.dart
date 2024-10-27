import 'package:flutter/material.dart';

class DenemeScreen extends StatefulWidget {
  const DenemeScreen({super.key});

  @override
  State<DenemeScreen> createState() => _DenemeScreenState();
}

class _DenemeScreenState extends State<DenemeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InteractiveViewer(
        //transformationController: provider.transformationController,
        boundaryMargin: const EdgeInsets.all(double.infinity),
        minScale: 0.1,
        maxScale: 2.0,
        child: SizedBox(
          width: 10000,
          height: 10000,
          child: Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.none,
            children: [
              Positioned(
                  top: 800,
                  left: 800,
                  child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        print("FŞALSDKJALKSDJFLSŞKDFLKJFLKSDAF");
                      },
                      child: Text("fadsşlfjasdklf")))
            ],
          ),
        ),
      ),
    );
    ;
  }
}
