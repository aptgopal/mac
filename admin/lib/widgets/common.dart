import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';

final _inr = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

String formatINR(double value) => _inr.format(value);
String formatINRCompact(double value) => '₹${value.toStringAsFixed(0)}';

class _NavItem {
  final String route;
  final String label;
  final IconData icon;
  const _NavItem({
    required this.route,
    required this.label,
    required this.icon,
  });
}

const List<_NavItem> _navItems = [
  _NavItem(route: '/dashboard', label: 'Dashboard', icon: Icons.dashboard_outlined),
  _NavItem(route: '/hotels', label: 'Hotels', icon: Icons.hotel_outlined),
  _NavItem(route: '/rooms', label: 'Rooms', icon: Icons.meeting_room_outlined),
  _NavItem(route: '/bookings', label: 'Bookings', icon: Icons.book_online_outlined),
];

/// Responsive Material 3 navigation shell for admin destinations.
class AdminScaffold extends StatelessWidget {
  final String route;
  final String title;
  final List<Widget>? actions;
  final Widget body;
  final Widget? floatingActionButton;

  const AdminScaffold({
    super.key,
    required this.route,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
  });

  void _go(BuildContext context, String target) {
    if (target != route) {
      Navigator.of(context).pushReplacementNamed(target);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        if (wide) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Row(
              children: [
                SizedBox(
                  width: 264,
                  child: _Sidebar(route: route, onTap: _go),
                ),
                Expanded(
                  child: Column(
                    children: [
                      _TopBar(title: title, actions: actions),
                      Expanded(child: body),
                    ],
                  ),
                ),
              ],
            ),
            floatingActionButton: floatingActionButton,
          );
        }
        return Scaffold(
          appBar: AppBar(title: Text(title), actions: actions),
          drawer: Drawer(
            width: 296,
            child: SafeArea(child: _Sidebar(route: route, onTap: _go)),
          ),
          body: body,
          floatingActionButton: floatingActionButton,
        );
      },
    );
  }
}

class _Sidebar extends StatelessWidget {
  final String route;
  final void Function(BuildContext, String) onTap;
  const _Sidebar({required this.route, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 30, 20, 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.hotel_rounded, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Lodge Booking',
                          style: TextStyle(
                              color: AppColors.text,
                              fontSize: 17,
                              fontWeight: FontWeight.w700)),
                      Text('Admin Console',
                          style: TextStyle(
                              color: AppColors.muted, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                for (final item in _navItems)
                  _NavTile(
                    item: item,
                    active: item.route == route,
                    onTap: () => onTap(context, item.route),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          _LogoutTile(onTap: () async {
            await Provider.of<AuthProvider>(context, listen: false).signOut();
            if (context.mounted) {
              Navigator.of(context).pushReplacementNamed('/login');
            }
          }),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final _NavItem item;
  final bool active;
  final VoidCallback onTap;
  const _NavTile({
    required this.item,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: active ? AppColors.primary.withOpacity(0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              children: [
                Icon(item.icon,
                    color: active ? AppColors.primary : AppColors.muted,
                    size: 22),
                const SizedBox(width: 14),
                Text(item.label,
                    style: TextStyle(
                      color: active ? AppColors.primary : AppColors.text,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 15,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoutTile extends StatelessWidget {
  final VoidCallback onTap;
  const _LogoutTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.logout, color: AppColors.muted, size: 22),
              const SizedBox(width: 14),
              const Text('Sign out',
                  style: TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w500,
                      fontSize: 15)),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  const _TopBar({required this.title, this.actions});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Text(title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  )),
          const Spacer(),
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}

/// A KPI / stat tile used on the dashboard.
class StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;
  const StatTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final child = Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(value,
                        style: const TextStyle(
                            fontSize: 26, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(label,
                        style: const TextStyle(
                            color: AppColors.muted, fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return onTap != null ? child : child;
  }
}

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final map = <String, (Color, Color, String)>{
      'confirmed': (AppColors.success, AppColors.successBg, 'Confirmed'),
      'pending': (AppColors.warning, AppColors.warningBg, 'Pending'),
      'cancelled': (AppColors.danger, AppColors.dangerBg, 'Cancelled'),
    };
    final (fg, bg, label) =
        map[status] ?? (AppColors.muted, AppColors.background, status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              color: fg, fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }
}

class AppChip extends StatelessWidget {
  final String label;
  const AppChip({super.key, required this.label});
  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(label), visualDensity: VisualDensity.compact);
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 44, color: AppColors.muted),
            ),
            const SizedBox(height: 16),
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted)),
            if (action != null) ...[const SizedBox(height: 16), action!],
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  const SectionTitle({super.key, required this.title, this.subtitle});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          if (subtitle != null)
            Text(subtitle!,
                style: const TextStyle(color: AppColors.muted, fontSize: 13)),
        ],
      ),
    );
  }
}

/// Renders hotel/room images with a graceful fallback.
class NetworkImageOrPlaceholder extends StatelessWidget {
  final String url;
  final double? height;
  final double? width;
  final BoxFit fit;
  const NetworkImageOrPlaceholder({
    super.key,
    required this.url,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final isEmpty = url.trim().isEmpty;
    return SizedBox(
      height: height,
      width: width,
      child: isEmpty
          ? Container(
              color: AppColors.background,
              child: const Center(
                  child: Icon(Icons.image_outlined,
                      color: AppColors.muted, size: 40)),
            )
          : Image.network(
              url,
              height: height,
              width: width,
              fit: fit,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.background,
                child: const Center(
                    child: Icon(Icons.broken_image_outlined,
                        color: AppColors.muted, size: 40)),
              ),
              loadingBuilder: (_, child, progress) {
                if (progress == null) return child;
                return Container(
                  color: AppColors.background,
                  child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2)),
                );
              },
            ),
    );
  }
}

class PagePadding extends StatelessWidget {
  final Widget child;
  const PagePadding({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: child,
    );
  }
}
