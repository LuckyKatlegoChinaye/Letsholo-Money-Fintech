import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminControlsScreen extends StatefulWidget {

  const AdminControlsScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });
  final String groupId;
  final String groupName;

  @override
  State<AdminControlsScreen> createState() => _AdminControlsScreenState();
}

class _AdminControlsScreenState extends State<AdminControlsScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text('${widget.groupName} - Admin'),
      ),
      body: IndexedStack(
        index: _selectedTabIndex,
        children: [
          _buildMembersTab(),
          _buildContributionsTab(),
          _buildPayoutsTab(),
          _buildReportsTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTabIndex,
        onTap: (index) {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Members',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment),
            label: 'Contributions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance),
            label: 'Payouts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
        ],
      ),
    );

  Widget _buildMembersTab() {
    final members = [
      {'name': 'John Doe', 'phone': '+267 71 234 567', 'joinedDate': 'Jan 15', 'status': 'active'},
      {'name': 'Jane Smith', 'phone': '+267 72 345 678', 'joinedDate': 'Jan 20', 'status': 'active'},
      {'name': 'Mike Johnson', 'phone': '+267 73 456 789', 'joinedDate': 'Feb 1', 'status': 'pending'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add Member Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showAddMemberDialog,
              icon: const Icon(Icons.person_add),
              label: const Text('Add Member'),
            ),
          ),

          const SizedBox(height: 24),

          // Members List
          Text(
            'Members (${members.length})',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          ...members.map((member) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member['name']!,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          member['phone']!,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        child: Text('Edit'),
                      ),
                      const PopupMenuItem(
                        child: Text('Remove'),
                      ),
                    ],
                  ),
                ],
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildContributionsTab() => SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Paid',
                  value: '12/15',
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Overdue',
                  value: '2',
                  color: Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Total',
                  value: 'P6,000',
                  color: Colors.blue,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Contribution List
          Text(
            'Current Cycle',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          ...[
            {'name': 'John Doe', 'amount': 'P500', 'status': 'Paid'},
            {'name': 'Jane Smith', 'amount': 'P500', 'status': 'Paid'},
            {'name': 'Mike Johnson', 'amount': 'P500', 'status': 'Overdue'},
          ].map((contribution) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contribution['name']!,
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        contribution['amount']!,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: contribution['status'] == 'Paid'
                          ? Colors.green[50]
                          : Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: contribution['status'] == 'Paid'
                            ? Colors.green[300]!
                            : Colors.red[300]!,
                      ),
                    ),
                    child: Text(
                      contribution['status']!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: contribution['status'] == 'Paid'
                            ? Colors.green[700]
                            : Colors.red[700],
                      ),
                    ),
                  ),
                ],
              ),
            )),
        ],
      ),
    );

  Widget _buildPayoutsTab() => SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trigger Payout Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showTriggerPayoutDialog,
              icon: const Icon(Icons.send),
              label: const Text('Trigger Payout'),
            ),
          ),

          const SizedBox(height: 24),

          // Payout Schedule
          Text(
            'Payout Schedule',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          ...[
            {'order': '1st', 'member': 'Jane Smith', 'amount': 'P2,000', 'date': 'Mar 10', 'status': 'Completed'},
            {'order': '2nd', 'member': 'John Doe', 'amount': 'P2,000', 'date': 'Apr 10', 'status': 'Scheduled'},
            {'order': '3rd', 'member': 'Mike Johnson', 'amount': 'P2,000', 'date': 'May 10', 'status': 'Pending'},
          ].map((payout) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${payout['order']!} Payout - ${payout['member']!}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${payout['amount']!} on ${payout['date']!}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: payout['status'] == 'Completed'
                          ? Colors.green[50]
                          : payout['status'] == 'Scheduled'
                              ? Colors.blue[50]
                              : Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: payout['status'] == 'Completed'
                            ? Colors.green[300]!
                            : payout['status'] == 'Scheduled'
                                ? Colors.blue[300]!
                                : Colors.orange[300]!,
                      ),
                    ),
                    child: Text(
                      payout['status']!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            )),
        ],
      ),
    );

  Widget _buildReportsTab() => SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          _buildStatCard(
            title: 'Total Members',
            value: '15',
            color: Colors.blue,
          ),

          const SizedBox(height: 12),

          _buildStatCard(
            title: 'Total Collected',
            value: 'P7,500',
            color: Colors.green,
          ),

          const SizedBox(height: 12),

          _buildStatCard(
            title: 'Payouts Completed',
            value: '1/15',
            color: Colors.purple,
          ),

          const SizedBox(height: 24),

          // Export Options
          Text(
            'Export Report',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.download),
            label: const Text('Download CSV'),
          ),

          const SizedBox(height: 12),

          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.print),
            label: const Text('Print Report'),
          ),
        ],
      ),
    );

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
  }) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );

  void _showAddMemberDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Member'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Phone Number',
                hintText: '+267 71 234 567',
              ),
            ),
            SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'Member Name',
                hintText: 'Enter member name',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Member added successfully')),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showTriggerPayoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Trigger Payout'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select member to receive payout:'),
            const SizedBox(height: 16),
            DropdownButtonFormField(
              decoration: const InputDecoration(
                labelText: 'Member',
              ),
              items: const [
                DropdownMenuItem(value: '1', child: Text('Jane Smith')),
                DropdownMenuItem(value: '2', child: Text('John Doe')),
                DropdownMenuItem(value: '3', child: Text('Mike Johnson')),
              ],
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Payout triggered successfully')),
              );
            },
            child: const Text('Trigger'),
          ),
        ],
      ),
    );
  }
}
