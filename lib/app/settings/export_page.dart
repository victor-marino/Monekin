import 'package:flutter/material.dart';
import 'package:monekin/core/database/services/transaction/transaction_service.dart';
import 'package:monekin/core/database/backup/backup_database_service.dart';
import 'package:monekin/core/presentation/widgets/dates/outlinedButtonStacked.dart';
import 'package:monekin/core/presentation/widgets/persistent_footer_button.dart';
import 'package:monekin/core/presentation/widgets/transaction_filter/transaction_filters.dart';
import 'package:monekin/core/utils/get_default_backup_path.dart';
import 'package:monekin/i18n/translations.g.dart';
import 'package:file_picker/file_picker.dart';

enum _ExportFormats { csv, db }

class ExportDataPage extends StatefulWidget {
  const ExportDataPage({super.key});

  @override
  State<ExportDataPage> createState() => _ExportDataPageState();
}

class _ExportDataPageState extends State<ExportDataPage> {
  _ExportFormats selectedExportFormat = _ExportFormats.db;

  TransactionFilters filters = const TransactionFilters();
  TextEditingController savePathTextController = TextEditingController();

  Widget cardSelector({
    required _ExportFormats exportFormat,
    required String title,
    required String descr,
  }) {
    final isSelected = selectedExportFormat == exportFormat;

    return Container(
      margin: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
      child: OutlinedButtonStacked(
        text: title,
        filled: isSelected,
        fontSize: 20,
        alignLeft: true,
        alignBeside: true,
        padding: const EdgeInsets.all(10),
        onTap: () {
          selectedExportFormat = exportFormat;

          if (selectedExportFormat == _ExportFormats.db) {
            filters = const TransactionFilters();
          }

          setState(() {});
        },
        iconData: exportFormat == _ExportFormats.csv
            ? Icons.format_quote
            : Icons.security,
        afterWidget: Text(descr),
      ),
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
          title: Text(t.backup.export.title),
        ),
        persistentFooterButtons: [
          PersistentFooterButton(
              child: FilledButton(
            child: Text(t.backup.export.title),
            onPressed: () async {
              final messeger = ScaffoldMessenger.of(context);

              if (selectedExportFormat == _ExportFormats.db) {
                await BackupDatabaseService()
                    .backupDatabaseFile(context, savePathTextController.text)
                    .then((value) {
                  print('EEEEEEEEEEE');
                }).catchError((err) {
                  print(err);
                });
              } else {
                await BackupDatabaseService()
                    .exportSpreadsheet(
                        context,
                        savePathTextController.text,
                        await TransactionService.instance
                            .getTransactions(filters: filters)
                            .first)
                    .then((value) {
                  messeger.showSnackBar(SnackBar(
                    content: Text(t.backup.export.success(x: value)),
                  ));
                }).catchError((err) {
                  messeger.showSnackBar(SnackBar(
                    content: Text('$err'),
                  ));
                });
              }
            },
          ))
        ],
        body: Column(
          children: [
            cardSelector(
              exportFormat: _ExportFormats.db,
              title: t.backup.export.all,
              descr: t.backup.export.all_descr,
            ),
            cardSelector(
              exportFormat: _ExportFormats.csv,
              title: t.backup.export.transactions,
              descr: t.backup.export.transactions_descr,
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
              child: TextField(
                controller: savePathTextController,
                readOnly: true,
                onTap: pickDirectory,
                decoration: const InputDecoration(
                    labelText: 'Backup folder',
                    suffixIcon: Icon(Icons.folder_open_rounded)),
              ),
            )
            // * -----------------------------------
            // * -----------------------------------
            // * -----------------------------------
            // TODO: --------- ADD FILTERS ---------
            // * -----------------------------------
            // * -----------------------------------
            // * -----------------------------------
          ],
        ));
  }
}
