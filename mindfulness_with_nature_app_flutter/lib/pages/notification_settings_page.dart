import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../service/notification_service.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  late final TextEditingController _messageController;

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

  Future<void> _pickTime(NotificationService service) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: service.reminderTime ?? const TimeOfDay(hour: 7, minute: 30),
    );

    if (picked != null) {
      await service.setReminderTime(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final service = context.watch<NotificationService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Notification Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Daily reminder'),
            subtitle: Text(
              service.isReminderEnabled
                  ? 'Enabled'
                  : 'Disabled',
            ),
            value: service.isReminderEnabled,
            onChanged: (value) async {
              if (value) {
                final granted = await service.requestPermissions();
                if (!granted) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notification permissions denied.')),
                  );
                  return;
                }
              }

              await service.setReminderEnabled(value);
            },
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Reminder time'),
            subtitle: Text(service.reminderTime?.format(context) ?? 'Not set'),
            trailing: const Icon(Icons.schedule),
            onTap: service.isReminderEnabled ? () => _pickTime(service) : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<ReminderSound>(
            initialValue: service.reminderSound,
            decoration: const InputDecoration(
              labelText: 'Reminder sound',
              border: OutlineInputBorder(),
            ),
            items: ReminderSound.values
                .map(
                  (sound) => DropdownMenuItem<ReminderSound>(
                    value: sound,
                    child: Text('${sound.icon} ${sound.label}'),
                  ),
                )
                .toList(),
            onChanged: service.isReminderEnabled
                ? (sound) async {
                    if (sound != null) {
                      await service.setReminderSound(sound);
                    }
                  }
                : null,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _messageController,
            maxLength: 120,
            decoration: const InputDecoration(
              labelText: 'Reminder message',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (value) async {
              await service.setReminderMessage(value);
            },
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () async {
              await service.setReminderMessage(_messageController.text);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reminder message saved.')),
              );
            },
            icon: const Icon(Icons.save_outlined),
            label: const Text('Save message'),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
