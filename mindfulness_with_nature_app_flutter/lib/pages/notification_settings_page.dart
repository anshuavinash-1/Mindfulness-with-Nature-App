import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../service/notification_service.dart';

class NotificationSettingsPage extends StatefulWidget {
  final bool isGuest;

  const NotificationSettingsPage({super.key, this.isGuest = false});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  late TextEditingController _messageController;
  bool _editingMessage = false;

  @override
  void initState() {
    super.initState();
    final service = context.read<NotificationService>();
    _messageController = TextEditingController(text: service.reminderMessage);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────
  Future<void> _pickTime(NotificationService service) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: service.reminderTime ?? const TimeOfDay(hour: 7, minute: 30),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3D2B1F),
              onPrimary: Colors.white,
              surface: Color(0xFFF5F0E8),
              onSurface: Color(0xFF3D2B1F),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF3D2B1F),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) await service.setReminderTime(picked);
  }

  void _saveMessage(NotificationService service) {
    service.setReminderMessage(_messageController.text);
    setState(() => _editingMessage = false);
    FocusScope.of(context).unfocus();
  }

  // ── Build ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final service = context.watch<NotificationService>();
    final canConfigureReminders = !widget.isGuest;
    final reminderEnabled = canConfigureReminders && service.isReminderEnabled;

    return Scaffold(
      backgroundColor: const Color(0xFFD6CBC0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3D2B1F),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Notification Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Main toggle card ──────────────────────────────────────────────
            _SectionCard(
              child: _ToggleRow(
                icon: reminderEnabled
                    ? Icons.notifications_active
                    : Icons.notifications_off_outlined,
                iconColor: reminderEnabled
                    ? const Color(0xFF6B9080)
                    : const Color(0xFF9E8F80),
                title: 'Time to go outside',
                subtitle: widget.isGuest
                    ? 'Guests cannot enable reminders. Sign in to use this feature.'
                    : !service.isNotificationSupported
                        ? (service.supportMessage ??
                            'Notifications are unavailable on this platform.')
                        : (reminderEnabled
                            ? 'Your mindful moment is scheduled'
                            : 'Turn on to build a daily habit'),
                value: reminderEnabled,
                onChanged: (v) async {
                  if (widget.isGuest) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please sign in to enable daily reminders.',
                          ),
                        ),
                      );
                    }
                    return;
                  }

                  if (!service.isNotificationSupported) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            service.supportMessage ??
                                'Notifications are unavailable on this platform.',
                          ),
                        ),
                      );
                    }
                    return;
                  }

                  if (v && service.reminderTime == null) {
                    await _pickTime(service);
                  }
                  if (v && service.reminderTime != null) {
                    final granted = await service.requestPermissions();
                    if (!granted && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Notification permission is required to enable reminders.',
                          ),
                        ),
                      );
                      return;
                    }
                  }
                  if (service.reminderTime != null || !v) {
                    await service.setReminderEnabled(v);
                  }
                },
              ),
            ),

            if (reminderEnabled) ...[
              const SizedBox(height: 16),

              // ── Time picker ───────────────────────────────────────────────
              _SectionLabel(label: 'SCHEDULED TIME'),
              const SizedBox(height: 8),
              _SectionCard(
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _pickTime(service),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3D2B1F),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.access_time,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Reminder time',
                                style: TextStyle(
                                  color: Color(0xFF7A6A5A),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                service.reminderTime?.format(context) ??
                                    'Tap to set time',
                                style: const TextStyle(
                                  color: Color(0xFF3D2B1F),
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: Color(0xFF9E8F80),
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Sound picker ──────────────────────────────────────────────
              _SectionLabel(label: 'NOTIFICATION SOUND'),
              const SizedBox(height: 8),
              _SectionCard(
                child: Column(
                  children: ReminderSound.values.map((sound) {
                    final isSelected = service.reminderSound == sound;
                    final isLast = sound == ReminderSound.values.last;
                    return Column(
                      children: [
                        _SoundOption(
                          sound: sound,
                          isSelected: isSelected,
                          onTap: () => service.setReminderSound(sound),
                        ),
                        if (!isLast)
                          Divider(
                            height: 1,
                            thickness: 0.5,
                            color: const Color(0xFFCCC0B0).withOpacity(0.5),
                          ),
                      ],
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 20),

              // ── Custom message ────────────────────────────────────────────
              _SectionLabel(label: 'NOTIFICATION MESSAGE'),
              const SizedBox(height: 8),
              _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAB8A3).withOpacity(0.4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.chat_bubble_outline,
                            color: Color(0xFF8B5E3C),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Text(
                            'Custom reminder text',
                            style: TextStyle(
                              color: Color(0xFF3D2B1F),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (_editingMessage) {
                              _saveMessage(service);
                            } else {
                              setState(() => _editingMessage = true);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _editingMessage
                                  ? const Color(0xFF3D2B1F)
                                  : const Color(0xFFEBE3D8),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _editingMessage ? 'Save' : 'Edit',
                              style: TextStyle(
                                color: _editingMessage
                                    ? Colors.white
                                    : const Color(0xFF3D2B1F),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 200),
                      crossFadeState: _editingMessage
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      firstChild: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEBE3D8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          service.reminderMessage,
                          style: const TextStyle(
                            color: Color(0xFF5A4A3A),
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      secondChild: TextField(
                        controller: _messageController,
                        maxLength: 120,
                        maxLines: 2,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFEBE3D8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.all(12),
                          hintText: 'Write your reminder message…',
                          hintStyle: const TextStyle(
                            color: Color(0xFF9E8F80),
                          ),
                          counterStyle: const TextStyle(
                            color: Color(0xFF9E8F80),
                            fontSize: 11,
                          ),
                        ),
                        style: const TextStyle(
                          color: Color(0xFF3D2B1F),
                          fontSize: 14,
                        ),
                        onSubmitted: (_) => _saveMessage(service),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Summary card ──────────────────────────────────────────────
              _ScheduleSummaryCard(service: service),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ── Reusable sub-widgets ──────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF7A6A5A),
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F0E8),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.18),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF3D2B1F),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF7A6A5A),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF3D2B1F),
          activeTrackColor: const Color(0xFF8B7355),
        ),
      ],
    );
  }
}

class _SoundOption extends StatelessWidget {
  final ReminderSound sound;
  final bool isSelected;
  final VoidCallback onTap;

  const _SoundOption({
    required this.sound,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 4),
        child: Row(
          children: [
            Text(sound.icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                sound.label,
                style: const TextStyle(
                  color: Color(0xFF3D2B1F),
                  fontSize: 15,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    isSelected ? const Color(0xFF3D2B1F) : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF3D2B1F)
                      : const Color(0xFFCCC0B0),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleSummaryCard extends StatelessWidget {
  final NotificationService service;
  const _ScheduleSummaryCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF3D2B1F),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your reminder is set',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          _SummaryRow(
            icon: Icons.access_time,
            text: service.reminderTime?.format(context) ?? '—',
          ),
          const SizedBox(height: 6),
          _SummaryRow(
            icon: Icons.volume_up_outlined,
            text: service.reminderSound.label,
          ),
          const SizedBox(height: 6),
          _SummaryRow(
            icon: Icons.chat_bubble_outline,
            text: service.reminderMessage,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _SummaryRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white54, size: 16),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
