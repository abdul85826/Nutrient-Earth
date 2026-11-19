// ==============================================================================
// Nutrient Earth — Communication Preferences Modal
// Part of God Mode User Lifecycle, Retention & Communication Intelligence
// ==============================================================================

import 'package:flutter/material.dart';
import '../../../../core/design_system/tokens/ne_tokens.dart';
import '../../../../core/domain/communication/communication_models.dart';
import '../../../../core/services/communication/central_communication_engine.dart';

class CommunicationPreferencesModal extends StatefulWidget {
  final String userId;
  final CentralCommunicationEngine communicationEngine;

  const CommunicationPreferencesModal({
    super.key,
    required this.userId,
    required this.communicationEngine,
  });

  static Future<void> show(
    BuildContext context, {
    required String userId,
    required CentralCommunicationEngine communicationEngine,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CommunicationPreferencesModal(
        userId: userId,
        communicationEngine: communicationEngine,
      ),
    );
  }

  @override
  State<CommunicationPreferencesModal> createState() =>
      _CommunicationPreferencesModalState();
}

class _CommunicationPreferencesModalState
    extends State<CommunicationPreferencesModal> {
  bool _isLoading = true;
  bool _isSaving = false;

  late bool _channelPush;
  late bool _channelEmail;
  late bool _channelInApp;

  late bool _catGoalReminders;
  late bool _catResearchDigests;
  late bool _catReEngagement;

  late String _quietStart;
  late String _quietEnd;
  late int _dailyCap;
  late int _weeklyCap;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs =
        await widget.communicationEngine.getPreferences(widget.userId);
    if (mounted) {
      setState(() {
        _channelPush = prefs.channelPushEnabled;
        _channelEmail = prefs.channelEmailEnabled;
        _channelInApp = prefs.channelInAppEnabled;
        _catGoalReminders = prefs.categoryGoalReminders;
        _catResearchDigests = prefs.categoryResearchDigests;
        _catReEngagement = prefs.categoryReEngagement;
        _quietStart = prefs.quietHoursStart;
        _quietEnd = prefs.quietHoursEnd;
        _dailyCap = prefs.dailyFrequencyCap;
        _weeklyCap = prefs.weeklyFrequencyCap;
        _isLoading = false;
      });
    }
  }

  Future<void> _savePreferences() async {
    setState(() => _isSaving = true);
    final updated = CommunicationPreferencesEntity(
      userId: widget.userId,
      channelPushEnabled: _channelPush,
      channelEmailEnabled: _channelEmail,
      channelInAppEnabled: _channelInApp,
      categoryGoalReminders: _catGoalReminders,
      categoryResearchDigests: _catResearchDigests,
      categorySecurityAlerts: true,
      categoryReEngagement: _catReEngagement,
      quietHoursStart: _quietStart,
      quietHoursEnd: _quietEnd,
      dailyFrequencyCap: _dailyCap,
      weeklyFrequencyCap: _weeklyCap,
      updatedAt: DateTime.now().toUtc(),
    );

    await widget.communicationEngine.updatePreferences(updated);
    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Communication preferences saved.'),
          backgroundColor: NETokens.botanicalTeal,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: NETokens.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: NETokens.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Communication Settings',
                  style: TextStyle(
                    fontFamily: 'Fraunces',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: NETokens.deepestForest,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: NETokens.deepestForest),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(color: NETokens.surfaceDim, height: 1),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: NETokens.botanicalTeal,
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    children: [
                      _buildSectionHeader('DELIVERY CHANNELS'),
                      _buildSwitchTile(
                        title: 'Push Notifications',
                        subtitle: 'Circadian nudges and movement reminders',
                        value: _channelPush,
                        onChanged: (v) => setState(() => _channelPush = v),
                      ),
                      _buildSwitchTile(
                        title: 'Email Communications',
                        subtitle: 'Weekly scientific digests and account exports',
                        value: _channelEmail,
                        onChanged: (v) => setState(() => _channelEmail = v),
                      ),
                      _buildSwitchTile(
                        title: 'In-App Notification Feed',
                        subtitle: 'Non-intrusive updates in your inbox',
                        value: _channelInApp,
                        onChanged: (v) => setState(() => _channelInApp = v),
                      ),
                      const SizedBox(height: 16),
                      _buildSectionHeader('CATEGORIES'),
                      _buildSwitchTile(
                        title: 'Goal & Movement Reminders',
                        subtitle: 'Gentle nudges aligned with diurnal rhythm',
                        value: _catGoalReminders,
                        onChanged: (v) => setState(() => _catGoalReminders = v),
                      ),
                      _buildSwitchTile(
                        title: 'Scientific Research Digests',
                        subtitle: 'Peer-reviewed studies on active nutrients',
                        value: _catResearchDigests,
                        onChanged: (v) =>
                            setState(() => _catResearchDigests = v),
                      ),
                      _buildSwitchTile(
                        title: 'Re-engagement & Seasonal Recaps',
                        subtitle: 'Transitions based on seasonal changes',
                        value: _catReEngagement,
                        onChanged: (v) =>
                            setState(() => _catReEngagement = v),
                      ),
                      _buildLockedTile(
                        title: 'Security & Integrity Alerts',
                        subtitle: 'Mandatory cryptographic and account safety',
                      ),
                      const SizedBox(height: 16),
                      _buildSectionHeader('QUIET HOURS & PACING'),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: NETokens.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: NETokens.borderSubtle),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Quiet Hours Window',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: NETokens.deepestForest,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'No automated reminders will be sent between $_quietStart and $_quietEnd local time.',
                              style: const TextStyle(
                                fontSize: 13,
                                color: NETokens.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTimeSelector(
                                    label: 'Start (Night)',
                                    value: _quietStart,
                                    onSelected: (val) =>
                                        setState(() => _quietStart = val),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildTimeSelector(
                                    label: 'End (Morning)',
                                    value: _quietEnd,
                                    onSelected: (val) =>
                                        setState(() => _quietEnd = val),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSectionHeader('FREQUENCY CAPS'),
                      Text(
                        'Daily Limit: $_dailyCap messages / day',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: NETokens.deepestForest,
                        ),
                      ),
                      Slider(
                        value: _dailyCap.toDouble(),
                        min: 1,
                        max: 10,
                        divisions: 9,
                        activeColor: NETokens.botanicalTeal,
                        inactiveColor: NETokens.paleMint,
                        onChanged: (v) =>
                            setState(() => _dailyCap = v.toInt()),
                      ),
                      Text(
                        'Weekly Limit: $_weeklyCap messages / week',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: NETokens.deepestForest,
                        ),
                      ),
                      Slider(
                        value: _weeklyCap.toDouble(),
                        min: 5,
                        max: 30,
                        divisions: 25,
                        activeColor: NETokens.botanicalTeal,
                        inactiveColor: NETokens.paleMint,
                        onChanged: (v) =>
                            setState(() => _weeklyCap = v.toInt()),
                      ),
                    ],
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: NETokens.deepestForest,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isSaving ? null : _savePreferences,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Save Preferences',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
          color: NETokens.mutedSage,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: NETokens.deepestForest,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: NETokens.onSurfaceVariant,
        ),
      ),
      value: value,
      activeColor: NETokens.botanicalTeal,
      onChanged: onChanged,
    );
  }

  Widget _buildLockedTile({
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: NETokens.deepestForest,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: NETokens.onSurfaceVariant,
        ),
      ),
      trailing: const Icon(
        Icons.lock_outline_rounded,
        size: 20,
        color: NETokens.outline,
      ),
    );
  }

  Widget _buildTimeSelector({
    required String label,
    required String value,
    required ValueChanged<String> onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: NETokens.onSurfaceVariant),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: NETokens.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: NETokens.outlineVariant),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: NETokens.deepestForest,
              ),
              items: [
                '20:00',
                '21:00',
                '22:00',
                '23:00',
                '06:00',
                '07:00',
                '08:00',
                '09:00',
              ].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (val) {
                if (val != null) onSelected(val);
              },
            ),
          ),
        ),
      ],
    );
  }
}
