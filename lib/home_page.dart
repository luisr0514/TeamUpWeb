import 'package:flutter/material.dart';
import 'aut/auth_service.dart';

class VistaAdmi extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: 1081,
            height: 724,
            color: const Color(0xFFF9FAFB),
            child: Stack(
              children: [
                // Sidebar
                Positioned(
                  left: 0,
                  top: 0,
                  child: Container(
                    width: 240,
                    height: 724,
                    color: const Color(0xFFDFFF4F),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 101,
                          alignment: Alignment.bottomLeft,
                          padding: const EdgeInsets.only(left: 24, bottom: 16),
                          child: const Text(
                            'Admin Dashboard',
                            style: TextStyle(
                              color: Color(0xFF10B981),
                              fontSize: 14,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        _buildMenuItem('Dashboard', false),
                        _buildMenuItem('Manage Games', true),
                        _buildMenuItem('Manage Fields', false),
                        _buildMenuItem('Users', false),
                        _buildMenuItem('Settings', false),
                      ],
                    ),
                  ),
                ),

                // Main content area
                Positioned(
                  left: 240,
                  top: 0,
                  child: Container(
                    width: 841,
                    height: 724,
                    color: Colors.white,
                    child: Column(
                      children: [
                        // Header with "Salir" button added
                        _buildHeader(),

                        // Sub-header
                        _buildSubHeader(),

                        // Content
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              children: [
                                _buildFilters(),
                                const SizedBox(height: 24),
                                _buildTable(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Logo at bottom
                Positioned(
                  left: 21,
                  top: 625,
                  child: Row(
                    children: [
                      Container(
                        width: 74,
                        height: 74,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage("https://placehold.co/74x74"),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'TeamUp',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 28,
                          fontFamily: 'Sansation',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 74,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 0.67, color: Color(0xFFE5E7EB)),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: [
          const Text(
            'Manage Games',
            style: TextStyle(
              color: Color(0xFF111827),
              fontSize: 24,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Container(
            width: 268,
            height: 41,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Padding(
              padding: EdgeInsets.only(left: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Search...',
                  style: TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 32),
          const CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage("https://placehold.co/40x40"),
          ),
          const SizedBox(width: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Admin User',
                style: TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Text(
                'admin@plei.com',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),

          const SizedBox(width: 24),

          // --- Botón Salir: Ubicación para agregar lógica de salida ---
          TextButton(
            onPressed: () async {
              await AuthService().singOut();
            },

            // Aquí puedes agregar la lógica pertinente para salir/cerrar sesión
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Salir',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubHeader() {
    return Container(
      height: 59,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 0.67, color: Color(0xFFE5E7EB)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 53,
            height: 58,
            margin: const EdgeInsets.only(left: 32),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(width: 2, color: Color(0xFF10B981)),
              ),
            ),
            child: const Center(
              child: Text(
                'Games',
                style: TextStyle(
                  color: Color(0xFF10B981),
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 32),
          const Text(
            'Fields',
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 16,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Container(
          width: 133,
          height: 41,
          decoration: BoxDecoration(
            color: const Color(0xFFD9D9D9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Text(
              'All Status',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          width: 174,
          height: 41,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const Spacer(),
        Container(
          width: 120,
          height: 41,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Text(
              'Export CSV',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          width: 151,
          height: 41,
          decoration: BoxDecoration(
            color: const Color(0xFF10B981),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: Colors.white, size: 16),
              SizedBox(width: 8),
              Text(
                'Add Game',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTable() {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x19000000),
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          children: [
            // Table header
            Container(
              height: 64,
              color: const Color(0xFFF9FAFB),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: const Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(
                      'GAME NAME',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  SizedBox(width: 50),
                  SizedBox(
                    width: 120,
                    child: Text(
                      'LOCATION',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  SizedBox(width: 50),
                  SizedBox(
                    width: 100,
                    child: Text(
                      'DATE/TIME',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  SizedBox(width: 50),
                  SizedBox(
                    width: 50,
                    child: Text(
                      'FIELD',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  SizedBox(width: 50),
                  SizedBox(
                    width: 50,
                    child: Text(
                      'PLAYERS',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  SizedBox(width: 50),
                  SizedBox(
                    width: 70,
                    child: Text(
                      'STATUS',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  Spacer(),
                  SizedBox(
                    width: 70,
                    child: Text(
                      'ACTIONS',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Empty table rows
            Expanded(
              child: ListView.builder(
                itemCount: 4, // Número de filas vacías
                itemBuilder: (context, index) {
                  return Container(
                    height: 93,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          width: 0.67,
                          color: Color(0xFFE5E7EB),
                        ),
                      ),
                    ),
                    child: const Row(
                      children: [
                        // Celdas vacías
                        SizedBox(width: 100),
                        SizedBox(width: 50),
                        SizedBox(width: 120),
                        SizedBox(width: 50),
                        SizedBox(width: 100),
                        SizedBox(width: 50),
                        SizedBox(width: 50),
                        SizedBox(width: 50),
                        SizedBox(width: 70),
                        Spacer(),
                        Row(
                          children: [
                            Icon(Icons.edit, size: 16),
                            SizedBox(width: 16),
                            Icon(Icons.delete, size: 16),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Table footer
            Container(
              height: 62,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(width: 0.67, color: Color(0xFFE5E7EB)),
                ),
              ),
              child: Row(
                children: [
                  const Text(
                    'Showing 0 to 0 of 0 results',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 83,
                    height: 29,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Center(
                      child: Text(
                        'Previous',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 30,
                    height: 29,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Center(
                      child: Text(
                        '1',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 56,
                    height: 29,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Center(
                      child: Text(
                        'Next',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(String title, bool isActive) {
    return Container(
      width: 208,
      height: 48,
      margin: const EdgeInsets.only(left: 16, top: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF10B981) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Container(width: 20, height: 20, color: Colors.transparent),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              color: isActive ? Colors.white : const Color(0xFF9CA3AF),
              fontSize: 16,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
