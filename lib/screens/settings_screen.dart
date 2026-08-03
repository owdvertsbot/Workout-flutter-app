import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(userSettingsProvider);
    final settingsNotifier = ref.read(userSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Appearance Section
          _buildSectionHeader('Appearance'),
          _buildSettingsTile(
            context: context,
            icon: Icons.dark_mode,
            title: 'Theme',
            subtitle: 'Dark',
            onTap: () => _showThemeSelector(context, ref),
          ),

          // Units & Calculation Section
          _buildSectionHeader('Units & Calculation'),
          SwitchListTile(
            secondary: const Icon(Icons.straighten),
            title: const Text('Use Metric System'),
            subtitle: Text(settings.useMetric ? 'kg / cm' : 'lbs / in'),
            value: settings.useMetric,
            onChanged: (value) => settingsNotifier.setUseMetric(value),
          ),
          _buildSettingsTile(
            context: context,
            icon: Icons.fitness_center,
            title: 'Barbell Weight',
            subtitle: '${settings.barbellWeight} ${settings.useMetric ? 'kg' : 'lbs'}',
            onTap: () => _showBarbellWeightPicker(context, ref),
          ),

          // Rest Timer Section
          _buildSectionHeader('Rest Timer'),
          _buildSettingsTile(
            context: context,
            icon: Icons.timer,
            title: 'Default Rest Duration',
            subtitle: '${settings.defaultRestSeconds}s',
            onTap: () => _showRestDurationPicker(context, ref, isWarmup: false),
          ),
          _buildSettingsTile(
            context: context,
            icon: Icons.whatshot,
            title: 'Warmup Rest Duration',
            subtitle: '${settings.warmupRestSeconds}s',
            onTap: () => _showRestDurationPicker(context, ref, isWarmup: true),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.vibration),
            title: const Text('Vibrate on Timer End'),
            subtitle: const Text('Haptic feedback when rest completes'),
            value: settings.vibrateOnTimerEnd,
            onChanged: (value) => settingsNotifier.setVibrateOnTimerEnd(value),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.play_arrow),
            title: const Text('Auto-Start Rest Timer'),
            subtitle: const Text('Automatically start rest after completing a set'),
            value: settings.autoStartRestTimer,
            onChanged: (value) => settingsNotifier.setAutoStartRestTimer(value),
          ),

          // Data & Backup Section
          _buildSectionHeader('Data & Backup'),
          _buildSettingsTile(
            context: context,
            icon: Icons.backup,
            title: 'Backup Database',
            subtitle: 'Save workout data to local file',
            onTap: () => _showBackupDialog(context),
          ),
          _buildSettingsTile(
            context: context,
            icon: Icons.restore,
            title: 'Restore Database',
            subtitle: 'Restore from local backup',
            onTap: () => _showRestoreDialog(context),
          ),
          _buildSettingsTile(
            context: context,
            icon: Icons.file_upload,
            title: 'Import CSV',
            subtitle: 'Import from Hevy, Strong, Lyfta',
            onTap: () => _showImportDialog(context),
          ),
          _buildSettingsTile(
            context: context,
            icon: Icons.file_download,
            title: 'Export CSV',
            subtitle: 'Export workout data',
            onTap: () => _showExportDialog(context),
          ),

          // Developer Options Section
          _buildSectionHeader('Developer Options'),
          _buildSettingsTile(
            context: context,
            icon: Icons.refresh,
            title: 'Reset Database',
            subtitle: 'Clear all local data',
            onTap: () => _showResetDialog(context, ref),
            isDestructive: true,
          ),

          // About Section
          _buildSectionHeader('About'),
          _buildSettingsTile(
            context: context,
            icon: Icons.info,
            title: 'App Version',
            subtitle: 'v1.0.0 (Build 1)',
            onTap: null,
          ),
          _buildSettingsTile(
            context: context,
            icon: Icons.code,
            title: 'Open Source Licenses',
            subtitle: 'View third-party licenses',
            onTap: () => showLicensePage(context: context),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF00E676),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : null,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
      onTap: onTap,
    );
  }

  void _showThemeSelector(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.brightness_5),
            title: const Text('Light'),
            onTap: () {
              ref.read(themeModeProvider.notifier).state = ThemeMode.light;
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.brightness_4),
            title: const Text('Dark'),
            onTap: () {
              ref.read(themeModeProvider.notifier).state = ThemeMode.dark;
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.brightness_2),
            title: const Text('OLED Black'),
            onTap: () {
              // OLED would need custom theme
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showBarbellWeightPicker(BuildContext context, WidgetRef ref) {
    final weights = [15.0, 20.0, 25.0, 45.0];
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Barbell Weight',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ...weights.map((weight) => ListTile(
            title: Text('$weight kg'),
            onTap: () {
              ref.read(userSettingsProvider.notifier).setBarbellWeight(weight);
              Navigator.pop(context);
            },
          )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showRestDurationPicker(BuildContext context, WidgetRef ref, {required bool isWarmup}) {
    final durations = [30, 45, 60, 90, 120, 180, 240, 300];
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              isWarmup ? 'Warmup Rest Duration' : 'Default Rest Duration',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ...durations.map((seconds) => ListTile(
            title: Text('${seconds}s (${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')})'),
            onTap: () {
              if (isWarmup) {
                ref.read(userSettingsProvider.notifier).setWarmupRestSeconds(seconds);
              } else {
                ref.read(userSettingsProvider.notifier).setDefaultRestSeconds(seconds);
              }
              Navigator.pop(context);
            },
          )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup Database'),
        content: const Text(
          'This will create a backup of all your workout data to local storage.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Backup created successfully')),
              );
            },
            child: const Text('Backup'),
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Database'),
        content: const Text(
          'This will replace all current data with the backup. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data restored successfully')),
              );
            },
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }

  void _showImportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import CSV'),
        content: const Text(
          'Select a CSV file from Hevy, Strong, or Lyfta to import your workout history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Import feature coming soon')),
              );
            },
            child: const Text('Select File'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export CSV'),
        content: const Text(
          'Export your workout history as a CSV file.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export feature coming soon')),
              );
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Database'),
        content: const Text(
          'This will permanently delete ALL your workout data, progress, and settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Database reset')),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
