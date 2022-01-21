import 'package:clock_loader/clock_loader.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ClockLoaderPage(),
    );
  }
}

class ClockLoaderPage extends StatefulWidget {
  const ClockLoaderPage({Key? key}) : super(key: key);

  @override
  State<ClockLoaderPage> createState() => _ClockLoaderPageState();
}

class _ClockLoaderPageState extends State<ClockLoaderPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFFff5558),
        child: SimpleSquare(
          clockLoaderModel: ClockLoaderModel(
            shapeOfParticles: ShapeOfParticlesEnum.circle,
            mainHandleColor: Colors.grey.shade100,
            particlesColor: Colors.grey.shade100,
          ),
        ),
      ),
    );
  }
}
