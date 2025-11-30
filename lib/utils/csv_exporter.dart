import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/service.dart';

class CsvExporter {
  static Future<String> exportServices(List<Service> services) async {
    final now = DateTime.now();
    final stamp = DateFormat('yyyyMMdd_HHmmss').format(now);
    final fileName = 'services_$stamp.csv';

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');

    final sb = StringBuffer();
    sb.writeln('id,date,clientName,deviceName,serialNumber,reason,servicePerformed,value,finalized,status');
    for (final s in services) {
      final line = [
        s.id ?? '',
        '"${s.date}"',
        '"${s.clientName.replaceAll('"', '\"')}"',
        '"${s.deviceName.replaceAll('"', '\"')}"',
        '"${s.serialNumber.replaceAll('"', '\"')}"',
        '"${s.reason.replaceAll('"', '\"')}"',
        '"${s.servicePerformed.replaceAll('"', '\"')}"',
        s.value.toStringAsFixed(2),
        s.finalized ? '1' : '0',
        '"${s.status}"',
      ].join(',');
      sb.writeln(line);
    }

    await file.writeAsString(sb.toString());
    return file.path;
  }
}
