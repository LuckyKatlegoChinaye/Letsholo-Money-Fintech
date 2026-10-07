import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  late TextEditingController _groupNameController;
  late TextEditingController _descriptionController;
  String _selectedTier = 'tier1';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _groupNameController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleCreateGroup() {
    if (_groupNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter group name')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // TODO: Implement create group logic
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Group created successfully')),
        );
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Create Group'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Start Your Savings Group',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF121212),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create a group and invite members to save together',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            // Group Name
            Text(
              'Group Name',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF121212),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _groupNameController,
              decoration: const InputDecoration(
                hintText: 'e.g., Office Savings Circle',
                prefixIcon: Icon(Icons.group),
              ),
            ),
            const SizedBox(height: 24),
            // Description
            Text(
              'Description (Optional)',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF121212),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Describe your group\'s purpose and goals',
                prefixIcon: Icon(Icons.description),
              ),
            ),
            const SizedBox(height: 32),
            // Tier Selection
            Text(
              'Select Subscription Tier',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF121212),
              ),
            ),
            const SizedBox(height: 16),
            _buildTierCard(
              tier: 'tier1',
              title: 'Basic',
              price: 'P50',
              members: '50 members',
              description: 'Perfect for small groups',
            ),
            const SizedBox(height: 12),
            _buildTierCard(
              tier: 'tier2',
              title: 'Standard',
              price: 'P150',
              members: '200 members',
              description: 'For growing communities',
            ),
            const SizedBox(height: 12),
            _buildTierCard(
              tier: 'tier3',
              title: 'Premium',
              price: 'P500',
              members: '1000 members',
              description: 'For large organizations',
            ),
            const SizedBox(height: 32),
            // Create Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleCreateGroup,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        'Create Group',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );

  Widget _buildTierCard({
    required String tier,
    required String title,
    required String price,
    required String members,
    required String description,
  }) {
    final isSelected = _selectedTier == tier;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTier = tier;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? const Color(0xFF6200EA) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? const Color(0xFF6200EA).withValues(alpha: 0.1) : Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF121212),
                  ),
                ),
                Radio<String>(
                  value: tier,
                  groupValue: _selectedTier,
                  onChanged: (value) => setState(() => _selectedTier = value ?? ''),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  price,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF6200EA),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  members,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
