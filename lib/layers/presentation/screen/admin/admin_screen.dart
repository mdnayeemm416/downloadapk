import 'package:adnetwork/config/theme/styles_manager.dart';
import 'package:adnetwork/layers/data/model/user_model.dart';
import 'package:adnetwork/layers/data/repo/remote/admin_repository.dart';
import 'package:adnetwork/layers/data/model/device_association_model.dart';
import 'package:adnetwork/layers/presentation/controller/admin/admin_bloc.dart';
import 'package:adnetwork/layers/presentation/widget/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          AdminBloc(adminRepository: AdminRepository())
            ..add(const LoadAllUsers()),
      child: const _AdminScreenBody(),
    );
  }
}

class _AdminScreenBody extends StatelessWidget {
  const _AdminScreenBody();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<AdminBloc, AdminState>(
      listenWhen: (prev, curr) =>
          prev.successMessage != curr.successMessage ||
          prev.errorMessage != curr.errorMessage,
      listener: (context, state) {
        if (state.successMessage.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage),
              backgroundColor: cs.secondary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
        if (state.errorMessage.isNotEmpty &&
            state.status == AdminStatus.loaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: cs.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: cs.surface,
          appBar: AppBar(
            backgroundColor: cs.surface,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: cs.onSurface),
              onPressed: () => Navigator.pop(context),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [cs.primary, cs.secondary],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.admin_panel_settings_rounded,
                    size: 18,
                    color: cs.onPrimary,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'User Management',
                  style: getBoldStyle(fontSize: 18, color: cs.onSurface),
                ),
              ],
            ),
            actions: [
              if (state.currentTab == AdminTab.all)
                IconButton(
                  icon: Icon(
                    state.isSelectionMode
                        ? Icons.checklist_rtl_rounded
                        : Icons.checklist_rounded,
                    color: state.isSelectionMode ? cs.primary : cs.onSurface,
                  ),
                  tooltip: 'Toggle Selection Mode',
                  onPressed: () => context
                      .read<AdminBloc>()
                      .add(const ToggleSelectionMode()),
                ),
              // User count badge
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.people_rounded, size: 14, color: cs.primary),
                    const SizedBox(width: 6),
                    Text(
                      '${state.allUsers.length}',
                      style: getMediumStyle(fontSize: 12, color: cs.primary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                // ── Tab Bar ──
                _TabBar(cs: cs, isDark: isDark, currentTab: state.currentTab),
                const SizedBox(height: 8),

                // ── Search Bar ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? cs.onSurface.withValues(alpha: .05)
                          : cs.primaryContainer,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: cs.primary.withValues(alpha: isDark ? .1 : .06),
                      ),
                    ),
                    child: TextField(
                      onChanged: (v) =>
                          context.read<AdminBloc>().add(SearchUsers(v)),
                      decoration: InputDecoration(
                        hintText: 'Search by name or email...',
                        hintStyle: getRegularStyle(
                          fontSize: 13,
                          color: cs.onSurface.withValues(alpha: .35),
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          size: 20,
                          color: cs.primary.withValues(alpha: .5),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 13,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Expanded(child: _buildContent(context, state, cs, isDark)),
              ],
            ),
          ),
          floatingActionButton: state.isSelectionMode && state.selectedUserIds.isNotEmpty
              ? FloatingActionButton.extended(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text('Bulk Update Auto-Like', style: getBoldStyle(fontSize: 18, color: cs.onSurface)),
                        content: Text('Update auto-like subscription for ${state.selectedUserIds.length} users?', style: getRegularStyle(fontSize: 14, color: cs.onSurface)),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              context.read<AdminBloc>().add(const BulkUpdateSubscription(0));
                            },
                            child: Text('Disable', style: getMediumStyle(fontSize: 14, color: cs.error)),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              context.read<AdminBloc>().add(const BulkUpdateSubscription(1));
                            },
                            child: Text('Enable', style: getMediumStyle(fontSize: 14, color: cs.primary)),
                          ),
                        ],
                        backgroundColor: cs.surface,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    );
                  },
                  backgroundColor: cs.primary,
                  icon: const Icon(Icons.subscriptions_rounded, color: Colors.white),
                  label: Text(
                    'Bulk Update (${state.selectedUserIds.length})',
                    style: getBoldStyle(fontSize: 14, color: Colors.white),
                  ),
                )
              : null,
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    AdminState state,
    ColorScheme cs,
    bool isDark,
  ) {
    if (state.currentTab == AdminTab.devices) {
      return _buildPendingDevicesContent(context, state, cs, isDark);
    }

    if (state.status == AdminStatus.loading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: cs.primary),
            const SizedBox(height: 16),
            Text(
              'Loading users...',
              style: getRegularStyle(
                fontSize: 14,
                color: cs.onSurface.withValues(alpha: .5),
              ),
            ),
          ],
        ),
      );
    }

    if (state.status == AdminStatus.error && state.allUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cs.error.withValues(alpha: .08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: cs.error.withValues(alpha: .6),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load users',
              style: getMediumStyle(
                fontSize: 16,
                color: cs.onSurface.withValues(alpha: .6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.errorMessage,
              style: getRegularStyle(
                fontSize: 12,
                color: cs.onSurface.withValues(alpha: .4),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: () =>
                  context.read<AdminBloc>().add(const LoadAllUsers()),
              icon: Icon(Icons.refresh_rounded, color: cs.primary),
              label: Text(
                'Retry',
                style: getMediumStyle(fontSize: 14, color: cs.primary),
              ),
            ),
          ],
        ),
      );
    }

    final users = state.filteredUsers;

    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: .06),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_off_rounded,
                size: 48,
                color: cs.primary.withValues(alpha: .4),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              state.searchQuery.isNotEmpty
                  ? 'No matching users'
                  : 'No users in this category',
              style: getMediumStyle(
                fontSize: 16,
                color: cs.onSurface.withValues(alpha: .5),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<AdminBloc>().add(const LoadAllUsers());
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return TweenAnimationBuilder<double>(
            key: ValueKey(user.id),
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 300 + (index * 40).clamp(0, 300)),
            curve: Curves.easeOutCubic,
            builder: (ctx, val, child) => Opacity(
              opacity: val,
              child: Transform.translate(
                offset: Offset(0, 16 * (1 - val)),
                child: child,
              ),
            ),
            child: _UserManagementCard(
              user: user,
              state: state,
              cs: cs,
              isDark: isDark,
            ),
          );
        },
      ),
    );
  }

  Widget _buildPendingDevicesContent(
    BuildContext context,
    AdminState state,
    ColorScheme cs,
    bool isDark,
  ) {
    if (state.status == AdminStatus.loading && state.pendingDevices.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: cs.primary),
            const SizedBox(height: 16),
            Text(
              'Loading pending devices...',
              style: getRegularStyle(
                fontSize: 14,
                color: cs.onSurface.withValues(alpha: .5),
              ),
            ),
          ],
        ),
      );
    }

    final devices = state.pendingDevices;

    if (devices.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: .06),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.devices_rounded,
                size: 48,
                color: cs.primary.withValues(alpha: .4),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No pending devices',
              style: getMediumStyle(
                fontSize: 16,
                color: cs.onSurface.withValues(alpha: .5),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<AdminBloc>().add(const LoadPendingDevices());
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: devices.length,
        itemBuilder: (context, index) {
          final device = devices[index];
          return TweenAnimationBuilder<double>(
            key: ValueKey(device.deviceId),
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 300 + (index * 40).clamp(0, 300)),
            curve: Curves.easeOutCubic,
            builder: (ctx, val, child) => Opacity(
              opacity: val,
              child: Transform.translate(
                offset: Offset(0, 16 * (1 - val)),
                child: child,
              ),
            ),
            child: _DeviceManagementCard(
              device: device,
              cs: cs,
              isDark: isDark,
              isLoading: state.actionUserId == device.userId,
              actionType: state.actionType,
            ),
          );
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  TAB BAR
// ══════════════════════════════════════════════════════════
class _TabBar extends StatelessWidget {
  final ColorScheme cs;
  final bool isDark;
  final AdminTab currentTab;

  const _TabBar({
    required this.cs,
    required this.isDark,
    required this.currentTab,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: AdminTab.values.map((tab) {
          final isActive = tab == currentTab;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              child: Material(
                color: isActive
                    ? cs.primary
                    : (isDark
                          ? cs.onSurface.withValues(alpha: .05)
                          : cs.primaryContainer),
                borderRadius: BorderRadius.circular(24),
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () => context.read<AdminBloc>().add(ChangeTab(tab)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _iconForTab(tab),
                          size: 16,
                          color: isActive
                              ? cs.onPrimary
                              : cs.onSurface.withValues(alpha: .5),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _labelForTab(tab),
                          style: getMediumStyle(
                            fontSize: 13,
                            color: isActive
                                ? cs.onPrimary
                                : cs.onSurface.withValues(alpha: .65),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _iconForTab(AdminTab tab) {
    switch (tab) {
      case AdminTab.all:
        return Icons.people_rounded;
      case AdminTab.pending:
        return Icons.hourglass_top_rounded;
      case AdminTab.blocked:
        return Icons.block_rounded;
      case AdminTab.moderators:
        return Icons.verified_user_rounded;
      case AdminTab.resetRequests:
        return Icons.vpn_key_rounded;
      case AdminTab.devices:
        return Icons.devices_rounded;
    }
  }

  String _labelForTab(AdminTab tab) {
    switch (tab) {
      case AdminTab.all:
        return 'All Users';
      case AdminTab.pending:
        return 'Pending Users';
      case AdminTab.blocked:
        return 'Blocked';
      case AdminTab.moderators:
        return 'Moderators';
      case AdminTab.resetRequests:
        return 'Reset Requests';
      case AdminTab.devices:
        return 'Pending Devices';
    }
  }
}

// ══════════════════════════════════════════════════════════
//  USER MANAGEMENT CARD
// ══════════════════════════════════════════════════════════
class _UserManagementCard extends StatelessWidget {
  final UserModel user;
  final AdminState state;
  final ColorScheme cs;
  final bool isDark;

  const _UserManagementCard({
    required this.user,
    required this.state,
    required this.cs,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isLoading = state.actionUserId == user.id;
    final actionType = state.actionType;
    final isBlocked = user.isBlocked == 1;
    final isPending = user.isApproved == 0;
    final isAdmin = user.role == 'admin';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark
            ? cs.onSurface.withValues(alpha: .04)
            : cs.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isBlocked
              ? cs.error.withValues(alpha: .2)
              : isPending
              ? cs.tertiary.withValues(alpha: .2)
              : cs.primary.withValues(alpha: isDark ? .1 : .05),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: cs.primary.withValues(alpha: .03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
        ],
      ),
      child: Column(
        children: [
          // ── User Info Row ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 0),
            child: Row(
              children: [
                // Avatar with status ring
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isBlocked
                              ? cs.error
                              : isAdmin
                              ? cs.secondary
                              : cs.primary,
                          width: 2,
                        ),
                      ),
                      child: UserAvatar(
                        username: user.username ?? '',
                        radius: 22,
                      ),
                    ),
                    if (isBlocked)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: cs.error,
                            shape: BoxShape.circle,
                            border: Border.all(color: cs.surface, width: 2),
                          ),
                          child: Icon(
                            Icons.block_rounded,
                            size: 10,
                            color: cs.onPrimary,
                          ),
                        ),
                      ),
                    if (isAdmin && !isBlocked)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: cs.secondary,
                            shape: BoxShape.circle,
                            border: Border.all(color: cs.surface, width: 2),
                          ),
                          child: Icon(
                            Icons.shield_rounded,
                            size: 10,
                            color: cs.onSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),

                // Name, email, meta
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              user.username ?? 'Unknown',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: getSemiBoldStyle(
                                fontSize: 14,
                                color: cs.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          _StatusBadge(user: user, cs: cs),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.email ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: getRegularStyle(
                          fontSize: 11,
                          color: cs.onSurface.withValues(alpha: .45),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 11,
                            color: cs.onSurface.withValues(alpha: .3),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            user.createdAt != null
                                ? 'Joined ${DateFormat('dd MMM yyyy').format(user.createdAt!)}'
                                : 'Unknown',
                            style: getRegularStyle(
                              fontSize: 10,
                              color: cs.onSurface.withValues(alpha: .35),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.people_outline_rounded,
                            size: 11,
                            color: cs.onSurface.withValues(alpha: .3),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${user.followersCount} followers',
                            style: getRegularStyle(
                              fontSize: 10,
                              color: cs.onSurface.withValues(alpha: .35),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Loading indicator or expand
                if (isLoading)
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: cs.primary,
                    ),
                  )
                else if (state.isSelectionMode)
                  Checkbox(
                    value: state.selectedUserIds.contains(user.id),
                    activeColor: cs.primary,
                    onChanged: (_) {
                      if (user.id != null) {
                        context.read<AdminBloc>().add(ToggleUserSelection(user.id!));
                      }
                    },
                  )
                else
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert_rounded,
                      color: cs.onSurface.withValues(alpha: .4),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    color: isDark ? const Color(0xFF2A2A3A) : cs.surface,
                    elevation: 8,
                    onSelected: (val) => _handleAction(context, val),
                    itemBuilder: (_) => _buildMenuItems(cs),
                  ),
              ],
            ),
          ),

          // ── Action Buttons Row ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            child: Row(children: _buildQuickActions(context, cs)),
          ),
        ],
      ),
    );
  }

  void _handleAction(BuildContext context, String action) {
    final bloc = context.read<AdminBloc>();
    final id = user.id ?? '';
    switch (action) {
      case 'approve':
        bloc.add(ApproveUser(id));
        break;
      case 'reject':
        bloc.add(RejectUser(id));
        break;
      case 'block':
        bloc.add(BlockUser(id));
        break;
      case 'unblock':
        bloc.add(UnblockUser(id));
        break;
      case 'make-moderator':
        bloc.add(MakeModerator(id));
        break;
      case 'remove-moderator':
        bloc.add(RemoveModerator(id));
        break;
      case 'reset-password':
        bloc.add(ResetUserPassword(id));
        break;
      case 'enable-autolike':
        bloc.add(UpdateSubscription(id, 1));
        break;
      case 'disable-autolike':
        bloc.add(UpdateSubscription(id, 0));
        break;
    }
  }

  List<PopupMenuEntry<String>> _buildMenuItems(ColorScheme cs) {
    final items = <PopupMenuEntry<String>>[];
    final isBlocked = user.isBlocked == 1;
    final isPending = user.isApproved == 0;
    final isAdmin = user.role == 'admin';
    final isModerator = user.role == 'moderator';

    if (isPending) {
      items.add(
        _menuItem(
          'approve',
          Icons.check_circle_outline_rounded,
          'Approve',
          cs.secondary,
        ),
      );
      items.add(_menuItem('reject', Icons.cancel_outlined, 'Reject', cs.error));
      items.add(const PopupMenuDivider());
    }

    if (user.autolike == 1) {
      items.add(_menuItem('disable-autolike', Icons.subscriptions_outlined, 'Disable Auto-Like', cs.error));
    } else {
      items.add(_menuItem('enable-autolike', Icons.subscriptions_rounded, 'Enable Auto-Like', cs.primary));
    }
    items.add(const PopupMenuDivider());

    if (isBlocked) {
      items.add(
        _menuItem('unblock', Icons.lock_open_rounded, 'Unblock', cs.secondary),
      );
    } else {
      items.add(_menuItem('block', Icons.block_rounded, 'Block', cs.error));
    }

    items.add(const PopupMenuDivider());

    if (isModerator) {
      items.add(
        _menuItem(
          'remove-moderator',
          Icons.verified_user_outlined,
          'Remove Moderator',
          cs.tertiary,
        ),
      );
    } else if (!isAdmin) {
      items.add(
        _menuItem(
          'make-moderator',
          Icons.verified_user_rounded,
          'Make Moderator',
          cs.secondary,
        ),
      );
    }

    items.add(const PopupMenuDivider());
    items.add(
      _menuItem(
        'reset-password',
        Icons.vpn_key_rounded,
        'Reset Password',
        Colors.orange,
      ),
    );

    return items;
  }

  PopupMenuItem<String> _menuItem(
    String value,
    IconData icon,
    String label,
    Color color,
  ) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Text(label, style: getMediumStyle(fontSize: 13, color: color)),
        ],
      ),
    );
  }

  List<Widget> _buildQuickActions(BuildContext context, ColorScheme cs) {
    final isBlocked = user.isBlocked == 1;
    final isPending = user.isApproved == 0;
    final actions = <Widget>[];

    if (isPending) {
      actions.add(
        _ActionChip(
          label: 'Approve',
          icon: Icons.check_rounded,
          color: cs.secondary,
          onTap: () => _handleAction(context, 'approve'),
        ),
      );
      actions.add(const SizedBox(width: 8));
      actions.add(
        _ActionChip(
          label: 'Reject',
          icon: Icons.close_rounded,
          color: cs.error,
          onTap: () => _handleAction(context, 'reject'),
        ),
      );
    } else if (isBlocked) {
      actions.add(
        _ActionChip(
          label: 'Unblock',
          icon: Icons.lock_open_rounded,
          color: cs.secondary,
          onTap: () => _handleAction(context, 'unblock'),
        ),
      );
    } else {
      actions.add(
        _ActionChip(
          label: 'Block',
          icon: Icons.block_rounded,
          color: cs.error,
          outlined: true,
          onTap: () => _handleAction(context, 'block'),
        ),
      );
    }

    if (user.resetRequested == 1) {
      actions.add(const SizedBox(width: 8));
      actions.add(
        _ActionChip(
          label: 'Reset Pwd',
          icon: Icons.vpn_key_rounded,
          color: Colors.orange,
          onTap: () => _handleAction(context, 'reset-password'),
        ),
      );
    }

    return actions;
  }
}

