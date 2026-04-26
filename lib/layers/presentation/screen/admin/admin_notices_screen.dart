import 'package:adnetwork/config/theme/styles_manager.dart';
import 'package:adnetwork/layers/data/repo/remote/notice_repository.dart';
import 'package:adnetwork/layers/presentation/controller/notice/notice_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class AdminNoticesScreen extends StatelessWidget {
  const AdminNoticesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          NoticeBloc(noticeRepository: NoticeRepository())..add(const LoadNotices()),
      child: const _AdminNoticesBody(),
    );
  }
}

class _AdminNoticesBody extends StatelessWidget {
  const _AdminNoticesBody();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                gradient: LinearGradient(colors: [cs.primary, cs.secondary]),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.campaign_rounded, size: 18, color: cs.onPrimary),
            ),
            const SizedBox(width: 10),
            Text('Manage Notices', style: getBoldStyle(fontSize: 18, color: cs.onSurface)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateNoticeSheet(context),
        backgroundColor: cs.primary,
        icon: Icon(Icons.add_rounded, color: cs.onPrimary),
        label: Text('New Notice', style: getMediumStyle(fontSize: 14, color: cs.onPrimary)),
      ),
      body: SafeArea(
        child: BlocConsumer<NoticeBloc, NoticeState>(
          listenWhen: (prev, curr) =>
              prev.successMessage != curr.successMessage ||
              prev.errorMessage != curr.errorMessage,
          listener: (context, state) {
            if (state.successMessage.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.successMessage),
                backgroundColor: cs.secondary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ));
            }
            if (state.errorMessage.isNotEmpty && state.status == NoticeStatus.loaded) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: cs.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ));
            }
          },
          builder: (context, state) {
            if (state.status == NoticeStatus.loading && state.notices.isEmpty) {
              return Center(child: CircularProgressIndicator(color: cs.primary));
            }
      
            if (state.status == NoticeStatus.error && state.notices.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline_rounded, size: 48, color: cs.error.withValues(alpha: .5)),
                    const SizedBox(height: 16),
                    Text('Failed to load notices', style: getMediumStyle(fontSize: 16, color: cs.onSurface)),
                  ],
                ),
              );
            }
      
            if (state.notices.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: cs.primary.withValues(alpha: .06), shape: BoxShape.circle),
                      child: Icon(Icons.campaign_outlined, size: 48, color: cs.primary.withValues(alpha: .4)),
                    ),
                    const SizedBox(height: 16),
                    Text('No active notices', style: getMediumStyle(fontSize: 16, color: cs.onSurface.withValues(alpha: .6))),
                  ],
                ),
              );
            }
      
            return RefreshIndicator(
              onRefresh: () async {
                context.read<NoticeBloc>().add(const LoadNotices());
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                itemCount: state.notices.length,
                itemBuilder: (context, index) {
                  final notice = state.notices[index];
                  final isDeleting = state.actionId == notice.id;
      
                  Color bg = _parseColor(notice.bgColor, cs.primaryContainer);
                  Color text = _parseColor(notice.textColor, cs.onSurface);
      
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        if (!isDark) BoxShadow(color: cs.primary.withValues(alpha: .05), blurRadius: 8, offset: const Offset(0, 3)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.campaign_rounded, size: 16, color: text.withValues(alpha: .6)),
                                const SizedBox(width: 8),
                                Text(
                                  notice.createdAt != null
                                      ? DateFormat('MMM dd, yyyy  HH:mm').format(notice.createdAt!)
                                      : 'Unknown Date',
                                  style: getMediumStyle(fontSize: 12, color: text.withValues(alpha: .6)),
                                ),
                              ],
                            ),
                            isDeleting
                                ? SizedBox(
                                    width: 20, height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: text),
                                  )
                                : InkWell(
                                    onTap: () {
                                      if (notice.id != null) {
                                        context.read<NoticeBloc>().add(DeleteNotice(notice.id!));
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(color: text.withValues(alpha: .1), shape: BoxShape.circle),
                                      child: Icon(Icons.delete_outline_rounded, size: 16, color: text.withValues(alpha: .8)),
                                    ),
                                  ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          notice.text ?? '',
                          style: getSemiBoldStyle(fontSize: 15, color: text),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Color _parseColor(String? hexCode, Color fallback) {
    if (hexCode == null || hexCode.isEmpty) return fallback;
    try {
      final code = hexCode.replaceAll('#', '');
      return Color(int.parse('FF$code', radix: 16));
    } catch (_) {
      return fallback;
    }
  }

  void _showCreateNoticeSheet(BuildContext context) {
    final bloc = context.read<NoticeBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: const _CreateNoticeSheet(),
      ),
    );
  }
}

