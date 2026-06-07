import 'package:adnetwork/config/theme/styles_manager.dart';
import 'package:adnetwork/layers/data/model/user_model.dart';
import 'package:adnetwork/layers/data/repo/remote/admin_repository.dart';
import 'package:adnetwork/layers/presentation/controller/admin/admin_bloc.dart';
import 'package:adnetwork/layers/presentation/widget/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class AdminSubscriptionsScreen extends StatelessWidget {
  const AdminSubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          AdminBloc(adminRepository: AdminRepository())
            ..add(const LoadAllUsers()),
      child: const _AdminSubscriptionsScreenBody(),
    );
  }
}

class _AdminSubscriptionsScreenBody extends StatelessWidget {
  const _AdminSubscriptionsScreenBody();

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
                    Icons.subscriptions_rounded,
                    size: 18,
                    color: cs.onPrimary,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Manage Subscriptions',
                  style: getBoldStyle(fontSize: 18, color: cs.onSurface),
                ),
              ],
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
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

                // ── Bulk Action Toolbar ──
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: state.isSelectionMode ? null : 0,
                  margin: EdgeInsets.only(
                    top: state.isSelectionMode ? 12 : 0,
                    left: 16,
                    right: 16,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? cs.onSurface.withValues(alpha: .04) : cs.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: cs.primary.withValues(alpha: isDark ? .2 : .15),
                    ),
                    boxShadow: [
                      if (!isDark && state.isSelectionMode)
                        BoxShadow(
                          color: cs.primary.withValues(alpha: .06),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: state.isSelectionMode
                      ? Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header Row
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: cs.primary.withValues(alpha: .1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.checklist_rounded, size: 20, color: cs.primary),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          state.selectedUserIds.isEmpty
                                              ? 'Bulk Actions Mode'
                                              : '${state.selectedUserIds.length} Users Selected',
                                          style: getBoldStyle(fontSize: 15, color: cs.onSurface),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          state.selectedUserIds.isEmpty
                                              ? 'Select users below to apply changes'
                                              : 'Choose an action to apply to selected users',
                                          style: getRegularStyle(
                                            fontSize: 12,
                                            color: cs.onSurface.withValues(alpha: .5),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.close_rounded, size: 20, color: cs.onSurface.withValues(alpha: .6)),
                                    onPressed: () => context.read<AdminBloc>().add(const ToggleSelectionMode()),
                                    style: IconButton.styleFrom(
                                      backgroundColor: cs.onSurface.withValues(alpha: .05),
                                    ),
                                  ),
                                ],
                              ),
                              
                              // Action Buttons
                              AnimatedSize(
                                duration: const Duration(milliseconds: 300),
                                child: state.selectedUserIds.isEmpty
                                    ? const SizedBox.shrink()
                                    : Padding(
                                        padding: const EdgeInsets.only(top: 16),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: _BulkActionButton(
                                                label: 'Disable Auto-Like',
                                                icon: Icons.subscriptions_outlined,
                                                color: cs.error,
                                                onTap: () => context.read<AdminBloc>().add(const BulkUpdateSubscription(0)),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: _BulkActionButton(
                                                label: 'Enable Auto-Like',
                                                icon: Icons.subscriptions_rounded,
                                                color: cs.primary,
                                                onTap: () => context.read<AdminBloc>().add(const BulkUpdateSubscription(1)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                if (!state.isSelectionMode)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => context.read<AdminBloc>().add(const ToggleSelectionMode()),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isDark ? cs.onSurface.withValues(alpha: .03) : cs.primaryContainer.withValues(alpha: .5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: cs.primary.withValues(alpha: isDark ? .15 : .1)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Left side: Bulk Actions Title
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: cs.primary.withValues(alpha: .1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.checklist_rounded, size: 18, color: cs.primary),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Bulk Actions',
                                      style: getBoldStyle(fontSize: 15, color: cs.onSurface),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Manage multiple subscriptions',
                                      style: getRegularStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: .5)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            // Right side: Total Users Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: cs.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: cs.primary.withValues(alpha: .1)),
                                boxShadow: [
                                  if (!isDark)
                                    BoxShadow(
                                      color: cs.primary.withValues(alpha: .04),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.people_rounded, size: 14, color: cs.primary),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${state.allUsers.length} Users',
                                    style: getMediumStyle(fontSize: 12, color: cs.primary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 12),

                Expanded(child: _buildContent(context, state, cs, isDark)),
              ],
            ),
          ),
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

    final users = state.allUsers.where((u) {
      if (state.searchQuery.isEmpty) return true;
      final q = state.searchQuery.toLowerCase();
      final n = u.username?.toLowerCase() ?? '';
      final e = u.email?.toLowerCase() ?? '';
      return n.contains(q) || e.contains(q);
    }).toList();

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
                  : 'No users available',
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
    final isBlocked = user.isBlocked == 1;
    final isAdmin = user.role == 'admin';
    final isAutoLikeEnabled = user.autolike == 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark
            ? cs.onSurface.withValues(alpha: .04)
            : cs.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAutoLikeEnabled
              ? cs.primary.withValues(alpha: .2)
              : cs.onSurface.withValues(alpha: .05),
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
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
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
                            Icons.subscriptions_rounded,
                            size: 11,
                            color: isAutoLikeEnabled
                                ? cs.primary
                                : cs.onSurface.withValues(alpha: .3),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isAutoLikeEnabled
                                ? 'Auto-Like Enabled'
                                : 'Auto-Like Disabled',
                            style: getMediumStyle(
                              fontSize: 10,
                              color: isAutoLikeEnabled
                                  ? cs.primary
                                  : cs.onSurface.withValues(alpha: .35),
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
                        context.read<AdminBloc>().add(
                          ToggleUserSelection(user.id!),
                        );
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
        ],
      ),
    );
  }

  void _handleAction(BuildContext context, String action) {
    final bloc = context.read<AdminBloc>();
    final id = user.id ?? '';
    switch (action) {
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

    if (user.autolike == 1) {
      items.add(
        _menuItem(
          'disable-autolike',
          Icons.subscriptions_outlined,
          'Disable Auto-Like',
          cs.error,
        ),
      );
    } else {
      items.add(
        _menuItem(
          'enable-autolike',
          Icons.subscriptions_rounded,
          'Enable Auto-Like',
          cs.primary,
        ),
      );
    }

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

    if (user.isBlocked == 1) {
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
//  BULK ACTION BUTTON
// ══════════════════════════════════════════════════════════
class _BulkActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _BulkActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: .1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: .2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(label, style: getMediumStyle(fontSize: 13, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

