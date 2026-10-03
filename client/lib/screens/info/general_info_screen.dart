import 'package:flutter/material.dart';

class GeneralInfoScreen extends StatelessWidget {
  const GeneralInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: theme.colorScheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF003580), Color(0xFF0066CC)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        'General Info',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _InfoCard(
                  icon: Icons.description_rounded,
                  title: 'Terms & Conditions',
                  iconColor: const Color(0xFF003580),
                  onTap: () => _showPage(context, 'Terms & Conditions', _termsContent),
                ),
                const SizedBox(height: 12),
                _InfoCard(
                  icon: Icons.privacy_tip_rounded,
                  title: 'Privacy Policy',
                  iconColor: const Color(0xFF0099FF),
                  onTap: () => _showPage(context, 'Privacy Policy', _privacyContent),
                ),
                const SizedBox(height: 12),
                _InfoCard(
                  icon: Icons.policy_rounded,
                  title: 'Cancellation & Refund Rules',
                  iconColor: const Color(0xFFFFC107),
                  onTap: () => _showPage(context, 'Cancellation & Refund Rules', _cancellationContent),
                ),
                const SizedBox(height: 12),
                _InfoCard(
                  icon: Icons.help_outline_rounded,
                  title: 'FAQs',
                  iconColor: const Color(0xFF00C853),
                  onTap: () => _showPage(context, 'FAQs', _faqContent),
                ),
                const SizedBox(height: 12),
                _InfoCard(
                  icon: Icons.support_agent_rounded,
                  title: 'Help & Support',
                  iconColor: const Color(0xFFD32F2F),
                  onTap: () => _showPage(context, 'Help & Support', _supportContent),
                ),
              ]),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  void _showPage(BuildContext context, String title, String content) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: themeColor,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                backgroundColor: const Color(0xFF003580),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF003580), Color(0xFF0066CC)],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            title,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(content, style: const TextStyle(height: 1.7, fontSize: 15)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const themeColor = Color(0xFFF5F7FA);

  static const _termsContent = '''
Terms & Conditions

1. Booking is confirmed only after successful payment.
2. Check-in time is 2:00 PM and check-out time is 12:00 PM.
3. Cancellation made 24 hours before check-in is eligible for a full refund.
4. No-shows will be charged the full amount.
5. Government-issued ID is required at check-in.
6. Pets are not allowed unless specified by the property.
7. Smoking is prohibited inside all rooms.
8. The management reserves the right to deny admission or terminate a stay.
''';

  static const _privacyContent = '''
Privacy Policy

We value your privacy. This policy explains how we collect, use, and protect your personal information.

1. We collect your name, email, phone number, and payment details when you book.
2. Your data is used solely for booking management and customer support.
3. We do not sell or share your personal information with third parties except as required for payment processing.
4. Payment information is processed securely through Razorpay.
5. You may request data deletion by contacting support.
''';

  static const _cancellationContent = '''
Cancellation & Refund Rules

1. Free cancellation up to 24 hours before check-in.
2. Cancellations within 24 hours incur a 50% penalty.
3. No-shows are non-refundable.
4. Refunds are processed within 5-7 business days to the original payment method.
5. Partial refunds may apply for early check-outs.
6. Force majeure events are handled on a case-by-case basis.
''';

  static const _faqContent = '''
Frequently Asked Questions

Q: How do I cancel a booking?
A: Go to My Bookings and select the booking you wish to cancel.

Q: What payment methods are accepted?
A: We accept all major credit/debit cards, UPI, and net banking via Razorpay.

Q: Can I modify my booking dates?
A: Yes, contact support at least 48 hours before check-in.

Q: Is my payment secure?
A: Yes, all payments are processed through Razorpay's secure gateway.

Q: How do I get a refund?
A: Refunds are initiated by our support team and typically take 5-7 business days.
''';

  static const _supportContent = '''
Help & Support

For assistance, reach out to us:

Email: support@lodgebooking.example.com
Phone: +1-800-123-4567

Our support team is available Monday to Friday, 9 AM - 6 PM IST.
''';
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color iconColor;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.onTap,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
        onTap: onTap,
      ),
    );
  }
}
