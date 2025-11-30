import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/db_helper.dart';
import '../models/service.dart';

class AddServicePage extends StatefulWidget {
  final Service? service;
  const AddServicePage({Key? key, this.service}) : super(key: key);

  @override
  State<AddServicePage> createState() => _AddServicePageState();
}

class _AddServicePageState extends State<AddServicePage> {
  final _formKey = GlobalKey<FormState>();
  final _clientController = TextEditingController();
  final _deviceController = TextEditingController();
  final _serialController = TextEditingController();
  final _reasonController = TextEditingController();
  final _serviceController = TextEditingController();
  final _valueController = TextEditingController();
  String _status = 'pending';
  String _date = DateFormat('dd/MM/yyyy').format(DateTime.now());

  @override
  void dispose() {
    _clientController.dispose();
    _deviceController.dispose();
    _serialController.dispose();
    _reasonController.dispose();
    _serviceController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    final value = double.tryParse(_valueController.text.replaceAll(',', '.')) ?? 0.0;

    if (widget.service != null) {
      final s = widget.service!;
      s.date = _date;
      s.clientName = _clientController.text.trim();
      s.deviceName = _deviceController.text.trim();
      s.serialNumber = _serialController.text.trim();
      s.reason = _reasonController.text.trim();
      s.servicePerformed = _serviceController.text.trim();
      s.value = value;
      s.status = _status;
      await DatabaseHelper.instance.updateService(s);
    } else {
      final service = Service(
        date: _date,
        clientName: _clientController.text.trim(),
        deviceName: _deviceController.text.trim(),
        serialNumber: _serialController.text.trim(),
        reason: _reasonController.text.trim(),
        servicePerformed: _serviceController.text.trim(),
        value: value,
        status: _status,
      );
      await DatabaseHelper.instance.insertService(service);
    }
    Navigator.of(context).pop(true);
  }

  Future _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = DateFormat('dd/MM/yyyy').format(picked));
  }

  @override
  void initState() {
    super.initState();
    if (widget.service != null) {
      final s = widget.service!;
      _date = s.date;
      _clientController.text = s.clientName;
      _deviceController.text = s.deviceName;
      _serialController.text = s.serialNumber;
      _reasonController.text = s.reason;
      _serviceController.text = s.servicePerformed;
      _valueController.text = s.value.toStringAsFixed(2);
      _status = s.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Serviço', style: TextStyle(fontSize: 16))),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: _pickDate,
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: const InputDecoration(labelText: 'Data'),
                    initialValue: _date,
                    validator: (v) => (v == null || v.isEmpty) ? 'Informe a data' : null,
                  ),
                ),
              ),
              TextFormField(
                controller: _clientController,
                decoration: const InputDecoration(labelText: 'Nome do Cliente'),
                validator: (v) => (v == null || v.isEmpty) ? 'Informe o nome do cliente' : null,
                style: const TextStyle(fontSize: 14),
              ),
              TextFormField(
                controller: _deviceController,
                decoration: const InputDecoration(labelText: 'Nome do Aparelho'),
                validator: (v) => (v == null || v.isEmpty) ? 'Informe o aparelho' : null,
              ),
              TextFormField(
                controller: _serialController,
                decoration: const InputDecoration(labelText: 'Número de Série'),
                validator: (v) {
                  if (v == null || v.isEmpty) return null; // opcional
                  if (v.trim().length < 3) return 'Número de série muito curto';
                  return null;
                },
              ),
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(labelText: 'Motivo do Reparo'),
              ),
              TextFormField(
                controller: _serviceController,
                decoration: const InputDecoration(labelText: 'Serviço Realizado'),
              ),
              TextFormField(
                controller: _valueController,
                decoration: const InputDecoration(labelText: 'Valor do Serviço (ex: 300.00)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Informe o valor do serviço';
                  final parsed = double.tryParse(v.replaceAll(',', '.'));
                  if (parsed == null) return 'Valor inválido';
                  if (parsed <= 0) return 'Informe valor maior que zero';
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Status'),
                value: _status,
                items: const [
                  DropdownMenuItem(value: 'pending', child: Text('Pendente')),
                  DropdownMenuItem(value: 'finalized', child: Text('Finalizado')),
                  DropdownMenuItem(value: 'cancelled', child: Text('Cancelado')),
                ],
                onChanged: (v) => setState(() => _status = v ?? 'pending'),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: _save,
                  child: const Text('Salvar', style: TextStyle(fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
