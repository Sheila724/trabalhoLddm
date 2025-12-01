import 'package:intl/intl.dart';

class Service {
  int? id;
  String date; 
  String clientName;
  String deviceName;
  String serialNumber;
  String reason;
  String servicePerformed;
  double value;
  String status; 

  Service({
    this.id,
    required this.date,
    required this.clientName,
    required this.deviceName,
    required this.serialNumber,
    required this.reason,
    required this.servicePerformed,
    required this.value,
    bool finalized = false,
    String? status,
  }) : status = status ?? (finalized ? 'finalized' : 'pending');

  factory Service.fromMap(Map<String, dynamic> map) {
    String status;
    if (map.containsKey('status') && map['status'] != null) {
      status = map['status'] as String;
    } else if (map.containsKey('finalized')) {
      status = ((map['finalized'] ?? 0) == 1) ? 'finalized' : 'pending';
    } else {
      status = 'pending';
    }

    return Service(
      id: map['id'] as int?,
      date: map['date'] as String,
      clientName: map['clientName'] as String,
      deviceName: map['deviceName'] as String,
      serialNumber: map['serialNumber'] as String,
      reason: map['reason'] as String,
      servicePerformed: map['servicePerformed'] as String,
      value: (map['value'] is int) ? (map['value'] as int).toDouble() : (map['value'] as double),
      status: status,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'date': date,
      'clientName': clientName,
      'deviceName': deviceName,
      'serialNumber': serialNumber,
      'reason': reason,
      'servicePerformed': servicePerformed,
      'value': value,
      'status': status,
    };
    if (id != null) map['id'] = id;
    return map;
  }

  DateTime get dateTime {
    try {
      return DateFormat('dd/MM/yyyy').parse(date);
    } catch (_) {
      // tenta parse ISO ou devolve epoch se falhar
      final iso = DateTime.tryParse(date);
      return iso ?? DateTime.fromMillisecondsSinceEpoch(0);
    }
  }

  bool get finalized => status == 'finalized';
  set finalized(bool v) => status = v ? 'finalized' : 'pending';
}
