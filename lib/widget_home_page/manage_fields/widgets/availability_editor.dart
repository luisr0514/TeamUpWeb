import 'package:flutter/material.dart';

class AvailabilityEditor extends StatefulWidget {
  final Map<String, List<String>> initialAvailability;
  final Function(Map<String, List<String>>) onAvailabilityChanged;

  const AvailabilityEditor({
    Key? key,
    required this.initialAvailability,
    required this.onAvailabilityChanged,
  }) : super(key: key);

  @override
  _AvailabilityEditorState createState() => _AvailabilityEditorState();
}

class _AvailabilityEditorState extends State<AvailabilityEditor> {
  late Map<String, List<String>> _availability;
  final List<String> _daysOfWeek = [
    'Lun', 'Mar', 'Mier', 'Jue', 'Vier', 'Sab', 'Dom'
  ];

  @override
  void initState() {
    super.initState();
    _availability = Map<String, List<String>>.from(widget.initialAvailability);
  }

  void _notifyParent() {
    widget.onAvailabilityChanged(_availability);
  }

  Future<void> _addTimeToDay(String day) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formattedTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      setState(() {
        if (!_availability[day]!.contains(formattedTime)) {
          _availability[day]!.add(formattedTime);
          _availability[day]!.sort();
          _notifyParent();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Este horario ya fue agregado.'), backgroundColor: Colors.orange),
          );
        }
      });
    }
  }

  void _addDay() {
    final availableDays = _daysOfWeek.where((d) => !_availability.containsKey(d)).toList();
    if (availableDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todos los días han sido añadidos.'), backgroundColor: Colors.blue),
      );
      return;
    }

    String? dayToAdd;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar Día'),
        content: DropdownButton<String>(
          hint: const Text("Elige un día"),
          isExpanded: true,
          items: availableDays.map((day) => DropdownMenuItem(value: day, child: Text(day))).toList(),
          onChanged: (selectedDay) {
            dayToAdd = selectedDay;
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(onPressed: (){
            if (dayToAdd != null) {
              setState(() {
                _availability[dayToAdd!] = [];
                _notifyParent();
              });
            }
            Navigator.of(context).pop();
          }, child: const Text('Añadir'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Usamos las claves del mapa para el orden actual
    List<String> sortedDays = _availability.keys.toList();
    // Opcional: si quieres un orden fijo (Lun, Mar, etc)
    // sortedDays.sort((a, b) => _daysOfWeek.indexOf(a).compareTo(_daysOfWeek.indexOf(b)));

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        border: Border.all(color: Colors.grey.shade700),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (sortedDays.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: Text("No hay días de disponibilidad definidos.", style: TextStyle(color: Colors.white70))),
            ),
          ...sortedDays.map((day) {
            final times = _availability[day]!;
            return ExpansionTile(
              key: ValueKey(day),
              iconColor: Colors.white,
              collapsedIconColor: Colors.white70,
              title: Text(day, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0),
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: [
                      ...times.map((time) => Chip(
                        label: Text(time),
                        backgroundColor: Colors.teal,
                        labelStyle: const TextStyle(color: Colors.white),
                        deleteIconColor: Colors.white70,
                        onDeleted: () {
                          setState(() {
                            _availability[day]!.remove(time);
                            _notifyParent();
                          });
                        },
                      )),
                      ActionChip(
                        avatar: const Icon(Icons.add, size: 18),
                        label: const Text('Hora'),
                        onPressed: () => _addTimeToDay(day),
                      )
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
          const Divider(),
          Center(
            child: TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: Colors.tealAccent),
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Añadir Día de Disponibilidad'),
              onPressed: _addDay,
            ),
          ),
        ],
      ),
    );
  }
}