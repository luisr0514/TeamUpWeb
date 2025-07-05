import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart'; // Import fl_chart
import 'reports.dart'; // Asegúrate de importar tu página de reportes

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int activeUsersCount = 0;
  int newUsersTodayCount = 0;
  int totalReportsCount = 0;
  int pendingReportsCount = 0; // New: To store pending reports
  int resolvedReportsCount = 0; // New: To store resolved reports
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _getDashboardData();
  }

  Future<void> _getDashboardData() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final usersFuture = FirebaseFirestore.instance.collection('users').get();
      final reportsFuture = FirebaseFirestore.instance.collection('reports').get();
      final newUsersFuture = FirebaseFirestore.instance
          .collection('users')
          .where('registrationDate', isGreaterThanOrEqualTo: today)
          .where('registrationDate', isLessThan: today.add(const Duration(days: 1)))
          .get();

      // Wait for all queries to complete
      final results = await Future.wait([usersFuture, reportsFuture, newUsersFuture]);

      final usersSnapshot = results[0] as QuerySnapshot;
      final reportsSnapshot = results[1] as QuerySnapshot;
      final newUsersSnapshot = results[2] as QuerySnapshot;

      // Process reports for pending and resolved counts
      int pending = 0;
      int resolved = 0;
      for (var doc in reportsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['status'] == 'pending') { // Assuming a 'status' field in your reports
          pending++;
        } else if (data['status'] == 'resolved') {
          resolved++;
        }
      }

      setState(() {
        activeUsersCount = usersSnapshot.docs.length;
        totalReportsCount = reportsSnapshot.docs.length;
        newUsersTodayCount = newUsersSnapshot.docs.length;
        pendingReportsCount = pending; // Set new counts
        resolvedReportsCount = resolved; // Set new counts
        isLoading = false;
        errorMessage = '';
      });

    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error loading dashboard data: ${e.toString()}';
      });
      debugPrint("Dashboard error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Dashboard',
            textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 46, 69, 23),
            ),
          ),
          const SizedBox(height: 20),

          if (errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                errorMessage,
                style: TextStyle(
                  color: Colors.red[700],
                  fontSize: 16,
                ),
              ),
            ),

          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildMetricCard(
                title: 'Usuarios',
                value: isLoading ? 'Loading...' : activeUsersCount.toString(),
                icon: Icons.people,
                color: Colors.blue[600]!,
              ),
              _buildMetricCard(
                title: 'Usuarios nuevos',
                value: isLoading ? 'Loading...' : newUsersTodayCount.toString(),
                icon: Icons.person_add,
                color: Colors.green[600]!,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Reports()), // Navega a la página de reportes
                  );
                },
                child: _buildMetricCard(
                  title: 'Reportes',
                  value: isLoading ? 'Loading...' : totalReportsCount.toString(),
                  icon: Icons.report,
                  color: Colors.orange[600]!,
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                /*_buildDashboardCard(
                  title: 'User Growth Chart', // Added title for clarity
                  child: const Center(child: Text('Placeholder for User Growth Chart')),
                  color: Colors.grey[200]!,
                ),*/
                _buildDashboardCard(
                  title: 'Reportes del sistema', // Added title for clarity
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildReportStatusChart(), // This is where the chart will go
                  color: Colors.grey[200]!,
                ),/*
                _buildDashboardCard(
                  title: 'Recent Activity', // Added title for clarity
                  child: const Center(child: Text('Placeholder for Recent Activity')),
                  color: Colors.grey[200]!,
                  fullWidth: true,
                ),*/
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

Widget _buildDashboardCard({
    required Widget child,
    required Color color,
    String title = 'Placeholder', // Added title parameter
    bool fullWidth = false,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: const EdgeInsets.all(16), // Padding for the entire card content
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.bold, 
              ),
            ),
            const SizedBox(height: 20), 
            Expanded(
              child: Padding( 
                padding: const EdgeInsets.only(top: 12.0, bottom: 12.0), 
                child: Center( 
                  child: child,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para crear los charts
  Widget _buildReportStatusChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                String text;
                switch (value.toInt()) {
                  case 0:
                    text = 'Pendientes';
                    break;
                  case 1:
                    text = 'Resueltos';
                    break;
                  default:
                    text = '';
                    break;
                }
                return SideTitleWidget(
                  meta : meta,
                  space: 4,
                  child: Text(text, style: const TextStyle(fontSize: 10)),
                );
              },
              reservedSize: 20,
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: pendingReportsCount.toDouble(),
                color: Colors.orange,
                width: 20,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
            showingTooltipIndicators: [0],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: resolvedReportsCount.toDouble(),
                color: Colors.green,
                width: 20,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
            showingTooltipIndicators: [0],
          ),
        ],
      ),
    );
  }
}