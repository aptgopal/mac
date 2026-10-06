import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/booking.dart';
import '../../services/firestore_service.dart';
import '../../providers/notification_provider.dart';

class ManageBookingsScreen extends StatelessWidget {
  const ManageBookingsScreen({super.key});

  FirestoreService get _firestore => FirestoreService();

  Future<void> _handleAction(BuildContext context, Booking b, String value) async {
    switch (value) {
      case 'PAY_CASH':
        await _firestore.markBookingPaid(b.id, 'CASH');
        break;
      case 'PAY_UPI':
        await _firestore.markBookingPaid(b.id, 'UPI');
        break;
      case 'PAY_PENDING':
        await _firestore.markBookingUnpaid(b.id);
        break;
      default:
        await _firestore.updateBookingStatus(b.id, value);
    }
  }

  Widget _paymentChip(Booking b) {
    final paid = b.paymentStatus == 'PAID';
    final method = b.paymentMethod != null ? ' (${b.paymentMethod})' : '';
    final label = paid ? 'PAID$method' : b.paymentStatus;
    final color = paid ? const Color(0xFF00C853) : Colors.orange.shade800;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  Color _statusColor(String status, ThemeData theme) {
    switch (status.toUpperCase()) {
      case 'CONFIRMED':
        return const Color(0xFF00C853);
      case 'PENDING':
        return const Color(0xFFFFC107);
      case 'CANCELLED':
        return const Color(0xFFD32F2F);
      case 'CHECKED_IN':
        return const Color(0xFF0099FF);
      default:
        return Colors.grey;
    }
  }

  Color _statusBgColor(String status, ThemeData theme) {
    switch (status.toUpperCase()) {
      case 'CONFIRMED':
        return const Color(0xFF00C853).withOpacity(0.1);
      case 'PENDING':
        return const Color(0xFFFFC107).withOpacity(0.1);
      case 'CANCELLED':
        return const Color(0xFFD32F2F).withOpacity(0.1);
      case 'CHECKED_IN':
        return const Color(0xFF0099FF).withOpacity(0.1);
      default:
        return Colors.grey.withOpacity(0.1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat.yMMMd();
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookings'),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, child) {
              return Container(
                margin: const EdgeInsets.only(right: 12),
                child: ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: const Text('Filter Bookings'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              title: const Text('All'),
                              onTap: () => Navigator.pop(ctx),
                            ),
                            ListTile(
                              title: const Text('Pending'),
                              onTap: () => Navigator.pop(ctx),
                            ),
                            ListTile(
                              title: const Text('Confirmed'),
                              onTap: () => Navigator.pop(ctx),
                            ),
                            ListTile(
                              title: const Text('Checked In'),
                              onTap: () => Navigator.pop(ctx),
                            ),
                            ListTile(
                              title: const Text('Cancelled'),
                              onTap: () => Navigator.pop(ctx),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.filter_list_rounded, size: 20),
                  label: const Text('Filter'),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, child) {
              final newBookings = notificationProvider.newBookings;
              if (newBookings.isEmpty) {
                return const SizedBox.shrink();
              }
              
              return Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF003580).withOpacity(0.1),
                      const Color(0xFF0099FF).withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF003580).withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFF003580).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.notifications_active_rounded,
                            color: Color(0xFF003580),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'New Bookings',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF003580),
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            notificationProvider.markAsRead();
                          },
                          icon: const Icon(Icons.done_all_rounded, size: 18),
                          label: const Text('Mark all read'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...newBookings.map((b) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00C853).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.book_online_rounded,
                                  color: Color(0xFF00C853),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      b.guestName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      'Room ${b.roomNumber} • ${fmt.format(b.checkIn)}',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _statusBgColor(b.status, theme),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  b.status.toUpperCase(),
                                  style: TextStyle(
                                    color: _statusColor(b.status, theme),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: StreamBuilder<List<Booking>>(
              stream: _firestore.streamBookings(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF003580)));
                }
                final bookings = snapshot.data!;
                if (bookings.isEmpty) {
                  return Center(
                    child: Column(
                      children: [
                        Icon(Icons.book_online_rounded, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          'No bookings yet.',
                          style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  );
                }
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 900;
                    if (isWide) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(const Color(0xFFF8F9FA)),
                          dataRowMinHeight: 72,
                          dataRowMaxHeight: 72,
                          columns: const [
                            DataColumn(label: Text('Booking')),
                            DataColumn(label: Text('Guest')),
                            DataColumn(label: Text('Dates')),
                            DataColumn(label: Text('Room')),
                            DataColumn(label: Text('Payment')),
                            DataColumn(label: Text('Status')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: bookings.map((b) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    b.id,
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                DataCell(
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(b.guestName, style: const TextStyle(fontWeight: FontWeight.w500)),
                                      Text(b.guestEmail, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                    ],
                                  ),
                                ),
                                DataCell(
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('${fmt.format(b.checkIn)} - ${fmt.format(b.checkOut)}'),
                                      Text('${b.guests} guests', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                    ],
                                  ),
                                ),
                                DataCell(Text('Room ${b.roomNumber}')),
                                DataCell(_paymentChip(b)),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _statusBgColor(b.status, theme),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      b.status.toUpperCase(),
                                      style: TextStyle(
                                        color: _statusColor(b.status, theme),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert_rounded, size: 20),
                                    onSelected: (value) => _handleAction(context, b, value),
                                    itemBuilder: (ctx) => const [
                                      PopupMenuItem(value: 'PENDING', child: Text('Pending')),
                                      PopupMenuItem(value: 'CONFIRMED', child: Text('Confirmed')),
                                      PopupMenuItem(value: 'CHECKED_IN', child: Text('Checked In')),
                                      PopupMenuItem(value: 'CANCELLED', child: Text('Cancelled')),
                                      PopupMenuItem(value: 'PAY_CASH', child: Text('Paid - Cash')),
                                      PopupMenuItem(value: 'PAY_UPI', child: Text('Paid - UPI')),
                                      PopupMenuItem(value: 'PAY_PENDING', child: Text('Payment pending')),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: bookings.length,
                      itemBuilder: (context, index) {
                        final b = bookings[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              b.hotelName,
                                              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Room ${b.roomNumber}',
                                              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _statusBgColor(b.status, theme),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          b.status.toUpperCase(),
                                          style: TextStyle(
                                            color: _statusColor(b.status, theme),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Icon(Icons.person_outline_rounded, size: 16, color: Colors.grey.shade500),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          b.guestName,
                                          style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today_rounded, size: 16, color: Colors.grey.shade500),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${fmt.format(b.checkIn)} - ${fmt.format(b.checkOut)}',
                                        style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                                      ),
                                      const Spacer(),
                                      Text(
                                        '${b.guests} guest${b.guests > 1 ? "s" : ""}',
                                        style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Align(alignment: Alignment.centerLeft, child: _paymentChip(b)),
                                  if (b.razorpayPaymentId != null) ...[
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(Icons.payments_rounded, size: 16, color: Colors.grey.shade500),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            b.razorpayPaymentId!,
                                            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  if (b.paymentStatus == 'REFUNDED') ...[
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(Icons.undo_rounded, size: 16, color: theme.colorScheme.error),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Refunded',
                                          style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.w500, fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ],
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      PopupMenuButton<String>(
                                        icon: const Icon(Icons.more_vert_rounded, size: 20),
                                        onSelected: (value) => _handleAction(context, b, value),
                                        itemBuilder: (ctx) => const [
                                          PopupMenuItem(value: 'PENDING', child: Text('Pending')),
                                          PopupMenuItem(value: 'CONFIRMED', child: Text('Confirmed')),
                                          PopupMenuItem(value: 'CHECKED_IN', child: Text('Checked In')),
                                          PopupMenuItem(value: 'CANCELLED', child: Text('Cancelled')),
                                          PopupMenuItem(value: 'PAY_CASH', child: Text('Paid - Cash')),
                                          PopupMenuItem(value: 'PAY_UPI', child: Text('Paid - UPI')),
                                          PopupMenuItem(value: 'PAY_PENDING', child: Text('Payment pending')),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
