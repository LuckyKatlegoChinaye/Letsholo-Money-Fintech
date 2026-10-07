import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GroupDashboardScreen extends StatefulWidget {
  const GroupDashboardScreen({super.key});

  @override
  State<GroupDashboardScreen> createState() => _GroupDashboardScreenState();
}

class _GroupDashboardScreenState extends State<GroupDashboardScreen> {
  final int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Office Savings Circle'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Show menu
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Group Stats
          Container(
            color: const Color(0xFF6200EA),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Balance
                Text(
                  'Group Balance',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'P 5,500.00',
                  style: GoogleFonts.inter(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                // Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem('Members', '8', Colors.white),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white30,
                    ),
                    _buildStatItem('Contributions', '24', Colors.white),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white30,
                    ),
                    _buildStatItem('Rounds', '2', Colors.white),
                  ],
                ),
              ],
            ),
          ),
          // Tab Bar
          TabBar(
            labelColor: const Color(0xFF6200EA),
            unselectedLabelColor: Colors.grey,
            labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Transactions'),
              Tab(text: 'Members'),
            ],
          ),
          // Tab Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildTabContent(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to contribute screen
        },
        child: const Icon(Icons.add),
      ),
    );

  Widget _buildStatItem(String label, String value, Color color) => Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: color.withValues(alpha: 0.8),
          ),
        ),
      ],
    );

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildOverviewTab();
      case 1:
        return _buildTransactionsTab();
      case 2:
        return _buildMembersTab();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildOverviewTab() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Next Contribution Due',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF121212),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.orange[300]!),
            borderRadius: BorderRadius.circular(12),
            color: Colors.orange[50],
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.orange[700]),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'P100.00',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF121212),
                      ),
                    ),
                    Text(
                      'Due: March 15, 2026',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[700],
                ),
                child: Text(
                  'Pay',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Group Description',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF121212),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Monthly savings group for office staff members to collectively save money and support each other financially.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Group Information',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF121212),
          ),
        ),
        const SizedBox(height: 12),
        _buildInfoRow('Created', 'January 15, 2026'),
        _buildInfoRow('Tier', 'Basic (50 members)'),
        _buildInfoRow('Invite Code', 'ABCD1234'),
      ],
    );

  Widget _buildTransactionsTab() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Transactions',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF121212),
          ),
        ),
        const SizedBox(height: 12),
        _buildTransactionItem(
          'Katlego Chinaye',
          'Contribution',
          'P100.00',
          'March 8, 2026',
          Colors.green,
        ),
        _buildTransactionItem(
          'Neelo Pilane',
          'Contribution',
          'P100.00',
          'March 7, 2026',
          Colors.green,
        ),
        _buildTransactionItem(
          'Late Payment Fee',
          'Penalty',
          'P10.00',
          'March 6, 2026',
          Colors.red,
        ),
      ],
    );

  Widget _buildMembersTab() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Group Members',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF121212),
          ),
        ),
        const SizedBox(height: 12),
        _buildMemberItem('Katlego Chinaye', 'Admin', 'P500', '5 contributions'),
        _buildMemberItem('Neelo Pilane', 'Member', 'P400', '4 contributions'),
        _buildMemberItem('Tshiamo Frank', 'Member', 'P300', '3 contributions'),
        _buildMemberItem('Lucky Katleo', 'Treasurer', 'P500', '5 contributions'),
      ],
    );

  Widget _buildInfoRow(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF121212),
            ),
          ),
        ],
      ),
    );

  Widget _buildTransactionItem(
    String name,
    String type,
    String amount,
    String date,
    Color color,
  ) => Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.2),
            child: Icon(
              color == Colors.green ? Icons.arrow_downward : Icons.warning,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF121212),
                  ),
                ),
                Text(
                  date,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );

  Widget _buildMemberItem(
    String name,
    String role,
    String contributed,
    String details,
  ) => Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF6200EA).withValues(alpha: 0.2),
            child: Text(
              name[0],
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF6200EA),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF121212),
                  ),
                ),
                Text(
                  '$role • $details',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            contributed,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6200EA),
            ),
          ),
        ],
      ),
    );
}
