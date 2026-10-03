import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/notification_provider.dart';
import '../../services/currency_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Stream<Map<String, int>> _getRoomCounts() {
    return FirebaseFirestore.instance
        .collectionGroup('rooms')
        .snapshots()
        .map((snapshot) {
      int available = 0;
      int booked = 0;
      int blocked = 0;
      int maintenance = 0;
      
      for (final doc in snapshot.docs) {
        final status = doc.data()['status'] ?? 'AVAILABLE';
        switch (status) {
          case 'AVAILABLE':
            available++;
          case 'BOOKED':
            booked++;
          case 'BLOCKED':
            blocked++;
          case 'MAINTENANCE':
            maintenance++;
        }
      }
      
      return {
        'available': available,
        'booked': booked,
        'blocked': blocked,
        'maintenance': maintenance,
        'total': available + booked + blocked + maintenance,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_rounded),
                    tooltip: 'Notifications',
                    onPressed: () {
                      notificationProvider.markAsRead();
                      Navigator.of(context).pushReplacementNamed('/bookings');
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                      child: Text('Sign Out', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 1200;
              final isMedium = constraints.maxWidth > 800;
              return SingleChildScrollView(
                padding: EdgeInsets.all(isWide ? 32 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isWide)
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.hotel_rounded,
                              label: 'Hotels',
                              count: '12',
                              color: const Color(0xFF003580),
                              onTap: () => Navigator.of(context).pushReplacementNamed('/hotels'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: StreamBuilder<Map<String, int>>(
                              stream: _getRoomCounts(),
                              builder: (context, snapshot) {
                                final total = snapshot.data?['total'] ?? 0;
                                return _StatCard(
                                  icon: Icons.meeting_room_rounded,
                                  label: 'Rooms',
                                  count: '$total',
                                  color: const Color(0xFF0099FF),
                                  onTap: () => Navigator.of(context).pushReplacementNamed('/rooms'),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.book_online_rounded,
                              label: 'Bookings',
                              count: '${notificationProvider.unreadCount + 156}',
                              color: const Color(0xFF00C853),
                              onTap: () => Navigator.of(context).pushReplacementNamed('/bookings'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.payments_rounded,
                              label: 'Revenue',
                              count: CurrencyService.formatInr(12400, decimals: 0),
                              color: const Color(0xFFFFC107),
                              onTap: () {},
                            ),
                          ),
                        ],
                      )
                    else
                      SizedBox(
                        height: 180,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          children: [
                            _StatCard(
                              icon: Icons.hotel_rounded,
                              label: 'Hotels',
                              count: '12',
                              color: const Color(0xFF003580),
                              onTap: () => Navigator.of(context).pushReplacementNamed('/hotels'),
                            ),
                            const SizedBox(width: 12),
                            StreamBuilder<Map<String, int>>(
                              stream: _getRoomCounts(),
                              builder: (context, snapshot) {
                                final total = snapshot.data?['total'] ?? 0;
                                return _StatCard(
                                  icon: Icons.meeting_room_rounded,
                                  label: 'Rooms',
                                  count: '$total',
                                  color: const Color(0xFF0099FF),
                                  onTap: () => Navigator.of(context).pushReplacementNamed('/rooms'),
                                );
                              },
                            ),
                            const SizedBox(width: 12),
                            _StatCard(
                              icon: Icons.book_online_rounded,
                              label: 'Bookings',
                              count: '${notificationProvider.unreadCount + 156}',
                              color: const Color(0xFF00C853),
                              onTap: () => Navigator.of(context).pushReplacementNamed('/bookings'),
                            ),
                            const SizedBox(width: 12),
                            _StatCard(
                              icon: Icons.payments_rounded,
                              label: 'Revenue',
                              count: CurrencyService.formatInr(12400, decimals: 0),
                              color: const Color(0xFFFFC107),
                              onTap: () {},
                            ),
                          ],
                        ),
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
                                child: _BookingsBarChart(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: StreamBuilder<Map<String, int>>(
                              stream: _getRoomCounts(),
                              builder: (context, snapshot) {
                                final data = snapshot.data ?? {'available': 0, 'booked': 0, 'blocked': 0, 'maintenance': 0};
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
                              child: _BookingsBarChart(),
                            ),
                          ),
                          const SizedBox(height: 24),
                          StreamBuilder<Map<String, int>>(
                            stream: _getRoomCounts(),
                            builder: (context, snapshot) {
                              final data = snapshot.data ?? {'available': 0, 'booked': 0, 'blocked': 0, 'maintenance': 0};
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
                        child: _RevenueLineChart(),
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
    final isWide = MediaQuery.of(context).size.width > 1200;
    return Container(
      width: isWide ? null : 200,
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
  _BookingsBarChart();

  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final List<int> _bookings = [12, 18, 15, 22, 28, 35, 25];

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 40,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => const Color(0xFF003580),
            tooltipRoundedRadius: 8,
            tooltipPadding: const EdgeInsets.all(8),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${_bookings[groupIndex]}',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                if (index < 0 || index >= _days.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _days[index],
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barGroups: List.generate(_bookings.length, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: _bookings[index].toDouble(),
                color: const Color(0xFF003580),
                width: 20,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
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
        PieChart(
          PieChartData(
            sectionsSpace: 2,
            centerSpaceRadius: 40,
            sections: [
              PieChartSectionData(
                value: available.toDouble(),
                color: const Color(0xFF00C853),
                title: 'Available\n$available',
                radius: 60,
                titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
              PieChartSectionData(
                value: booked.toDouble(),
                color: const Color(0xFFD32F2F),
                title: 'Booked\n$booked',
                radius: 60,
                titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
              PieChartSectionData(
                value: blocked.toDouble(),
                color: const Color(0xFFFFC107),
                title: 'Blocked\n$blocked',
                radius: 60,
                titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
              if (maintenance > 0)
                PieChartSectionData(
                  value: maintenance.toDouble(),
                  color: Colors.grey,
                  title: 'Maint.\n$maintenance',
                  radius: 60,
                  titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _LegendItem(color: const Color(0xFF00C853), label: 'Available', value: '$available'),
            const SizedBox(height: 8),
            _LegendItem(color: const Color(0xFFD32F2F), label: 'Booked', value: '$booked'),
            const SizedBox(height: 8),
            _LegendItem(color: const Color(0xFFFFC107), label: 'Blocked', value: '$blocked'),
            if (maintenance > 0) ...[
              const SizedBox(height: 8),
              _LegendItem(color: Colors.grey, label: 'Maintenance', value: '$maintenance'),
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

  const _LegendItem({required this.color, required this.label, required this.value});

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
  _RevenueLineChart();

  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final List<double> _revenue = [1200, 1800, 1500, 2200, 2800, 3500, 2500];

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        maxY: 4000,
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
                final label = index >= 0 && index < _days.length ? _days[index] : '';
                return LineTooltipItem(
                  '$label\n₹${_revenue[index].toInt()}',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                if (index < 0 || index >= _days.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _days[index],
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(_revenue.length, (index) {
              return FlSpot(index.toDouble(), _revenue[index]);
            }),
            isCurved: true,
            color: const Color(0xFF003580),
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF003580).withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }
}