class _CreateNoticeSheet extends StatefulWidget {
  const _CreateNoticeSheet();

  @override
  State<_CreateNoticeSheet> createState() => _CreateNoticeSheetState();
}

class _CreateNoticeSheetState extends State<_CreateNoticeSheet> {
  final _textCtrl = TextEditingController();
  
  // Pre-defined pastel pleasing colors exactly matching feed screens
  final List<Map<String, String>> _colors = [
    {'bg': '#F4F8FF', 'txt': '#1565C0'}, // Pastel Blue with dark blue text
    {'bg': '#FFFCF0', 'txt': '#8D6E63'}, // Pastel Yellow with brownish text
    {'bg': '#FFF0F0', 'txt': '#B71C1C'}, // Pastel Red with dark red text
    {'bg': '#F0FFF0', 'txt': '#2E7D32'}, // Pastel Green with dark green text
    {'bg': '#F9F0FF', 'txt': '#6A1B9A'}, // Pastel Purple with dark purple text
    {'bg': '#FFF0F5', 'txt': '#AD1457'}, // Pastel Pink with dark pink text
  ];
  
  int _selectedColorIdx = 0;

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: BlocConsumer<NoticeBloc, NoticeState>(
          listenWhen: (p, c) => p.actionId == 'create' && c.actionId != 'create',
          listener: (context, state) {
            if (state.errorMessage.isEmpty) {
              Navigator.pop(context);
            }
          },
          builder: (context, state) {
            final isCreating = state.actionId == 'create';
            final selectedColor = _colors[_selectedColorIdx];
            final bg = Color(int.parse('FF${selectedColor['bg']!.replaceAll('#', '')}', radix: 16));

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('New Notice', style: getBoldStyle(fontSize: 18, color: cs.onSurface)),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: cs.onSurface.withValues(alpha: .5)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Text Input
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? cs.onSurface.withValues(alpha: .05) : cs.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cs.primary.withValues(alpha: isDark ? .1 : .06)),
                  ),
                  child: TextField(
                    controller: _textCtrl,
                    maxLines: 4,
                    minLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Enter notice details here...',
                      hintStyle: getRegularStyle(fontSize: 14, color: cs.onSurface.withValues(alpha: .35)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Text('Appearance', style: getSemiBoldStyle(fontSize: 15, color: cs.onSurface)),
                const SizedBox(height: 12),
                
                // Color Picker
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(_colors.length, (idx) {
                      final c = _colors[idx];
                      final cColor = Color(int.parse('FF${c['bg']!.replaceAll('#', '')}', radix: 16));
                      final cTxtColor = Color(int.parse('FF${c['txt']!.replaceAll('#', '')}', radix: 16));
                      final isSelected = _selectedColorIdx == idx;

                      return GestureDetector(
                        onTap: () => setState(() => _selectedColorIdx = idx),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: cColor,
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected ? Border.all(color: cs.onSurface, width: 2) : Border.all(color: Colors.transparent, width: 2),
                            boxShadow: [
                              if (isSelected && !isDark) BoxShadow(color: cColor.withValues(alpha: .3), blurRadius: 8, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: Icon(
                            isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                            color: cTxtColor,
                            size: 18,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 32),

                // Post Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isCreating ? null : () {
                      if (_textCtrl.text.trim().isEmpty) return;
                      context.read<NoticeBloc>().add(CreateNotice(
                        text: _textCtrl.text.trim(),
                        bgColor: selectedColor['bg']!,
                        textColor: selectedColor['txt']!,
                      ));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: bg,
                      foregroundColor: Color(int.parse('FF${selectedColor['txt']!.replaceAll('#', '')}', radix: 16)),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: isCreating
                        ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Color(int.parse('FF${selectedColor['txt']!.replaceAll('#', '')}', radix: 16))))
                        : Text('Post Notice', style: getBoldStyle(fontSize: 16)),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
