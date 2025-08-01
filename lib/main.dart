import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;

void main() {
  runApp(const NafasApp());
}

class NafasApp extends StatelessWidget {
  const NafasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nafas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E8B7D),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.w300,
            letterSpacing: -1.0,
          ),
          displayMedium: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.5,
          ),
          headlineLarge: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.25,
          ),
          headlineMedium: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w500,
            letterSpacing: 0,
          ),
          titleLarge: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w500,
            letterSpacing: 0,
          ),
          titleMedium: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.15,
          ),
          bodyLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
          ),
          bodyMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.25,
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class BreathingTechnique {
  final String nameAr;
  final String nameEn;
  final String descriptionAr;
  final List<int> phaseDurations;
  final List<String> phaseNamesAr;
  final Color primaryColor;
  final Color secondaryColor;
  final IconData icon;
  final String backgroundImage;
  final List<Color> gradientColors;

  BreathingTechnique({
    required this.nameAr,
    required this.nameEn,
    required this.descriptionAr,
    required this.phaseDurations,
    required this.phaseNamesAr,
    required this.primaryColor,
    required this.secondaryColor,
    required this.icon,
    required this.backgroundImage,
    required this.gradientColors,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _breathingAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  bool _isBreathing = false;
  int _currentPhase = 0;
  int _currentTime = 0;
  int _sessionDuration = 0;
  int _completedCycles = 0;
  Timer? _timer;
  int _selectedTechniqueIndex = 0;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  final List<BreathingTechnique> _techniques = [
    BreathingTechnique(
      nameAr: 'تنفس الاسترخاء',
      nameEn: '4-4-6-2 Relaxation',
      descriptionAr: 'تقنية مهدئة للاسترخاء وتقليل التوتر',
      phaseDurations: [4, 4, 6, 2],
      phaseNamesAr: ['استنشاق', 'احتفظ', 'زفير', 'احتفظ'],
      primaryColor: const Color(0xFF2E8B7D),
      secondaryColor: const Color(0xFF4FD1C7),
      icon: Icons.spa_outlined,
      backgroundImage: 'ocean_waves',
      gradientColors: [Color(0xFF2E8B7D), Color(0xFF4FD1C7), Color(0xFF81E6D9)],
    ),
    BreathingTechnique(
      nameAr: 'تنفس التركيز',
      nameEn: '4-7-8 Focus',
      descriptionAr: 'لتحسين التركيز والهدوء الذهني',
      phaseDurations: [4, 7, 8, 0],
      phaseNamesAr: ['استنشاق', 'احتفظ', 'زفير', ''],
      primaryColor: const Color(0xFF6366F1),
      secondaryColor: const Color(0xFF8B5CF6),
      icon: Icons.psychology_outlined,
      backgroundImage: 'mountain_mist',
      gradientColors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFA78BFA)],
    ),
    BreathingTechnique(
      nameAr: 'تنفس الطاقة',
      nameEn: '6-2-6-2 Energy',
      descriptionAr: 'لزيادة الطاقة والحيوية',
      phaseDurations: [6, 2, 6, 2],
      phaseNamesAr: ['استنشاق', 'احتفظ', 'زفير', 'احتفظ'],
      primaryColor: const Color(0xFFEF4444),
      secondaryColor: const Color(0xFFF97316),
      icon: Icons.bolt_outlined,
      backgroundImage: 'sunrise_energy',
      gradientColors: [Color(0xFFEF4444), Color(0xFFF97316), Color(0xFFFBBF24)],
    ),
    BreathingTechnique(
      nameAr: 'تنفس عميق',
      nameEn: '5-5-5-5 Deep',
      descriptionAr: 'تنفس عميق ومتوازن للاستقرار',
      phaseDurations: [5, 5, 5, 5],
      phaseNamesAr: ['استنشاق', 'احتفظ', 'زفير', 'احتفظ'],
      primaryColor: const Color(0xFF059669),
      secondaryColor: const Color(0xFF10B981),
      icon: Icons.air_outlined,
      backgroundImage: 'forest_deep',
      gradientColors: [Color(0xFF059669), Color(0xFF10B981), Color(0xFF34D399)],
    ),
  ];

  @override
  void initState() {
    super.initState();

    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    _breathingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  BreathingTechnique get _currentTechnique =>
      _techniques[_selectedTechniqueIndex];

  void _vibrate() {
    if (_vibrationEnabled) {
      try {
        HapticFeedback.selectionClick();
      } catch (e) {
        // Fallback if haptic feedback fails
        print('Haptic feedback not available: $e');
      }
    }
  }

  void _startBreathing() {
    if (_isBreathing) return;

    setState(() {
      _isBreathing = true;
      _currentPhase = 0;
      _currentTime = 0;
      _sessionDuration = 0;
      _completedCycles = 0;
    });

    _startBreathingCycle();
  }

  void _stopBreathing() {
    setState(() {
      _isBreathing = false;
      _currentPhase = 0;
      _currentTime = 0;
    });

    _timer?.cancel();
    _breathingController.reset();
    _breathingController.duration = Duration(
      seconds: _currentTechnique.phaseDurations[0],
    );
  }

  void _startBreathingCycle() {
    _timer?.cancel();
    final technique = _currentTechnique;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isBreathing) {
        timer.cancel();
        return;
      }

      setState(() {
        _currentTime++;
        _sessionDuration++;
      });

      if (_currentTime >= technique.phaseDurations[_currentPhase]) {
        _currentTime = 0;

        if (_currentPhase == 0) {
          // Start inhale
          _breathingController.duration = Duration(
            seconds: technique.phaseDurations[0],
          );
          _breathingController.forward();
          _vibrate();
        } else if (_currentPhase == 1) {
          // Hold after inhale - keep the circle expanded
          _breathingController.duration = Duration(
            seconds: technique.phaseDurations[1],
          );
        } else if (_currentPhase == 2) {
          // Start exhale
          _breathingController.duration = Duration(
            seconds: technique.phaseDurations[2],
          );
          _breathingController.reverse();
          _vibrate();
        } else if (_currentPhase == 3) {
          // Hold after exhale - keep the circle contracted
          _breathingController.duration = Duration(
            seconds: technique.phaseDurations[3],
          );
        }

        _currentPhase = (_currentPhase + 1) % technique.phaseDurations.length;

        if (_currentPhase == 0) {
          _completedCycles++;
        }
      }
    });

    // Start the first inhale
    _breathingController.duration = Duration(
      seconds: technique.phaseDurations[0],
    );
    _breathingController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final isTablet = screenWidth > 600;
    final isLandscape = screenWidth > screenHeight;
    final safeAreaHeight =
        screenHeight -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;

    // Responsive sizing with overlap prevention
    final maxCircleSize = isLandscape
        ? safeAreaHeight * 0.4
        : safeAreaHeight * 0.35;
    final circleSize = isTablet
        ? (isLandscape
              ? math.min(screenHeight * 0.35, maxCircleSize)
              : math.min(screenWidth * 0.45, maxCircleSize))
        : math.min(screenWidth * 0.55, maxCircleSize);
    final buttonSize = isTablet ? 100.0 : 80.0;
    final headerPadding = isTablet ? 24.0 : 16.0;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _currentTechnique.gradientColors,
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withOpacity(0.9),
                Colors.white.withOpacity(0.7),
                Colors.transparent,
              ],
              stops: const [0.0, 0.3, 1.0],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(headerPadding, isTablet),

                // Technique Selector
                _buildTechniqueSelector(isTablet),

                // Main breathing area
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: safeAreaHeight * 0.6,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Session Stats
                            if (_isBreathing) ...[
                              _buildSessionStats(isTablet),
                              SizedBox(height: isTablet ? 16 : 8),
                            ],

                            // Breathing circle
                            Flexible(
                              child: _buildBreathingCircle(
                                circleSize,
                                isTablet,
                              ),
                            ),

                            SizedBox(height: isTablet ? 24 : 16),

                            // Start/Stop button
                            _buildActionButton(buttonSize, isTablet),

                            SizedBox(height: isTablet ? 16 : 12),

                            // Instructions
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: isTablet ? 32 : 16,
                              ),
                              child: _buildInstructions(isTablet),
                            ),

                            SizedBox(height: isTablet ? 24 : 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double padding, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.9),
            Colors.white.withOpacity(0.7),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: _currentTechnique.primaryColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(isTablet ? 12 : 8),
                    decoration: BoxDecoration(
                      color: _currentTechnique.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.air,
                      color: _currentTechnique.primaryColor,
                      size: isTablet ? 32 : 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Nafas',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: const Color(0xFF1A202C),
                      fontWeight: FontWeight.w300,
                      fontSize: isTablet ? 56 : 48,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'تنفس بوعي واسترخاء',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF4A5568),
                  fontSize: isTablet ? 26 : 22,
                ),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _soundEnabled = !_soundEnabled;
                  });
                  _vibrate();
                },
                child: Container(
                  padding: EdgeInsets.all(isTablet ? 16 : 12),
                  decoration: BoxDecoration(
                    color: _soundEnabled
                        ? _currentTechnique.primaryColor.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _soundEnabled ? Icons.volume_up : Icons.volume_off,
                    color: _soundEnabled
                        ? _currentTechnique.primaryColor
                        : Colors.grey,
                    size: isTablet ? 28 : 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _vibrationEnabled = !_vibrationEnabled;
                  });
                  if (_vibrationEnabled) _vibrate();
                },
                child: Container(
                  padding: EdgeInsets.all(isTablet ? 16 : 12),
                  decoration: BoxDecoration(
                    color: _vibrationEnabled
                        ? _currentTechnique.primaryColor.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _vibrationEnabled ? Icons.vibration : Icons.phonelink_erase,
                    color: _vibrationEnabled
                        ? _currentTechnique.primaryColor
                        : Colors.grey,
                    size: isTablet ? 28 : 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTechniqueSelector(bool isTablet) {
    return Container(
      height: isTablet ? 120 : 90,
      margin: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 8),
        itemCount: _techniques.length,
        itemBuilder: (context, index) {
          final technique = _techniques[index];
          final isSelected = index == _selectedTechniqueIndex;

          return GestureDetector(
            onTap: () {
              if (!_isBreathing) {
                setState(() {
                  _selectedTechniqueIndex = index;
                });
              }
            },
            child: Container(
              width: isTablet ? 160 : 120,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: EdgeInsets.all(isTablet ? 12 : 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? technique.primaryColor
                    : Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : technique.primaryColor.withOpacity(0.2),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? technique.primaryColor.withOpacity(0.3)
                        : Colors.black.withOpacity(0.1),
                    blurRadius: isSelected ? 15 : 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    technique.icon,
                    color: isSelected ? Colors.white : technique.primaryColor,
                    size: isTablet ? 28 : 20,
                  ),
                  SizedBox(height: isTablet ? 6 : 4),
                  Flexible(
                    child: Text(
                      technique.nameAr,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : technique.primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: isTablet ? 16 : 12,
                      ),
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: isTablet ? 4 : 2),
                  Flexible(
                    child: Text(
                      technique.descriptionAr,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white.withOpacity(0.8)
                            : const Color(0xFF718096),
                        fontSize: isTablet ? 14 : 10,
                      ),
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSessionStats(bool isTablet) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isTablet ? 48 : 24),
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 32 : 20,
        vertical: isTablet ? 16 : 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _currentTechnique.primaryColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: _buildStatItem(
                'الوقت',
                '${_sessionDuration ~/ 60}:${(_sessionDuration % 60).toString().padLeft(2, '0')}',
                isTablet,
              ),
            ),
            Container(
              width: 1,
              height: isTablet ? 40 : 30,
              color: Colors.grey.shade300,
              margin: EdgeInsets.symmetric(horizontal: 16),
            ),
            Expanded(
              child: _buildStatItem('الدورات', '$_completedCycles', isTablet),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, bool isTablet) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              fontSize: isTablet ? 28 : 20,
              fontWeight: FontWeight.w600,
              color: _currentTechnique.primaryColor,
            ),
          ),
        ),
        SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: TextStyle(
              fontSize: isTablet ? 20 : 14,
              color: const Color(0xFF718096),
            ),
            textDirection: TextDirection.rtl,
          ),
        ),
      ],
    );
  }

  Widget _buildBreathingCircle(double circleSize, bool isTablet) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _breathingAnimation,
        _pulseAnimation,
        _rotationAnimation,
      ]),
      builder: (context, child) {
        final breathingScale = 0.7 + (_breathingAnimation.value * 0.3);
        final pulseScale = 1.0 + (_pulseAnimation.value * 0.03);
        final finalScale = breathingScale * pulseScale;

        return Transform.rotate(
          angle: _rotationAnimation.value * 0.1,
          child: Transform.scale(
            scale: finalScale,
            child: Container(
              width: circleSize,
              height: circleSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(-0.3, -0.3),
                  colors: [
                    _currentTechnique.secondaryColor.withOpacity(0.9),
                    _currentTechnique.primaryColor,
                    _currentTechnique.primaryColor.withOpacity(0.8),
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: _currentTechnique.primaryColor.withOpacity(0.4),
                    blurRadius: 50,
                    spreadRadius: 10,
                  ),
                  BoxShadow(
                    color: _currentTechnique.secondaryColor.withOpacity(0.2),
                    blurRadius: 100,
                    spreadRadius: 20,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Animated particles
                  ...List.generate(6, (index) {
                    final angle = (index * 60.0) * (math.pi / 180);
                    final distance =
                        25.0 + (math.sin(_rotationAnimation.value * 2) * 6);
                    return Positioned(
                      left:
                          (circleSize / 2) +
                          (math.cos(angle + _rotationAnimation.value) *
                              distance) -
                          3,
                      top:
                          (circleSize / 2) +
                          (math.sin(angle + _rotationAnimation.value) *
                              distance) -
                          3,
                      child: Container(
                        width: isTablet ? 8 : 6,
                        height: isTablet ? 8 : 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.3),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  // Animated border
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 3,
                      ),
                    ),
                  ),
                  // Inner circle
                  Center(
                    child: Container(
                      width: circleSize * 0.67,
                      height: circleSize * 0.67,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.95),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _currentTechnique.icon,
                              size: isTablet ? 32 : 22,
                              color: _currentTechnique.primaryColor,
                            ),
                            SizedBox(height: isTablet ? 8 : 4),
                            Text(
                              _currentTechnique.phaseNamesAr[_currentPhase <
                                      _currentTechnique.phaseNamesAr.length
                                  ? _currentPhase
                                  : 0],
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    color: const Color(0xFF1A202C),
                                    fontWeight: FontWeight.w600,
                                    fontSize: isTablet ? 24 : 16,
                                  ),
                              textDirection: TextDirection.rtl,
                            ),
                            SizedBox(height: isTablet ? 4 : 2),
                            Text(
                              '${_currentTechnique.phaseDurations[_currentPhase < _currentTechnique.phaseDurations.length ? _currentPhase : 0] - _currentTime}',
                              style: Theme.of(context).textTheme.displayMedium
                                  ?.copyWith(
                                    color: _currentTechnique.primaryColor,
                                    fontWeight: FontWeight.w300,
                                    fontSize: isTablet ? 36 : 24,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton(double buttonSize, bool isTablet) {
    return GestureDetector(
      onTap: _isBreathing ? _stopBreathing : _startBreathing,
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _isBreathing
                ? [const Color(0xFFEF4444), const Color(0xFFDC2626)]
                : [
                    _currentTechnique.primaryColor,
                    _currentTechnique.secondaryColor,
                  ],
          ),
          boxShadow: [
            BoxShadow(
              color:
                  (_isBreathing
                          ? const Color(0xFFEF4444)
                          : _currentTechnique.primaryColor)
                      .withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Icon(
          _isBreathing ? Icons.stop : Icons.play_arrow,
          color: Colors.white,
          size: isTablet ? 48 : 32,
        ),
      ),
    );
  }

  Widget _buildInstructions(bool isTablet) {
    return Column(
      children: [
        Text(
          _isBreathing ? 'اضغط للتوقف' : 'اضغط لبدء جلسة التنفس',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: const Color(0xFF4A5568),
            fontSize: isTablet ? 24 : 18,
            fontWeight: FontWeight.w500,
          ),
          textDirection: TextDirection.rtl,
        ),
        if (!_isBreathing) ...[
          const SizedBox(height: 8),
          Text(
            _currentTechnique.descriptionAr,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF718096),
              fontSize: isTablet ? 22 : 16,
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          ),
        ],
      ],
    );
  }
}
