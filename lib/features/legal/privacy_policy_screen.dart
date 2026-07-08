import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Privacy Policy'), backgroundColor: Colors.black),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Text(
          '''Nutrient Earth Privacy Policy (Alpha)

Data Collection:
We collect biological inputs, daily check-in responses, and usage data to build your personal knowledge graph.

Data Usage:
Your data is used strictly for calculating recommendations, predicting health trajectories, and finding scientific matches for your biological state. 

Third Parties:
During Alpha, data is stored on secure cloud servers. We do not sell your data.

By participating in the Alpha, you acknowledge that Nutrient Earth is not a medical device and should not replace professional medical advice.''',
          style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
        ),
      ),
    );
  }
}
