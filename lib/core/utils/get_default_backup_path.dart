import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Since the `path_provider` library do not support the download path for android, this functions try to find it and get another directory for the download if fails. See: https://pub.dev/packages/path_provider#supported-platforms-and-paths
Future<String> getDefaultBackupPath() async {
  String backupPath = (await getTemporaryDirectory()).path;

  if (!Platform.isAndroid) {
    final newPath = (await getDownloadsDirectory());
    if (newPath != null) {
      backupPath = newPath.path;
    }
  } else if ((await Directory('/storage/emulated/0/Download/').exists())) {
    backupPath = '/storage/emulated/0/Download/';
  } else {
    final newPath = (await getExternalStorageDirectory());
    if (newPath != null) {
      backupPath = newPath.path;
    }
  }

  return '${backupPath}Monekin/';
}
