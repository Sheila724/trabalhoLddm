import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../models/service.dart';
import 'add_service_page.dart';
import '../utils/csv_exporter.dart';
import 'package:flutter/foundation.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class ServiceSearchDelegate extends SearchDelegate<void> {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(icon: const Icon(Icons.clear), onPressed: () { if (query.isEmpty) close(context, null); else query = ''; }),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, null));
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<Service>>(
      future: DatabaseHelper.instance.getAllServices(),
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final q = query.toLowerCase();
        final results = snap.data!.where((s) {
          return s.clientName.toLowerCase().contains(q)
              || s.deviceName.toLowerCase().contains(q)
              || s.serialNumber.toLowerCase().contains(q)
              || s.servicePerformed.toLowerCase().contains(q)
              || (s.id != null && s.id.toString() == q);
        }).toList();
        if (results.isEmpty) return const Center(child: Text('Nenhum resultado')); 
        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (_, i) {
            final s = results[i];
            return ListTile(
              title: Text('${s.clientName} — ${s.deviceName}'),
              subtitle: Text('OS: ${s.id ?? "_"} • ${s.date}'),
              onTap: () async {
                // abrir edição
                await Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddServicePage(service: s)));
                close(context, null);
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) return const Center(child: Text('Digite para buscar por cliente, aparelho ou OS'));
    return buildResults(context);
  }
}

class _HomePageState extends State<HomePage> {
  List<Service> services = [];
  bool loading = true;
  String _filter = 'all'; // all | finalized | pending
  String _sortOrder = 'desc'; // desc (mais recentes) | asc (mais antigas)

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  void _openAddPage() async {
    final result = await Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddServicePage()));
    if (result == true) _loadServices();
  }

  void _deleteService(int id) async {
    await DatabaseHelper.instance.deleteService(id);
    _loadServices();
  }

  void _toggleFinalized(Service s) async {
    s.finalized = !s.finalized;
    await DatabaseHelper.instance.updateService(s);
    _loadServices();
  }

  Widget _buildItem(Service s) {
    return Dismissible(
      key: ValueKey(s.id ?? DateTime.now().millisecondsSinceEpoch),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.redAccent,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        final res = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            content: const Text('Excluir este registro?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
            ],
          ),
        );
        return res == true;
      },
      onDismissed: (_) {
        if (s.id != null) _deleteService(s.id!);
      },
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        title: Text('${s.clientName} — ${s.deviceName}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        subtitle: Text('OS: ${s.id ?? "_"} • ${s.date} • R\$ ${s.value.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
        trailing: Builder(builder: (_) {
          // determina o texto e a cor do status com base em s.status (preferível)
          String statusText;
          Color statusColor;
          final lowerReason = s.reason.toLowerCase();
          final lowerPerformed = s.servicePerformed.toLowerCase();
          final st = s.status.toLowerCase();
          if (st == 'finalized' || st == 'finalizado') {
            statusText = 'Finalizado';
            statusColor = Colors.green;
          } else if (st == 'cancelled' || st == 'cancelado') {
            statusText = 'Cancelado';
            statusColor = Colors.red;
          } else if (lowerReason.contains('cancel') || lowerPerformed.contains('cancel') || lowerReason.contains('cancelado') || lowerPerformed.contains('cancelado')) {
            // fallback heurística
            statusText = 'Cancelado';
            statusColor = Colors.red;
          } else {
            statusText = 'Pendente';
            statusColor = Colors.amber[800]!;
          }

          // se for cancelado, não mostrar checkbox — apenas o texto de status
          if (st == 'cancelled' || st == 'cancelado' || statusText == 'Cancelado') {
            return Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.w600));
          }

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: s.finalized,
                onChanged: (_) => _toggleFinalized(s),
              ),
              const SizedBox(width: 8),
              Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.w600)),
            ],
          );
        }),
        onTap: () async {
          final result = await Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddServicePage(service: s)));
          if (result == true) _loadServices();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Serviços'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Buscar',
            onPressed: () async {
              await showSearch(context: context, delegate: ServiceSearchDelegate());
              _loadServices();
            },
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            tooltip: 'Exportar CSV',
            onPressed: _exportCsv,
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v.startsWith('filter:')) {
                setState(() => _filter = v.split(':')[1]);
                _loadServices();
              } else if (v.startsWith('sort:')) {
                setState(() => _sortOrder = v.split(':')[1]);
                _loadServices();
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'filter:all', child: Text('Todos')),
              const PopupMenuItem(value: 'filter:finalized', child: Text('Finalizados')),
              const PopupMenuItem(value: 'filter:pending', child: Text('Pendentes')),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'sort:desc', child: Text('Ordenar: Mais recentes')),
              const PopupMenuItem(value: 'sort:asc', child: Text('Ordenar: Mais antigas')),
            ],
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : services.isEmpty
              ? const Center(child: Text('Nenhum serviço cadastrado.'))
              : RefreshIndicator(
                  onRefresh: () async => _loadServices(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: services.length,
                    itemBuilder: (_, i) => _buildItem(services[i]),
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddPage,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future _exportCsv() async {
    try {
      final all = await DatabaseHelper.instance.getAllServices();
      final path = await CsvExporter.exportServices(all);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('CSV salvo em: $path')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro exportando CSV: $e')));
    }
  }

  Future _loadServices() async {
    setState(() => loading = true);
    final all = await DatabaseHelper.instance.getAllServices();
    Iterable<Service> filtered;
    if (_filter == 'finalized') {
      filtered = all.where((s) => s.finalized);
    } else if (_filter == 'pending') {
      filtered = all.where((s) => !s.finalized);
    } else {
      filtered = all;
    }

    final list = filtered.toList();
    list.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    if (_sortOrder == 'desc') list.reversed.toList().asMap().forEach((_, __) {}); // keep reversed order below
    services = (_sortOrder == 'desc') ? list.reversed.toList() : list;

    setState(() => loading = false);
  }
}
