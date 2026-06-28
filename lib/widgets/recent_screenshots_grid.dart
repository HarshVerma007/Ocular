import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import '../core/app_theme.dart';
import '../core/app_constants.dart';
import '../services/screenshot_service.dart';
import '../services/ocr_service.dart';

/// Screenshot grid — dark cards with green accents.
class ScreenshotGrid extends StatefulWidget {
  final int maxCount;
  final String? selectedFilter;
  final String? searchQuery;
  final VoidCallback? onClearSearch;
  final VoidCallback? onResetFilter;

  const ScreenshotGrid({
    super.key,
    this.maxCount = 20,
    this.selectedFilter,
    this.searchQuery,
    this.onClearSearch,
    this.onResetFilter,
  });

  @override
  State<ScreenshotGrid> createState() => _ScreenshotGridState();
}

class _ScreenshotGridState extends State<ScreenshotGrid> {
  List<AssetEntity>? _screenshots;
  bool _isLoading = true;
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    _loadScreenshots();
  }

  @override
  void didUpdateWidget(covariant ScreenshotGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.selectedFilter ?? 'All') != (widget.selectedFilter ?? 'All') ||
        (oldWidget.searchQuery ?? '') != (widget.searchQuery ?? '')) {
      setState(() {
        _isLoading = true;
      });
      _loadScreenshots();
    }
  }

  Future<void> _loadScreenshots() async {
    final service = ScreenshotService.instance;
    final hasPermission = await service.checkPermission();

    if (!hasPermission) {
      if (mounted) setState(() { _permissionDenied = true; _isLoading = false; });
      return;
    }

    List<AssetEntity> screenshots;
    final now = DateTime.now();
    final filter = widget.selectedFilter ?? 'All';
    final query = widget.searchQuery ?? '';

    if (filter == 'Today') {
      final start = DateTime(now.year, now.month, now.day);
      screenshots = await service.getScreenshotsByDateRange(start: start, end: now, count: widget.maxCount);
    } else if (filter == 'This Week') {
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
      screenshots = await service.getScreenshotsByDateRange(start: start, end: now, count: widget.maxCount);
    } else if (filter == 'This Month') {
      final start = DateTime(now.year, now.month, 1);
      screenshots = await service.getScreenshotsByDateRange(start: start, end: now, count: widget.maxCount);
    } else {
      // 'All'
      screenshots = await service.getRecentScreenshots(count: widget.maxCount);
    }

    if (query.isNotEmpty) {
      screenshots = await OcrService.instance.searchScreenshots(
        query,
        screenshots,
      );
    }

    if (mounted) {
      setState(() {
        _screenshots = screenshots;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _buildShimmer();
    if (_permissionDenied) return _buildPermission();
    if (_screenshots == null || _screenshots!.isEmpty) return _buildEmpty();
    return _buildGrid();
  }

  Widget _buildGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingXL),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.7,
      ),
      itemCount: _screenshots!.length,
      itemBuilder: (context, index) {
        return _ScreenshotCard(asset: _screenshots![index], index: index);
      },
    );
  }

  Widget _buildShimmer() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingXL),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.7,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => _ShimmerCard(index: index),
    );
  }

  Widget _buildPermission() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingXL),
      child: _TerminalWindow(
        title: 'SECURE_SHELL://AUTH_FAILURE',
        isAlert: true,
        terminalLines: const [
          'SYSTEM STATUS: PENDING AUTHORIZATION',
          'ERROR: [SEC_DEP_401] PERMISSION_DENIED',
          'CAUSE: PHOTO LIBRARY ACCESS IS REQUIRED',
          'RUNNING DIAGNOSTIC... FAILED',
        ],
        buttonLabel: './sudo_grant_access.sh',
        onButtonPressed: () async {
          final service = ScreenshotService.instance;
          final granted = await service.requestPermission();
          if (granted) {
            _loadScreenshots();
          }
        },
      ),
    );
  }

  Widget _buildEmpty() {
    final query = widget.searchQuery ?? '';
    final filter = widget.selectedFilter ?? 'All';

    if (query.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingXL),
        child: _TerminalWindow(
          title: 'SECURE_SHELL://QUERY_EXCEPTION',
          isAlert: true,
          terminalLines: [
            'SEARCH RESULT: 0 RECORDS MATCHED',
            'QUERY STRING : "$query"',
            'SECTOR SCOPE : ${filter.toUpperCase()}',
            '',
            'DIAGNOSTICS & RECOMMENDATIONS:',
            '-> verify input keyword spelling',
            '-> search with simplified keywords',
            '-> expand sector scope time filter',
          ],
          buttonLabel: './clear_search_query.sh',
          onButtonPressed: widget.onClearSearch,
        ),
      );
    }

    if (filter != 'All') {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingXL),
        child: _TerminalWindow(
          title: 'ocular@localhost:~',
          terminalLines: [
            'scanning active storage sectors... OK',
            'FILTER SECTOR: DATE_FILTER_ACTIVE',
            'TARGET WINDOW: ${filter.toUpperCase()}',
            'MATCHED ITEMS: 0 files in range',
            '',
            'STATUS: NO_ASSETS_IN_TIME_WINDOW',
          ],
          buttonLabel: './reset_time_filter.sh',
          onButtonPressed: widget.onResetFilter,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingXL),
      child: _TerminalWindow(
        title: 'ocular@localhost:~',
        terminalLines: const [
          'initializing screenshot watcher...',
          'scanning active storage sectors... OK',
          'indexing database metadata... 0 files',
          'STATUS: LISTENING_FOR_NEW_IMAGES',
        ],
        buttonLabel: './ingest_mock_data.sh',
        onButtonPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'mock_daemon: simulating file creation...',
                style: TextStyle(fontFamily: 'JetBrainsMono', color: AppTheme.green),
              ),
              backgroundColor: AppTheme.surface,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                side: const BorderSide(color: AppTheme.green, width: 0.5),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TerminalWindow extends StatefulWidget {
  final String title;
  final List<String> terminalLines;
  final String? buttonLabel;
  final VoidCallback? onButtonPressed;
  final bool isAlert;

  const _TerminalWindow({
    required this.title,
    required this.terminalLines,
    this.buttonLabel,
    this.onButtonPressed,
    this.isAlert = false,
  });

  @override
  State<_TerminalWindow> createState() => _TerminalWindowState();
}

