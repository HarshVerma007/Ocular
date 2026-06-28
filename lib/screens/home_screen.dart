import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_theme.dart';
import '../core/app_constants.dart';
import '../widgets/atlas_search_bar.dart';
import '../widgets/category_tags.dart';
import '../widgets/recent_screenshots_grid.dart';
import '../services/screenshot_service.dart';

/// Home Screen — dark, clean, focused.
/// Automatically verifies photo/gallery access permissions on startup and blocks the app
/// with a themed hacker console if access is denied.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  bool _hasPermission = false;
  bool _isChecking = true;
  int _selectedFilterIndex = 0;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAndRequestPermission(autoPrompt: true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Re-evaluate permission state when user returns from settings
      _checkAndRequestPermission(autoPrompt: false);
    }
  }

  Future<void> _checkAndRequestPermission({required bool autoPrompt}) async {
    final service = ScreenshotService.instance;
    bool granted = await service.checkPermission();

    if (!granted) {
      if (mounted) {
        setState(() {
          _hasPermission = false;
          _isChecking = false;
        });
      }
      if (autoPrompt) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showInAppPermissionDialog();
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _hasPermission = true;
          _isChecking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        backgroundColor: AppTheme.bg,
        body: Center(
          child: CircularProgressIndicator(
            color: AppTheme.green,
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (!_hasPermission) {
      return const Scaffold(
        backgroundColor: AppTheme.bg,
        body: SizedBox.expand(),
      );
    }

    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: topPadding + 20),

            // ─── Title ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingXL),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Ocular', style: AppTheme.displayLarge),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const _PrivacyPolicyScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                        border: Border.all(color: AppTheme.border, width: 0.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppTheme.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'privacy.sh',
                            style: TextStyle(
                              fontFamily: 'JetBrainsMono',
                              fontSize: 10,
                              color: AppTheme.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 4),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingXL),
              child: TypewriterText(
                texts: const [
                  'Find Any Screenshot. Instantly.',
                  'Type it. Find it.',
                  'Stop scrolling. Start finding.',
                  'Like Ctrl+F for your photos',
                  'Forgot where it is? Type it'
                ],
                style: AppTheme.bodyLarge.copyWith(color: AppTheme.textDim),
              ),
            ),

            const SizedBox(height: AppConstants.spacingXXL),

            // ─── Search ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingXL),
              child: AtlasSearchBar(
                controller: _searchController,
                onSearch: (q) {
                  setState(() {
                    _searchQuery = q;
                  });
                },
                onScanTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('scanning...', style: AppTheme.bodyMedium.copyWith(color: AppTheme.black)),
                      backgroundColor: AppTheme.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: AppConstants.spacingLG),

            // ─── Filters ─────────────────────────────────────────
            TimeFilterChips(
              selectedIndex: _selectedFilterIndex,
              onFilterChanged: (i) {
                setState(() {
                  _selectedFilterIndex = i;
                });
              },
            ),

            const SizedBox(height: AppConstants.spacingXXL),

            // ─── Section label ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingXL),
              child: Text('> recent', style: AppTheme.titleLarge),
            ),

            const SizedBox(height: AppConstants.spacingMD),

            // ─── Grid ────────────────────────────────────────────
            ScreenshotGrid(
              maxCount: 20,
              selectedFilter: AppConstants.timeFilters[_selectedFilterIndex],
              searchQuery: _searchQuery,
              onClearSearch: () {
                setState(() {
                  _searchController.clear();
                  _searchQuery = '';
                });
              },
              onResetFilter: () {
                setState(() {
                  _selectedFilterIndex = 0;
                });
              },
            ),

            const SizedBox(height: AppConstants.spacingHuge),
          ],
        ),
      ),
    );
  }

  void _showInAppPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: AppTheme.bg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              side: const BorderSide(color: AppTheme.green, width: 1.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppTheme.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'SECURE_SHELL://AUTH_REQUEST',
                        style: TextStyle(
                          fontFamily: 'JetBrainsMono',
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.green,
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: AppTheme.border, height: 24),
                  const Text(
                    'Ocular requires media storage or photo gallery permission to locate, index, and search your screenshots locally on this device.',
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 11,
                      color: AppTheme.textPrimary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            SystemNavigator.pop();
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.alert,
                            side: const BorderSide(color: AppTheme.alert),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                            ),
                          ),
                          child: const Text(
                            './exit_app.sh',
                            style: TextStyle(
                              fontFamily: 'JetBrainsMono',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            
                            final service = ScreenshotService.instance;
                            final granted = await service.requestPermission();
                            
                            if (mounted) {
                              setState(() {
                                _hasPermission = granted;
                                _isChecking = false;
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.green,
                            foregroundColor: AppTheme.black,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                            ),
                          ),
                          child: const Text(
                            './sudo_allow.sh',
                            style: TextStyle(
                              fontFamily: 'JetBrainsMono',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
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
  }
}

class TypewriterText extends StatefulWidget {
  final List<String> texts;
  final TextStyle? style;
  final Duration typingSpeed;
  final Duration pauseDuration;

  const TypewriterText({
    super.key,
    required this.texts,
    this.style,
    this.typingSpeed = const Duration(milliseconds: 60),
    this.pauseDuration = const Duration(seconds: 2),
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  String _currentText = '';
  Timer? _timer;
  int _charIndex = 0;
  bool _isDeleting = false;
  int _textIndex = 0;

  String get _targetText => widget.texts[_textIndex];

  @override
  void initState() {
    super.initState();
    _startTypewriter();
  }

  void _startTypewriter() {
    _timer = Timer.periodic(widget.typingSpeed, (timer) {
      if (!mounted) return;

      setState(() {
        if (!_isDeleting) {
          // Typing
          if (_charIndex < _targetText.length) {
            _charIndex++;
            _currentText = _targetText.substring(0, _charIndex);
          } else {
            // Reached end, pause and then delete
            _timer?.cancel();
            Future.delayed(widget.pauseDuration, () {
              if (mounted) {
                _isDeleting = true;
                _startTypewriter();
              }
            });
          }
        } else {
          // Deleting/Clearing
          if (_charIndex > 0) {
            _charIndex--;
            _currentText = _targetText.substring(0, _charIndex);
          } else {
            // Reached start, rotate text index, pause and then type again
            _isDeleting = false;
            _textIndex = (_textIndex + 1) % widget.texts.length;
            _timer?.cancel();
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                _startTypewriter();
              }
            });
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: widget.style,
        children: [
          TextSpan(text: _currentText),
          const WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: SizedBox(width: 2),
          ),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: _BlinkingCursor(color: widget.style?.color ?? AppTheme.textDim),
          ),
        ],
      ),
    );
  }
}

class _BlinkingCursor extends StatefulWidget {
  final Color color;
  const _BlinkingCursor({required this.color});

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return Opacity(
          opacity: _ctrl.value > 0.5 ? 1.0 : 0.0,
          child: Container(
            width: 6,
            height: 14,
            color: widget.color,
          ),
        );
      },
    );
  }
}

class _PrivacyPolicyScreen extends StatelessWidget {
  const _PrivacyPolicyScreen();

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
        title: const Text(
          'ocular@localhost:~//sys/privacy_disclosure',
          style: TextStyle(
            fontFamily: 'JetBrainsMono',
            fontSize: 11,
            color: AppTheme.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingXL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTerminalBox(
              title: '1. LOCAL_EXECUTION_DISCLOSURE',
              content: 'All image character analysis (OCR) is executed locally on-device. '
                  'Ocular does NOT compile, transmit, or store user screenshots on remote servers. '
                  'Your screenshots never leave your physical device.',
            ),
            const SizedBox(height: 16),
            _buildTerminalBox(
              title: '2. STORAGE_PERMISSIONS_SCOPE',
              content: 'Ocular requests READ media permissions solely to locate, filter, '
                  'and index screenshots for your queries. The system operates in a strict '
                  'READ-ONLY mode; it never modifies, creates, or deletes gallery assets.',
            ),
            const SizedBox(height: 16),
            _buildTerminalBox(
              title: '3. ML_KIT_PROCESSING',
              content: 'On-device text extraction is handled by Google ML Kit (latin script). '
                  'This service processes pixels locally within the application sandbox. No '
                  'network queries or third-party cloud APIs are triggered.',
            ),
            const SizedBox(height: 16),
            _buildTerminalBox(
              title: '4. DATA_RETENTION_POLICIES',
              content: 'OCR indexing data is stored temporarily in volatile system memory. '
                  'No background tracking, analytics databases, or identifiers are mapped to '
                  'your personal screenshots.',
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: AppTheme.green,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                  side: const BorderSide(color: AppTheme.green, width: 1.0),
                ),
              ),
              child: const Text(
                './close_override.sh',
                style: TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTerminalBox({required String title, required String content}) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        border: Border.all(color: AppTheme.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: const BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppConstants.radiusMD - 1),
                topRight: Radius.circular(AppConstants.radiusMD - 1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppTheme.greenDim,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              content,
              style: const TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 11,
                color: AppTheme.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
