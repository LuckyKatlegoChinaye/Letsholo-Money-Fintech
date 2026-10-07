import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    // Sample notifications
    final notifications = [
      {
        'id': '1',
        'title': 'Contribution Due',
        'message': 'Your March contribution of P500 is due today',
        'timestamp': 'Today 9:30 AM',
        'icon': Icons.payment,
        'read': false,
        'color': Colors.orange,
      },
      {
        'id': '2',
        'title': 'Payout Scheduled',
        'message': 'You will receive P2,000 on March 10, 2026',
        'timestamp': 'Yesterday 2:15 PM',
        'icon': Icons.account_balance_wallet,
        'read': false,
        'color': Colors.green,
      },
      {
        'id': '3',
        'title': 'Member Joined',
        'message': 'Peter Mkailu has joined the Finance Savers group',
        'timestamp': '2 days ago',
        'icon': Icons.person_add,
        'read': true,
        'color': Colors.blue,
      },
      {
        'id': '4',
        'title': 'Payment Received',
        'message': 'John Doe paid P500 to the Finance Savers group',
        'timestamp': '3 days ago',
        'icon': Icons.check_circle,
        'read': true,
        'color': Colors.green,
      },
      {
        'id': '5',
        'title': 'Late Payment Penalty',
        'message': 'Penalty of P50 applied for late contribution',
        'timestamp': '5 days ago',
        'icon': Icons.warning,
        'read': true,
        'color': Colors.red,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              showMenu(
                context: context,
                position: const RelativeRect.fromLTRB(100, 50, 0, 0),
                items: [
                  const PopupMenuItem(
                    child: Text('Mark all as read'),
                  ),
                  const PopupMenuItem(
                    child: Text('Clear all'),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return GestureDetector(
                  onTap: () {
                    // Handle notification tap
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          notification['message'] as String,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: (notification['read'] as bool)
                          ? Colors.transparent
                          : Colors.grey[50],
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey[200]!,
                        ),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                (notification['color'] as Color).withValues(alpha: 0.1),
                          ),
                          child: Icon(
                            notification['icon'] as IconData,
                            color: notification['color'] as Color,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    notification['title'] as String,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (!(notification['read'] as bool))
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFF27a745),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                notification['message'] as String,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                notification['timestamp'] as String,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
