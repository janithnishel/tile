// lib/widget/admin_panel/stat_card.dart

import 'package:flutter/material.dart';

class StatCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final String? trend;
  final bool isPositiveTrend;
  final VoidCallback? onTap;

  const StatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
    this.trend,
    this.isPositiveTrend = true,
    this.onTap,
  }) : super(key: key);

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _iconRotateAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _iconRotateAnimation = Tween<double>(begin: 0.0, end: 0.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _animationController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _animationController.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              // Main colored shadow
              BoxShadow(
                color: widget.color.withOpacity(_isHovered ? 0.45 : 0.3),
                blurRadius: _isHovered ? 30 : 20,
                offset: Offset(0, _isHovered ? 15 : 10),
                spreadRadius: _isHovered ? 0 : -5,
              ),
              // Subtle dark shadow for depth
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.color,
                      Color.lerp(widget.color, Colors.black, 0.15)!,
                    ],
                  ),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // ═══════════════════════════════════════
                    // 🎨 BACKGROUND DECORATIONS
                    // ═══════════════════════════════════════

                    // Large circle - top right
                    Positioned(
                      right: -30,
                      top: -30,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: _isHovered ? 120 : 100,
                        height: _isHovered ? 120 : 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(
                            _isHovered ? 0.15 : 0.1,
                          ),
                        ),
                      ),
                    ),

                    // Medium circle - bottom right
                    Positioned(
                      right: 30,
                      bottom: -40,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: _isHovered ? 90 : 70,
                        height: _isHovered ? 90 : 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(
                            _isHovered ? 0.1 : 0.06,
                          ),
                        ),
                      ),
                    ),

                    // Small circle - left
                    Positioned(
                      left: -20,
                      bottom: 20,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: _isHovered ? 50 : 40,
                        height: _isHovered ? 50 : 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                    ),

                    // ═══════════════════════════════════════
                    // 📝 CONTENT
                    // ═══════════════════════════════════════
                    LayoutBuilder(
                      builder: (context, constraints) {
                        // Adjust content based on available height
                        final availableHeight = constraints.maxHeight;
                        final isCompact =
                            availableHeight <
                            180; // Detect if card is constrained

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Row - Icon & Trend
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Icon Container (smaller in compact mode)
                                AnimatedBuilder(
                                  animation: _iconRotateAnimation,
                                  builder: (context, child) {
                                    return Transform.rotate(
                                      angle: _iconRotateAnimation.value,
                                      child: child,
                                    );
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(
                                      isCompact ? 10 : 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(
                                        isCompact ? 12 : 16,
                                      ),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.1),
                                        width: 1,
                                      ),
                                    ),
                                    child: Icon(
                                      widget.icon,
                                      color: Colors.white,
                                      size: isCompact ? 20 : 28,
                                    ),
                                  ),
                                ),

                                // Trend Badge (smaller in compact mode)
                                if (widget.trend != null)
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: _isHovered
                                          ? (isCompact ? 10 : 14)
                                          : (isCompact ? 8 : 12),
                                      vertical: _isHovered
                                          ? (isCompact ? 6 : 8)
                                          : (isCompact ? 4 : 6),
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(
                                        _isHovered ? 0.25 : 0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          widget.isPositiveTrend
                                              ? Icons.trending_up_rounded
                                              : Icons.trending_down_rounded,
                                          color: Colors.white,
                                          size: isCompact ? 12 : 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          widget.trend!,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: isCompact ? 11 : 13,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),

                            SizedBox(
                              height: isCompact ? 8 : 16,
                            ), // Smaller spacing in compact mode
                            // Value (smaller font in compact mode)
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: TextStyle(
                                fontSize: _isHovered
                                    ? (isCompact ? 32 : 42)
                                    : (isCompact ? 28 : 38),
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.1,
                                letterSpacing: -1,
                              ),
                              child: Text(widget.value),
                            ),

                            SizedBox(
                              height: isCompact ? 4 : 8,
                            ), // Smaller spacing in compact mode
                            // Title (smaller font in compact mode)
                            Text(
                              widget.title,
                              style: TextStyle(
                                fontSize: isCompact ? 13 : 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.95),
                                letterSpacing: 0.3,
                              ),
                            ),

                            // Subtitle (smaller in compact mode)
                            if (widget.subtitle != null) ...[
                              SizedBox(height: isCompact ? 4 : 6),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isCompact ? 8 : 10,
                                  vertical: isCompact ? 3 : 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  widget.subtitle!,
                                  style: TextStyle(
                                    fontSize: isCompact ? 10 : 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),

                    // ═══════════════════════════════════════
                    // ✨ SHINE EFFECT ON HOVER
                    // ═══════════════════════════════════════
                    if (_isHovered)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withOpacity(0.15),
                                Colors.white.withOpacity(0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════
// 📊 DUAL STAT CARD (Items & Services)
// ═══════════════════════════════════════

class DualStatCard extends StatefulWidget {
  final String leftTitle;
  final String leftValue;
  final IconData leftIcon;
  final Color leftColor;
  final String rightTitle;
  final String rightValue;
  final IconData rightIcon;
  final Color rightColor;
  final String? subtitle;
  final VoidCallback? onTap;

  const DualStatCard({
    Key? key,
    required this.leftTitle,
    required this.leftValue,
    required this.leftIcon,
    required this.leftColor,
    required this.rightTitle,
    required this.rightValue,
    required this.rightIcon,
    required this.rightColor,
    this.subtitle,
    this.onTap,
  }) : super(key: key);

  @override
  State<DualStatCard> createState() => _DualStatCardState();
}

class _DualStatCardState extends State<DualStatCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _animationController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _animationController.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: widget.leftColor.withOpacity(_isHovered ? 0.45 : 0.3),
                blurRadius: _isHovered ? 30 : 20,
                offset: Offset(0, _isHovered ? 15 : 10),
                spreadRadius: _isHovered ? 0 : -5,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.leftColor,
                      Color.lerp(widget.leftColor, Colors.black, 0.15)!,
                    ],
                  ),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // ═══════════════════════════════════════
                    // 🎨 BACKGROUND DECORATIONS
                    // ═══════════════════════════════════════

                    Positioned(
                      right: -30,
                      top: -30,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: _isHovered ? 120 : 100,
                        height: _isHovered ? 120 : 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(
                            _isHovered ? 0.15 : 0.1,
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      right: 30,
                      bottom: -40,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: _isHovered ? 90 : 70,
                        height: _isHovered ? 90 : 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(
                            _isHovered ? 0.1 : 0.06,
                          ),
                        ),
                      ),
                    ),

                    // ═══════════════════════════════════════
                    // 📝 CONTENT - TWO COLUMNS
                    // ═══════════════════════════════════════
                    Row(
                      children: [
                        // Left Column - Items
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Icon
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.1),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  widget.leftIcon,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Value
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: TextStyle(
                                  fontSize: _isHovered ? 32 : 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1.1,
                                  letterSpacing: -1,
                                ),
                                child: Text(widget.leftValue),
                              ),

                              const SizedBox(height: 4),

                              // Title
                              Text(
                                widget.leftTitle,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Divider
                        Container(
                          width: 1,
                          height: 80,
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          color: Colors.white.withOpacity(0.3),
                        ),

                        // Right Column - Services
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Icon
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.1),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  widget.rightIcon,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Value
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: TextStyle(
                                  fontSize: _isHovered ? 32 : 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1.1,
                                  letterSpacing: -1,
                                ),
                                child: Text(widget.rightValue),
                              ),

                              const SizedBox(height: 4),

                              // Title
                              Text(
                                widget.rightTitle,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Subtitle at bottom (optional)
                    if (widget.subtitle != null)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(24),
                            ),
                          ),
                          child: Text(
                            widget.subtitle!,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.9),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),

                    // ═══════════════════════════════════════
                    // ✨ SHINE EFFECT ON HOVER
                    // ═══════════════════════════════════════
                    if (_isHovered)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withOpacity(0.15),
                                Colors.white.withOpacity(0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
