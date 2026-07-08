import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Terms of Service'), backgroundColor: Colors.black),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Text(
          '''Nutrient Earth Terms of Service (Alpha)

1. Acceptance
By using the Alpha build, you agree to these terms.

2. Not Medical Advice
Nutrient Earth provides scientific insights based on biological inputs. It does not diagnose, treat, or cure diseases.

3. Volatility
This is an Alpha product. Features may change, break, or be removed without notice.

4. Limitation of Liability
Nutrient Earth is not liable for any health decisions made based on the app's recommendations.''',
          style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
        ),
      ),
    );
  }
}
