import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DeveloperPlaygroundScreen extends ConsumerStatefulWidget {
  const DeveloperPlaygroundScreen({super.key});

  @override
  ConsumerState<DeveloperPlaygroundScreen> createState() => _DeveloperPlaygroundScreenState();
}

class _DeveloperPlaygroundScreenState extends ConsumerState<DeveloperPlaygroundScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer Playground (DO NOT SHIP)'),
        backgroundColor: Colors.red[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () => context.push('/founder-dashboard'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                padding: const EdgeInsets.all(16),
              ),
              child: const Text('OPEN FOUNDER DASHBOARD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.push('/chat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                padding: const EdgeInsets.all(16),
              ),
              child: const Text('TEST AI CHAT PIPELINE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24),
            const Card(
              color: Colors.white10,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Notice: Local pipeline execution is deprecated on the client. All adaptation and understanding engine tasks have been migrated to backend Supabase Edge Functions.',
                  style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
