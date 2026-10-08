import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/notification_provider.dart';
import '../../services/currency_service.dart';
import '../../widgets/common.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Stream<_DashStats> _stats() {
    final db = FirebaseFirestore.instance;
    final controller = StreamController<_DashStats>();
    QuerySnapshot<Map<String, dynamic>>? hotels, rooms, bookings;
    void emit() {
      if (hotels == null || rooms == null || bookings == null) return;
      controller.add(_DashStats.compute(hotels!, rooms!, bookings!));
    }

    final subs = [
      db.collection('hotels').snapshots().listen((s) {
        hotels = s;
        emit();
      }),
      db.collectionGroup('rooms').snapshots().listen((s) {
        rooms = s;
        emit();
      }),
      db.collection('bookings').snapshots().listen((s) {
        bookings = s;
        emit();
      }),
    ];
    controller.onCancel = () {
      for (final s in subs) {
        s.cancel();
      }
    };
    return controller.stream;
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      route: '/dashboard',
      title: 'Dashboard',
      actions: [
        Consumer<NotificationProvider>(
          builder: (context, notificationProvider, child) {
            return Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_rounded),
                  tooltip: 'Notifications',
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (ctx) =>
                          _NotificationsSheet(provider: notificationProvider),
                    );
                  },
                ),
                if (notificationProvider.unreadCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD32F2F),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        '${notificationProvider.unreadCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.logout_rounded),
          tooltip: 'Sign out',
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                title: const Text('Sign Out'),
                content: const Text('Are you sure you want to sign out?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                    child: Text('Sign Out',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error)),
                  ),
                ],
              ),
            );
          },
        ),
      ],
      body: StreamBuilder<_DashStats>(
        stream: _stats(),
        builder: (context, snap) {
          final stats = snap.data ?? _DashStats.empty();
          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 1200;
              return SingleChildScrollView(
                padding: EdgeInsets.all(isWide ? 32 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final columns = constraints.maxWidth >= 1200
                            ? 4
                            : constraints.maxWidth >= 600
                                ? 2
                                : 1;
                        const gap = 16.0;
                        final width =
                            (constraints.maxWidth - gap * (columns - 1)) /
                                columns;
                        final cards = [
                          _StatCard(
                            icon: Icons.hotel_rounded,
                            label: 'Hotels',
                            count: '${stats.hotels}',
                            color: const Color(0xFF003580),
                            onTap: () => Navigator.of(context)
                                .pushReplacementNamed('/hotels'),
                          ),
                          _StatCard(
                            icon: Icons.meeting_room_rounded,
                            label: 'Rooms',
                            count: '${stats.total}',
                            color: const Color(0xFF0099FF),
                            onTap: () => Navigator.of(context)
                                .pushReplacementNamed('/rooms'),
                          ),
                          _StatCard(
                            icon: Icons.book_online_rounded,
                            label: 'Bookings',
                            count: '${stats.bookings}',
                            color: const Color(0xFF00C853),
                            onTap: () => Navigator.of(context)
                                .pushReplacementNamed('/bookings'),
                          ),
                          _StatCard(
                            icon: Icons.payments_rounded,
                            label: 'Revenue',
                            count: CurrencyService.formatInr(
                              stats.revenue,
                              decimals: 0,
                            ),
                            color: const Color(0xFFFFC107),
                            onTap: () {},
                          ),
                        ];
                        return Wrap(
                          spacing: gap,
                          runSpacing: gap,
                          children: [
                            for (final card in cards)
                              SizedBox(
                                width: width,
                                height: 180,
                                child: card,
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: _ChartCard(
                              title: 'Bookings Trend',
                              subtitle: 'Last 7 days',
                              child: SizedBox(
                                height: 260,
                                child: _BookingsBarChart(
                                    labels: stats.labels,
                                    values: stats.dailyBookings),
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Builder(
                              builder: (context) {
                                final data = {
                                  'available': stats.available,
                                  'booked': stats.booked,
                                  'blocked': stats.blocked,
                                  'maintenance': stats.maintenance
                                };
                                return _ChartCard(
                                  title: 'Room Status',
                                  subtitle: 'Current distribution',
                                  child: SizedBox(
                                    height: 260,
                                    child: _DynamicRoomStatusPieChart(
                                      available: data['available'] ?? 0,
                                      booked: data['booked'] ?? 0,
                                      blocked: data['blocked'] ?? 0,
                                      maintenance: data['maintenance'] ?? 0,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          _ChartCard(
                            title: 'Bookings Trend',
                            subtitle: 'Last 7 days',
                            child: SizedBox(
                              height: 260,
                              child: _BookingsBarChart(
                                  labels: stats.labels,
                                  values: stats.dailyBookings),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Builder(
                            builder: (context) {
                              final data = {
                                'available': stats.available,
                                'booked': stats.booked,
                                'blocked': stats.blocked,
                                'maintenance': stats.maintenance
                              };
                              return _ChartCard(
                                title: 'Room Status',
                                subtitle: 'Current distribution',
                                child: SizedBox(
                                  height: 260,
                                  child: _DynamicRoomStatusPieChart(
                                    available: data['available'] ?? 0,
                                    booked: data['booked'] ?? 0,
                                    blocked: data['blocked'] ?? 0,
                                    maintenance: data['maintenance'] ?? 0,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    const SizedBox(height: 24),
                    _ChartCard(
                      title: 'Revenue',
                      subtitle: 'Last 7 days',
                      child: SizedBox(
                        height: 260,
                        child: _RevenueLineChart(
                            labels: stats.labels, values: stats.dailyRevenue),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String count;
  final Color color;
  final VoidCallback onTap;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      count,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: const Color(0xFF1A1A2E),
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _BookingsBarChart extends StatelessWidget {
  const _BookingsBarChart({required this.labels, required this.values});

  final List<String> labels;
  final List<int> values;

  @override
  Widget build(BuildContext context) {
    final peak = values.fold<int>(0, (m, v) => v > m ? v : m);
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (peak < 5 ? 5 : peak + 2).toDouble(),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => const Color(0xFF003580),
            tooltipRoundedRadius: 8,
            tooltipPadding: const EdgeInsets.all(8),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${values[groupIndex]}',
                const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= labels.length) {
                  return const SizedBox();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(labels[index],
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                );
              },
            ),
          ),
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barGroups: List.generate(values.length, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: values[index].toDouble(),
                color: const Color(0xFF003580),
                width: 20,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _DynamicRoomStatusPieChart extends StatelessWidget {
  const _DynamicRoomStatusPieChart({
    required this.available,
    required this.booked,
    required this.blocked,
    required this.maintenance,
  });

  final int available;
  final int booked;
  final int blocked;
  final int maintenance;

  @override
  Widget build(BuildContext context) {
    final total = available + booked + blocked + maintenance;
    if (total == 0) {
      return const Center(
        child: Text('No rooms yet'),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: [
                PieChartSectionData(
                  value: available.toDouble(),
                  color: const Color(0xFF00C853),
                  title: 'Available\n$available',
                  radius: 60,
                  titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12),
                ),
                PieChartSectionData(
                  value: booked.toDouble(),
                  color: const Color(0xFFD32F2F),
                  title: 'Booked\n$booked',
                  radius: 60,
                  titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12),
                ),
                PieChartSectionData(
                  value: blocked.toDouble(),
                  color: const Color(0xFFFFC107),
                  title: 'Blocked\n$blocked',
                  radius: 60,
                  titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12),
                ),
                if (maintenance > 0)
                  PieChartSectionData(
                    value: maintenance.toDouble(),
                    color: Colors.grey,
                    title: 'Maint.\n$maintenance',
                    radius: 60,
                    titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 24),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _LegendItem(
                color: const Color(0xFF00C853),
                label: 'Available',
                value: '$available'),
            const SizedBox(height: 8),
            _LegendItem(
                color: const Color(0xFFD32F2F),
                label: 'Booked',
                value: '$booked'),
            const SizedBox(height: 8),
            _LegendItem(
                color: const Color(0xFFFFC107),
                label: 'Blocked',
                value: '$blocked'),
            if (maintenance > 0) ...[
              const SizedBox(height: 8),
              _LegendItem(
                  color: Colors.grey,
                  label: 'Maintenance',
                  value: '$maintenance'),
            ],
          ],
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _LegendItem(
      {required this.color, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: $value',
          style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
        ),
      ],
    );
  }
}

class _RevenueLineChart extends StatelessWidget {
  const _RevenueLineChart({required this.labels, required this.values});

  final List<String> labels;
  final List<double> values;

  @override
  Widget build(BuildContext context) {
    final peak = values.fold<double>(0, (m, v) => v > m ? v : m);
    return LineChart(
      LineChartData(
        maxY: peak <= 0 ? 1000 : peak * 1.2,
        minY: 0,
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => const Color(0xFF003580),
            tooltipRoundedRadius: 8,
            tooltipPadding: const EdgeInsets.all(8),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                final label =
                    index >= 0 && index < labels.length ? labels[index] : '';
                return LineTooltipItem(
                  '$label\n${CurrencyService.formatInr(values[index], decimals: 0)}',
                  const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                );
              }).toList();
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= labels.length) {
                  return const SizedBox();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(labels[index],
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                );
              },
            ),
          ),
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
                values.length, (i) => FlSpot(i.toDouble(), values[i])),
            isCurved: true,
            color: const Color(0xFF003580),
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
                show: true, color: const Color(0xFF003580).withOpacity(0.1)),
          ),
        ],
      ),
    );
  }
}

class _NotificationsSheet extends StatelessWidget {
  final NotificationProvider provider;
  const _NotificationsSheet({required this.provider});

  IconData _icon(String type) {
    switch (type) {
      case 'CHECKIN_REMINDER':
        return Icons.login_rounded;
      case 'CHECKOUT_REMINDER':
        return Icons.logout_rounded;
      default:
        return Icons.book_online_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = provider.notifications;
    return SafeArea(
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Notifications',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: TextButton(
                onPressed: () {
                  provider.markAsRead();
                  Navigator.pop(context);
                },
                child: const Text('Mark all read'),
              ),
            ),
            const Divider(height: 1),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Text('No notifications yet'),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (ctx, i) {
                    final n = items[i];
                    return ListTile(
                      leading: Icon(_icon(n.type),
                          color:
                              n.read ? Colors.grey : const Color(0xFF003580)),
                      title: Text(n.title,
                          style: TextStyle(
                              fontWeight: n.read
                                  ? FontWeight.normal
                                  : FontWeight.bold)),
                      subtitle: Text(n.message),
                      onTap: () => provider.markRead([n.id]),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Aggregates hotels, rooms and bookings into the numbers shown on the dashboard.
class _DashStats {
  final int hotels;
  final int bookings;
  final double revenue;
  final int total;
  final int available;
  final int booked;
  final int blocked;
  final int maintenance;
  final List<String> labels;
  final List<int> dailyBookings;
  final List<double> dailyRevenue;

  _DashStats({
    required this.hotels,
    required this.bookings,
    required this.revenue,
    required this.total,
    required this.available,
    required this.booked,
    required this.blocked,
    required this.maintenance,
    required this.labels,
    required this.dailyBookings,
    required this.dailyRevenue,
  });

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  factory _DashStats.empty() => _DashStats(
        hotels: 0,
        bookings: 0,
        revenue: 0,
        total: 0,
        available: 0,
        booked: 0,
        blocked: 0,
        maintenance: 0,
        labels: List.filled(7, ''),
        dailyBookings: List.filled(7, 0),
        dailyRevenue: List.filled(7, 0),
      );

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  factory _DashStats.compute(
    QuerySnapshot<Map<String, dynamic>> hotels,
    QuerySnapshot<Map<String, dynamic>> rooms,
    QuerySnapshot<Map<String, dynamic>> bookings,
  ) {
    final now = DateTime.now();
    final today = _day(now);

    final roomPrice = <String, double>{};
    var blocked = 0, maintenance = 0;
    for (final r in rooms.docs) {
      final data = r.data();
      roomPrice[r.id] = (data['price'] ?? 0).toDouble();
      final status = data['status'] ?? 'AVAILABLE';
      if (status == 'BLOCKED') blocked++;
      if (status == 'MAINTENANCE') maintenance++;
    }

    final days = List.generate(7, (i) => today.subtract(Duration(days: 6 - i)));
    final dailyBookings = List.filled(7, 0);
    final dailyRevenue = List.filled(7, 0.0);
    final occupiedRoomIds = <String>{};
    var revenue = 0.0;
    var counted = 0;

    for (final doc in bookings.docs) {
      final b = doc.data();
      final status = b['status'] ?? 'PENDING';
      if (status == 'CANCELLED') continue;
      counted++;

      final checkIn = (b['checkIn'] as Timestamp?)?.toDate();
      final checkOut = (b['checkOut'] as Timestamp?)?.toDate();
      final created = (b['createdAt'] as Timestamp?)?.toDate() ?? checkIn;

      if (checkIn != null &&
          checkOut != null &&
          !now.isBefore(checkIn) &&
          now.isBefore(checkOut)) {
        occupiedRoomIds.add(b['roomId'] ?? '');
      }

      final idx = created == null ? -1 : days.indexOf(_day(created));
      if (idx >= 0) dailyBookings[idx]++;

      if (b['paymentStatus'] == 'PAID') {
        var amount = (b['amount'] as num?)?.toDouble();
        if (amount == null && checkIn != null && checkOut != null) {
          final nights = _day(checkOut).difference(_day(checkIn)).inDays;
          amount = (nights < 1 ? 1 : nights) * (roomPrice[b['roomId']] ?? 0);
        }
        revenue += amount ?? 0;
        final paid = (b['paidAt'] as Timestamp?)?.toDate() ?? created;
        final pIdx = paid == null ? -1 : days.indexOf(_day(paid));
        if (pIdx >= 0) dailyRevenue[pIdx] += amount ?? 0;
      }
    }

    final total = rooms.docs.length;
    final booked = occupiedRoomIds.length;
    final available = (total - booked - blocked - maintenance).clamp(0, total);

    return _DashStats(
      hotels: hotels.docs.length,
      bookings: counted,
      revenue: revenue,
      total: total,
      available: available,
      booked: booked,
      blocked: blocked,
      maintenance: maintenance,
      labels: days.map((d) => _weekdays[d.weekday - 1]).toList(),
      dailyBookings: dailyBookings,
      dailyRevenue: dailyRevenue,
    );
  }
}
