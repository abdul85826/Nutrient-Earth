import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/auth/auth_service.dart';
import '../../../core/design_system/design_system.dart';
import '../domain/data_rights_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final dataRights = ref.watch(dataRightsProvider);

    return Scaffold(
      backgroundColor: NeTokens.warmIvory,
      appBar: AppBar(
        title: const Text(
          'Privacy & Data Rights',
          style: TextStyle(
            fontFamily: NeTokens.fontFamilySerif,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: NeTokens.deepForest,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: NeTokens.deepForest,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(NeTokens.spacing20),
          children: [
            // User Identity Card
            NeCard(
              padding: const EdgeInsets.all(NeTokens.spacing16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: NeTokens.botanicalEvergreen.withValues(
                        alpha: 0.12,
                      ),
                      borderRadius: BorderRadius.circular(NeTokens.radius16),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: NeTokens.botanicalEvergreen,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: NeTokens.spacing16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? 'Health Explorer',
                          style: const TextStyle(
                            fontFamily: NeTokens.fontFamilySans,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: NeTokens.deepForest,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.email ?? 'Local Sovereign Mode',
                          style: const TextStyle(
                            fontFamily: NeTokens.fontFamilySans,
                            fontSize: 12,
                            color: NeTokens.slateMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: user?.isGuest == true
                          ? NeTokens.sandDune.withValues(alpha: 0.5)
                          : NeTokens.mossGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(NeTokens.radiusFull),
                    ),
                    child: Text(
                      user?.isGuest == true
                          ? 'Sovereign Guest'
                          : 'Cloud Verified',
                      style: TextStyle(
                        fontFamily: NeTokens.fontFamilySans,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: user?.isGuest == true
                            ? NeTokens.deepForest
                            : NeTokens.botanicalEvergreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: NeTokens.spacing24),

            // Consent Ledger Section
            const Text(
              'Consent & Permissions Ledger',
              style: TextStyle(
                fontFamily: NeTokens.fontFamilySerif,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: NeTokens.deepForest,
              ),
            ),
            const SizedBox(height: NeTokens.spacing6),
            const Text(
              'Granular consent controls. Revoking permission immediately blocks processing for that data type.',
              style: TextStyle(
                fontFamily: NeTokens.fontFamilySans,
                fontSize: 12,
                color: NeTokens.slateMuted,
              ),
            ),
            const SizedBox(height: NeTokens.spacing12),

            ...dataRights.consents.map(
              (consent) => Padding(
                padding: const EdgeInsets.only(bottom: NeTokens.spacing8),
                child: NeCard(
                  padding: const EdgeInsets.all(NeTokens.spacing14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              consent.title,
                              style: const TextStyle(
                                fontFamily: NeTokens.fontFamilySans,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: NeTokens.deepForest,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              consent.description,
                              style: const TextStyle(
                                fontFamily: NeTokens.fontFamilySans,
                                fontSize: 11,
                                color: NeTokens.slateMuted,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: consent.isGranted,
                        activeTrackColor: NeTokens.botanicalEvergreen,
                        onChanged: (_) => ref
                            .read(dataRightsProvider.notifier)
                            .toggleConsent(consent.purposeId),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: NeTokens.spacing24),

            // Data Rights Section (Export & Deletion)
            const Text(
              'Your Data Rights (GDPR & CCPA)',
              style: TextStyle(
                fontFamily: NeTokens.fontFamilySerif,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: NeTokens.deepForest,
              ),
            ),
            const SizedBox(height: NeTokens.spacing12),

            // Export Archive Button
            NeButton(
              label: dataRights.isExporting
                  ? 'Generating Manifest...'
                  : 'Export Health Memory Archive (JSON)',
              icon: Icons.download_rounded,
              variant: NeButtonVariant.secondary,
              isLoading: dataRights.isExporting,
              onPressed: () async {
                final payload = await ref
                    .read(dataRightsProvider.notifier)
                    .generateExportArchive(user?.id ?? 'guest');
                if (context.mounted) {
                  await showDialog<void>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: NeTokens.warmIvory,
                      title: const Text('Health Memory Manifest Ready'),
                      content: SingleChildScrollView(
                        child: Text(
                          payload,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10,
                          ),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),

            const SizedBox(height: NeTokens.spacing12),

            // Account Deletion Button
            NeButton(
              label: 'Delete Account & Purge Health Memory',
              icon: Icons.delete_forever_rounded,
              variant: NeButtonVariant.ghost,
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: NeTokens.warmIvory,
                    title: const Text(
                      'Confirm Account Deletion',
                      style: TextStyle(
                        color: NeTokens.alertCrimson,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: const Text(
                      'This will immediately purge your local Health Memory, remove active auth sessions, and delete cloud data. This action is irreversible.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.of(ctx).pop();
                          await ref
                              .read(dataRightsProvider.notifier)
                              .executeAccountDeletion();
                          if (context.mounted) {
                            context.go('/login');
                          }
                        },
                        child: const Text(
                          'Permanently Delete',
                          style: TextStyle(
                            color: NeTokens.alertCrimson,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
