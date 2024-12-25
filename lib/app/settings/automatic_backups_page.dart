import 'package:flutter/material.dart';
import 'package:monekin/core/database/services/transaction/transaction_service.dart';
import 'package:monekin/core/database/backup/backup_database_service.dart';
import 'package:monekin/core/presentation/widgets/dates/outlinedButtonStacked.dart';
import 'package:monekin/core/presentation/widgets/persistent_footer_button.dart';
import 'package:monekin/core/presentation/widgets/transaction_filter/transaction_filters.dart';
import 'package:monekin/core/database/services/user-setting/user_setting_service.dart';
import 'package:monekin/core/utils/get_default_backup_path.dart';
import 'package:monekin/i18n/translations.g.dart';
import 'package:file_picker/file_picker.dart';

enum _BackupFrequencies { monthly, weekly, daily, onExit, onSave }

enum _BackupsToKeep { one, three, five, seven, ten, unlimited }

_BackupFrequencies _selectedBackupFrequency = _BackupFrequencies.monthly;

_BackupsToKeep _selectedBackupsToKeep = _BackupsToKeep.one;

List<DropdownMenuEntry> backupFrequencyOptions = [
  const DropdownMenuEntry(value: _BackupFrequencies.monthly, label: 'Monthly'),
  const DropdownMenuEntry(value: _BackupFrequencies.weekly, label: 'Weekly'),
  const DropdownMenuEntry(value: _BackupFrequencies.daily, label: 'Daily'),
  const DropdownMenuEntry(
      value: _BackupFrequencies.onExit, label: 'On app exit'),
  const DropdownMenuEntry(
      value: _BackupFrequencies.onSave, label: 'After every change')
];

List<DropdownMenuEntry> backupCleanupOptions = [
  const DropdownMenuEntry(value: _BackupsToKeep.one, label: '1'),
  const DropdownMenuEntry(value: _BackupsToKeep.three, label: '3'),
  const DropdownMenuEntry(value: _BackupsToKeep.five, label: '5'),
  const DropdownMenuEntry(value: _BackupsToKeep.seven, label: '7'),
  const DropdownMenuEntry(value: _BackupsToKeep.ten, label: '10'),
  const DropdownMenuEntry(value: _BackupsToKeep.unlimited, label: 'Unlimited'),
];

class AutomaticBackupsPage extends StatefulWidget {
  const AutomaticBackupsPage({super.key});

  @override
  State<AutomaticBackupsPage> createState() => _AutomaticBackupsPageState();
}

class _AutomaticBackupsPageState extends State<AutomaticBackupsPage> {
  bool localBackupsEnabled = false;
  bool deleteOldBackups = true;
  TextEditingController savePathTextController = TextEditingController();

  Widget localBackupSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownMenu(
            label: Text("Backup frequency"),
            dropdownMenuEntries: backupFrequencyOptions,
            initialSelection: backupFrequencyOptions[0],
            onSelected: (value) => changeBackupFrequency(value),
            expandedInsets: EdgeInsets.zero),
        CheckboxListTile.adaptive(
          title: const Text("Automatically delete old backups"),
          subtitle: const Text("Cleanup old backups after creating new ones"),
          contentPadding: EdgeInsets.zero,
          value: deleteOldBackups,
          onChanged: (value) => toggleDeleteOldBackups(value),
        ),
        if (deleteOldBackups) ...[
          Row(
            children: [
              Text("Keep the last"),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: DropdownMenu(
                  dropdownMenuEntries: backupCleanupOptions,
                  initialSelection: backupCleanupOptions[0],
                  onSelected: (value) => changeBackupsToKeep(value),
                  width: 150,
                  // inputDecorationTheme:
                  //     InputDecorationTheme(contentPadding: EdgeInsets.zero),
                ),
              ),
              Text("backups"),
            ],
          )
        ],
        const SizedBox(height: 20),
        TextField(
          controller: savePathTextController,
          readOnly: true,
          onTap: pickDirectory,
          decoration: const InputDecoration(
              labelText: 'Backup folder',
              suffixIcon: Icon(Icons.folder_open_rounded)),
        ),
      ],
    );
  }

  Future<void> setDefaultBackupPath() async {
    // savePathTextController.text = await getDownloadPath();
    savePathTextController.text = await getDefaultBackupPath();
  }

  Future<void> pickDirectory() async {
    // String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    // FilePickerResult? result =
    //     await FilePicker.platform.pickFiles(type: FileType.any);
    String? result = await FilePicker.platform
        .getDirectoryPath(initialDirectory: savePathTextController.text);
    if (result != null) {
      savePathTextController.text = '$result/';
    }
  }

  void toggleLocalBackups(bool newValue) {
    setState(() {
      localBackupsEnabled = newValue;
    });
  }

  void changeBackupFrequency(_BackupFrequencies newValue) {
    setState(() {
      _selectedBackupFrequency = newValue;
    });
  }

  void toggleDeleteOldBackups(bool? newValue) {
    if (newValue != null) {
      setState(() {
        deleteOldBackups = newValue;
      });
    }
  }

  void changeBackupsToKeep(_BackupsToKeep newValue) {
    setState(() {
      _selectedBackupsToKeep = newValue;
    });
  }

  @override
  void initState() {
    super.initState();
    setDefaultBackupPath();
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return Scaffold(
        appBar: AppBar(
          title: Text('Automatic backups'),
        ),
        body: Padding(
          padding: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Enable local backups"),
                  Switch.adaptive(
                      value: localBackupsEnabled,
                      onChanged: (value) => toggleLocalBackups(value)),
                ],
              ),
              if (localBackupsEnabled) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 10),
                  child: localBackupSettings(),
                )
              ]
            ],
          ),
        ));
  }
}
