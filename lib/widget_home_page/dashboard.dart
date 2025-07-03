import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

      setState(() {
        activeUsersCount = usersSnapshot.docs.length;
        totalReportsCount = reportsSnapshot.docs.length;
        newUsersTodayCount = newUsersSnapshot.docs.length;
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dashboard',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
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
                _buildDashboardCard(
                  child: const Center(child: Text('User  Growth Chart')),
                  color: Colors.grey[200]!,
                ),
                _buildDashboardCard(
                  child: const Center(child: Text('Report Trends')),
                  color: Colors.grey[200]!,
                ),
                _buildDashboardCard(
                  child: const Center(child: Text('Recent Activity')),
                  color: Colors.grey[200]!,
                  fullWidth: true,
                ),
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
    bool fullWidth = false,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Placeholder for chart/data',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Center(
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}