// ══════════════════════════════════════════════════════════
//  STATUS BADGE
// ══════════════════════════════════════════════════════════
class _StatusBadge extends StatelessWidget {
  final UserModel user;
  final ColorScheme cs;

  const _StatusBadge({required this.user, required this.cs});

  @override
  Widget build(BuildContext context) {
    String label;
    Color color;

    if (user.resetRequested == 1) {
      label = 'Reset Requested';
      color = Colors.orange;
    } else if (user.isBlocked == 1) {
      label = 'Blocked';
      color = cs.error;
    } else if (user.isApproved == 0) {
      label = 'Pending';
      color = cs.tertiary;
    } else if (user.role == 'admin') {
      label = 'Admin';
      color = cs.secondary;
    } else if (user.role == 'moderator') {
      label = 'Moderator';
      color = Colors.orange;
    } else {
      label = 'Active';
      color = cs.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: .25)),
      ),
      child: Text(label, style: getMediumStyle(fontSize: 9, color: color)),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  ACTION CHIP
// ══════════════════════════════════════════════════════════
class _ActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool outlined;

  const _ActionChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: outlined ? Colors.transparent : color.withValues(alpha: .1),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: .3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 5),
              Text(label, style: getMediumStyle(fontSize: 11, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  DEVICE MANAGEMENT CARD
// ══════════════════════════════════════════════════════════
class _DeviceManagementCard extends StatelessWidget {
  final DeviceAssociationModel device;
  final ColorScheme cs;
  final bool isDark;
  final bool isLoading;
  final String actionType;

  const _DeviceManagementCard({
    required this.device,
    required this.cs,
    required this.isDark,
    required this.isLoading,
    required this.actionType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark
            ? cs.onSurface.withValues(alpha: .04)
            : cs.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cs.primary.withValues(alpha: isDark ? .1 : .05),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: cs.primary.withValues(alpha: .03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
        ],
      ),
      child: Column(
        children: [
          // ── Device Info Row ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: .1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.devices_rounded,
                    size: 24,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device.user?.username ?? 'Unknown User',
                        style: getBoldStyle(fontSize: 16, color: cs.onSurface),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        device.user?.email ?? 'No email',
                        style: getRegularStyle(
                          fontSize: 13,
                          color: cs.onSurface.withValues(alpha: .5),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Device ID: ${device.deviceId ?? 'Unknown'}',
                        style: getRegularStyle(
                          fontSize: 11,
                          color: cs.onSurface.withValues(alpha: .4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Actions ──
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: _ActionChip(
                    label: 'Reject',
                    icon: Icons.close_rounded,
                    color: cs.error,
                    onTap: () => context.read<AdminBloc>().add(
                      RejectDevice(device.userId!, device.deviceId!),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ActionChip(
                    label: 'Approve',
                    icon: Icons.check_rounded,
                    color: cs.primary,
                    onTap: () => context.read<AdminBloc>().add(
                      ApproveDevice(device.userId!, device.deviceId!),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