class _TerminalWindowState extends State<_TerminalWindow>
    with SingleTickerProviderStateMixin {
  late AnimationController _cursorController;
  late Animation<double> _cursorOpacity;

  @override
  void initState() {
    super.initState();
    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
    _cursorOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 50),
      TweenSequenceItem(tween: ConstantTween<double>(0.0), weight: 50),
    ]).animate(_cursorController);
  }

  @override
  void dispose() {
    _cursorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = widget.isAlert ? AppTheme.alert : AppTheme.green;
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        border: Border.all(
          color: widget.isAlert ? AppTheme.alert : AppTheme.border,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Terminal Title Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: widget.isAlert
                  ? AppTheme.alertSubtle
                  : AppTheme.border.withValues(alpha: 0.3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppConstants.radiusMD - 1),
                topRight: Radius.circular(AppConstants.radiusMD - 1),
              ),
            ),
            child: Row(
              children: [
                // Red/Yellow/Green circle dots like macOS terminal
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: widget.isAlert ? AppTheme.alert : AppTheme.greenDim,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.border,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 11,
                      color: widget.isAlert ? AppTheme.alert : AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // Terminal Body
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                ...widget.terminalLines.map((line) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        line,
                        style: TextStyle(
                          fontFamily: 'JetBrainsMono',
                          fontSize: 11,
                          color: widget.isAlert ? AppTheme.alert : AppTheme.textPrimary,
                        ),
                      ),
                    )),
                // Input Prompt with blinking cursor
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(

                      widget.isAlert ? '\$ ' : '> ',
                      style: TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 11,
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _cursorOpacity,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _cursorOpacity.value,
                          child: Container(
                            width: 6,
                            height: 12,
                            color: accentColor,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                if (widget.buttonLabel != null) ...[
                  const SizedBox(height: 16),
                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: widget.onButtonPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: accentColor,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                            side: BorderSide(color: accentColor, width: 1.0),
                          ),
                        ),
                        child: Text(
                          widget.buttonLabel!,
                          style: const TextStyle(
                            fontFamily: 'JetBrainsMono',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScreenshotCard extends StatefulWidget {
  final AssetEntity asset;
  final int index;
  const _ScreenshotCard({required this.asset, required this.index});

  @override
  State<_ScreenshotCard> createState() => _ScreenshotCardState();
}

class _ScreenshotCardState extends State<_ScreenshotCard>
    with SingleTickerProviderStateMixin {
  Uint8List? _thumb;
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200 + widget.index * 50),
    );
    _load();
  }

  Future<void> _load() async {
    final data = await widget.asset.thumbnailDataWithSize(
      const ThumbnailSize(300, 420), quality: 85,
    );
    if (mounted && data != null) {
      setState(() => _thumb = data);
      _anim.forward();
    }
  }

  @override
  void dispose() { _anim.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => _FullScreenImageViewer(asset: widget.asset),
          ),
        );
      },
      child: FadeTransition(
        opacity: CurvedAnimation(parent: _anim, curve: Curves.easeOut),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.radiusMD),
            color: AppTheme.card,
            border: Border.all(color: AppTheme.border, width: 0.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusMD),
            child: _thumb != null
                ? Image.memory(_thumb!, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
                : const Center(
                    child: SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 1.5, color: AppTheme.green),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _ShimmerCard extends StatefulWidget {
  final int index;
  const _ShimmerCard({required this.index});

  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.radiusMD),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 2.0 * _ctrl.value, 0),
              end: Alignment(-0.5 + 2.0 * _ctrl.value, 0),
              colors: const [AppTheme.surface, AppTheme.surfaceLight, AppTheme.surface],
            ),
          ),
        );
      },
    );
  }
}

class _FullScreenImageViewer extends StatelessWidget {
  final AssetEntity asset;

  const _FullScreenImageViewer({required this.asset});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.green, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          asset.title ?? 'SCREENSHOT_VIEW',
          style: const TextStyle(
            fontFamily: 'JetBrainsMono',
            fontSize: 12,
            color: AppTheme.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: FutureBuilder<File?>(
          future: asset.file,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
              return InteractiveViewer(
                maxScale: 4.0,
                minScale: 1.0,
                child: Image.file(
                  snapshot.data!,
                  fit: BoxFit.contain,
                ),
              );
            }
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.green, strokeWidth: 2),
            );
          },
        ),
      ),
    );
  }
}
