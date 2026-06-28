import 'dart:async';
import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../core/app_constants.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  final List<String> _consoleLogs = [];
  int _logIndex = 0;
  Timer? _logTimer;

  final List<String> _sourceLogs = [
    'BOOTING OCULAR KERNEL v1.0.0...',
    'CONNECTING FILE SYSTEM INTERFACE... OK',
    'MOUNTING READ_MEDIA_IMAGE SECTORS... OK',
    'LINKING GOOGLE ML_KIT TEXT ENGINE... OK',
    'INITIALIZING VOLATILE OCR MEMORY CACHE... OK',
    'SYS_STATUS: READY',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    )..addListener(() {
        setState(() {});
      });

    _controller.forward();
    _printConsoleLogs();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateToHome();
      }
    });
  }

  void _printConsoleLogs() {
    _logTimer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
      if (_logIndex < _sourceLogs.length) {
        setState(() {
          _consoleLogs.add(_sourceLogs[_logIndex]);
          _logIndex++;
        });
      } else {
        _logTimer?.cancel();
      }
    });
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _logTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progressVal = _progressAnimation.value;
    final percent = (progressVal * 100).toInt();
    
    const barWidth = 20;
    final filledBlocks = (progressVal * barWidth).round();
    final emptyBlocks = barWidth - filledBlocks;
    final progressBar = '[${'█' * filledBlocks}${'░' * emptyBlocks}]';

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingXL, vertical: AppConstants.spacingXL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              
              Center(
                child: Column(
                  children: [
                    Text(
                      'OCULAR',
                      style: AppTheme.displayLarge.copyWith(
                        color: AppTheme.green,
                        fontSize: 40,
                        letterSpacing: 8,
                        shadows: [
                          Shadow(
                            color: AppTheme.greenGlow,
                            blurRadius: 20,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'smart screenshot finder',
                      style: TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 11,
                        color: AppTheme.greenDim,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              Container(
                height: 140,
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                  border: Border.all(color: AppTheme.border, width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _consoleLogs.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Text(
                              _consoleLogs[index],
                              style: const TextStyle(
                                fontFamily: 'JetBrainsMono',
                                fontSize: 10,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          progressBar,
                          style: const TextStyle(
                            fontFamily: 'JetBrainsMono',
                            fontSize: 11,
                            color: AppTheme.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$percent%',
                          style: const TextStyle(
                            fontFamily: 'JetBrainsMono',
                            fontSize: 11,
                            color: AppTheme.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
