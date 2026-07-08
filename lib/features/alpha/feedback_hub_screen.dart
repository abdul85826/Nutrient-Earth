import 'package:flutter/material.dart';

class FeedbackHubScreen extends StatefulWidget {
  const FeedbackHubScreen({super.key});

  @override
  State<FeedbackHubScreen> createState() => _FeedbackHubScreenState();
}

class _FeedbackHubScreenState extends State<FeedbackHubScreen> {
  final _textController = TextEditingController();
  String _feedbackType = 'Bug Report';

  void _submit() {
    if (_textController.text.trim().isEmpty) return;
    
    // In reality, this would send to Supabase or Sentry
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Feedback submitted! Thank you.')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Alpha Feedback Hub'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _feedbackType,
              dropdownColor: Colors.grey[900],
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Feedback Type',
                labelStyle: TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white10,
              ),
              items: ['Bug Report', 'Suggest Feature', 'General Feedback', 'Rate Experience']
                  .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              onChanged: (val) => setState(() => _feedbackType = val!),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _textController,
              maxLines: 5,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Details',
                labelStyle: TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white10,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('SUBMIT FEEDBACK', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () {
                // Future: Export local database or execution traces
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logs exported successfully (Dev Mode)')),
                );
              },
              icon: const Icon(Icons.download, color: Colors.white70),
              label: const Text('Export Logs (Dev Mode)', style: TextStyle(color: Colors.white70)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
