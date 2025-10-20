
import 'package:flutter/material.dart';

class NoviceSignupPage extends StatelessWidget {
  const NoviceSignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novice Signup'),
      ),
      body: const Center(
        child: Text('This is the novice signup page.'),
      ),
    );
  }
}
