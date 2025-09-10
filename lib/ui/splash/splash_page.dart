import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/ui/theme/app_colors.dart';
import '/viewmodels/splash/splash_viewmodel.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {
  late final SplashViewModel vm;
  late final AnimationController _fadeCtrl;
  late final AnimationController _breathCtrl;
  late final AnimationController _bgCtrl;

  late final Animation<double> _fadeIn;
  late final Animation<double> _scalePulse;
  late final Animation<Alignment> _alignAnimA;
  late final Animation<Alignment> _alignAnimB;

  @override
  void initState() {
    super.initState();

    vm = Get.put(SplashViewModel());

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _breathCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
      lowerBound: 0.0,
      upperBound: 1.0,
    )..repeat(reverse: true);

    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _fadeIn = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOutCubic);

    _scalePulse = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.96, end: 1.04), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.04, end: 0.98), weight: 50),
    ]).animate(CurvedAnimation(parent: _breathCtrl, curve: Curves.easeInOut));

    _alignAnimA = AlignmentTween(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).animate(CurvedAnimation(parent: _bgCtrl, curve: Curves.easeInOut));

    _alignAnimB = AlignmentTween(
      begin: Alignment.bottomRight,
      end: Alignment.topLeft,
    ).animate(CurvedAnimation(parent: _bgCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _breathCtrl.dispose();
    _bgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final logoSize = min(size.width, size.height) * 0.38;

    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_bgCtrl, _breathCtrl, _fadeCtrl]),
        builder: (_, __) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: _alignAnimA.value,
                end: _alignAnimB.value,
                colors: const [
                  AppColors.gradient1,
                  AppColors.gradient2,
                  AppColors.gradient3,
                ],
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Brilho radial sutil atrás da logo
                Opacity(
                  opacity: 0.18,
                  child: Container(
                    width: logoSize * 4.0,
                    height: logoSize * 4.0,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white,
                          blurRadius: 120,
                          spreadRadius: 24,
                        )
                      ],
                    ),
                  ),
                ),

                FadeTransition(
                  opacity: _fadeIn,
                  child: Transform.scale(
                    scale: _scalePulse.value,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/logo.png',
                          width: logoSize,
                          height: logoSize,
                        ),
                        const SizedBox(height: 40),
                        const Text(
                          'Atmus',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Indicador discreto
                Positioned(
                  bottom: size.height * 0.12,
                  child: Opacity(
                    opacity: 0.85,
                    child: SizedBox(
                      width: 36,
                      height: 36,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
