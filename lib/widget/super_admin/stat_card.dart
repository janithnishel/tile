// // lib/widget/admin_panel/stat_card.dart

// import 'package:flutter/material.dart';
// import 'package:tilework/theme/theme.dart';

// class StatCard extends StatefulWidget {
//   final String title;
//   final String value;
//   final IconData icon;
//   final Color color;
//   final String? subtitle;
//   final String? trend;
//   final bool isPositiveTrend;
//   final VoidCallback? onTap;

//   const StatCard({
//     Key? key,
//     required this.title,
//     required this.value,
//     required this.icon,
//     required this.color,
//     this.subtitle,
//     this.trend,
//     this.isPositiveTrend = true,
//     this.onTap,
//   }) : super(key: key);

//   @override
//   State<StatCard> createState() => _StatCardState();
// }

// class _StatCardState extends State<StatCard>
//     with SingleTickerProviderStateMixin {
//   bool _isHovered = false;
//   late AnimationController _controller;
//   late Animation<double> _scaleAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 200),
//       vsync: this,
//     );
//     _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeOut),
//     );
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MouseRegion(
//       onEnter: (_) {
//         setState(() => _isHovered = true);
//         _controller.forward();
//       },
//       onExit: (_) {
//         setState(() => _isHovered = false);
//         _controller.reverse();
//       },
//       child: AnimatedBuilder(
//         animation: _scaleAnimation,
//         builder: (context, child) {
//           return Transform.scale(
//             scale: _scaleAnimation.value,
//             child: child,
//           );
//         },
//         child: Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(20),
//             boxShadow: [
//               BoxShadow(
//                 color: widget.color.withOpacity(_isHovered ? 0.4 : 0.25),
//                 blurRadius: _isHovered ? 20 : 15,
//                 offset: Offset(0, _isHovered ? 10 : 8),
//                 spreadRadius: _isHovered ? 2 : 0,
//               ),
//             ],
//           ),
//           child: Material(
//             color: Colors.transparent,
//             child: InkWell(
//               onTap: widget.onTap,
//               borderRadius: BorderRadius.circular(20),
//               child: Container(
//                 padding: const EdgeInsets.all(24),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(20),
//                   gradient: LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                     colors: [
//                       widget.color,
//                       widget.color.withOpacity(0.8),
//                     ],
//                   ),
//                 ),
//                 child: Stack(
//                   children: [
//                     // Background Pattern
//                     Positioned(
//                       right: -20,
//                       top: -20,
//                       child: Container(
//                         width: 100,
//                         height: 100,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: Colors.white.withOpacity(0.1),
//                         ),
//                       ),
//                     ),
//                     Positioned(
//                       right: 20,
//                       bottom: -30,
//                       child: Container(
//                         width: 80,
//                         height: 80,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: Colors.white.withOpacity(0.08),
//                         ),
//                       ),
//                     ),

//                     // Content
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Icon & Trend Row
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             // Icon
//                             Container(
//                               padding: const EdgeInsets.all(12),
//                               decoration: BoxDecoration(
//                                 color: Colors.white.withOpacity(0.2),
//                                 borderRadius: BorderRadius.circular(14),
//                               ),
//                               child: Icon(
//                                 widget.icon,
//                                 color: Colors.white,
//                                 size: 26,
//                               ),
//                             ),

//                             // Trend Badge
//                             if (widget.trend != null)
//                               Container(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 10,
//                                   vertical: 5,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: Colors.white.withOpacity(0.2),
//                                   borderRadius: BorderRadius.circular(20),
//                                 ),
//                                 child: Row(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     Icon(
//                                       widget.isPositiveTrend
//                                           ? Icons.trending_up_rounded
//                                           : Icons.trending_down_rounded,
//                                       color: Colors.white,
//                                       size: 14,
//                                     ),
//                                     const SizedBox(width: 4),
//                                     Text(
//                                       widget.trend!,
//                                       style: const TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 12,
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                           ],
//                         ),

//                         const Spacer(),

//                         // Value
//                         Text(
//                           widget.value,
//                           style: const TextStyle(
//                             fontSize: 36,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                             height: 1.1,
//                           ),
//                         ),

//                         const SizedBox(height: 8),

//                         // Title
//                         Text(
//                           widget.title,
//                           style: TextStyle(
//                             fontSize: 15,
//                             fontWeight: FontWeight.w500,
//                             color: Colors.white.withOpacity(0.9),
//                           ),
//                         ),

//                         // Subtitle
//                         if (widget.subtitle != null) ...[
//                           const SizedBox(height: 4),
//                           Text(
//                             widget.subtitle!,
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Colors.white.withOpacity(0.7),
//                             ),
//                           ),
//                         ],
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════
// // 🎨 ALTERNATIVE - GLASS CARD STYLE
// // ═══════════════════════════════════════
// class GlassStatCard extends StatefulWidget {
//   final String title;
//   final String value;
//   final IconData icon;
//   final Color color;
//   final String? subtitle;
//   final double? progress;
//   final VoidCallback? onTap;

//   const GlassStatCard({
//     Key? key,
//     required this.title,
//     required this.value,
//     required this.icon,
//     required this.color,
//     this.subtitle,
//     this.progress,
//     this.onTap,
//   }) : super(key: key);

//   @override
//   State<GlassStatCard> createState() => _GlassStatCardState();
// }

// class _GlassStatCardState extends State<GlassStatCard> {
//   bool _isHovered = false;

//   @override
//   Widget build(BuildContext context) {
//     return MouseRegion(
//       onEnter: (_) => setState(() => _isHovered = true),
//       onExit: (_) => setState(() => _isHovered = false),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         transform: Matrix4.identity()..translate(0.0, _isHovered ? -5.0 : 0.0),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//             color: widget.color.withOpacity(_isHovered ? 0.3 : 0.1),
//             width: 2,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: widget.color.withOpacity(_isHovered ? 0.2 : 0.1),
//               blurRadius: _isHovered ? 20 : 10,
//               offset: Offset(0, _isHovered ? 10 : 5),
//             ),
//           ],
//         ),
//         child: Material(
//           color: Colors.transparent,
//           child: InkWell(
//             onTap: widget.onTap,
//             borderRadius: BorderRadius.circular(20),
//             child: Padding(
//               padding: const EdgeInsets.all(24),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Header Row
//                   Row(
//                     children: [
//                       // Icon Container
//                       Container(
//                         padding: const EdgeInsets.all(14),
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                             colors: [
//                               widget.color,
//                               widget.color.withOpacity(0.7),
//                             ],
//                           ),
//                           borderRadius: BorderRadius.circular(14),
//                           boxShadow: [
//                             BoxShadow(
//                               color: widget.color.withOpacity(0.3),
//                               blurRadius: 10,
//                               offset: const Offset(0, 4),
//                             ),
//                           ],
//                         ),
//                         child: Icon(
//                           widget.icon,
//                           color: Colors.white,
//                           size: 24,
//                         ),
//                       ),
//                       const Spacer(),

//                       // More Options
//                       Container(
//                         padding: const EdgeInsets.all(8),
//                         decoration: BoxDecoration(
//                           color: Colors.grey.shade100,
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: Icon(
//                           Icons.more_horiz,
//                           color: Colors.grey.shade500,
//                           size: 18,
//                         ),
//                       ),
//                     ],
//                   ),

//                   const Spacer(),

//                   // Value
//                   Text(
//                     widget.value,
//                     style: TextStyle(
//                       fontSize: 34,
//                       fontWeight: FontWeight.bold,
//                       color: AppTheme.textPrimary,
//                       height: 1.1,
//                     ),
//                   ),

//                   const SizedBox(height: 6),

//                   // Title
//                   Text(
//                     widget.title,
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.grey.shade600,
//                     ),
//                   ),

//                   // Progress Bar
//                   if (widget.progress != null) ...[
//                     const SizedBox(height: 16),
//                     Column(
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               widget.subtitle ?? 'Progress',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.grey.shade500,
//                               ),
//                             ),
//                             Text(
//                               '${(widget.progress! * 100).toInt()}%',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w600,
//                                 color: widget.color,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 8),
//                         Container(
//                           height: 6,
//                           decoration: BoxDecoration(
//                             color: Colors.grey.shade200,
//                             borderRadius: BorderRadius.circular(3),
//                           ),
//                           child: Align(
//                             alignment: Alignment.centerLeft,
//                             child: FractionallySizedBox(
//                               widthFactor: widget.progress!,
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   gradient: LinearGradient(
//                                     colors: [
//                                       widget.color,
//                                       widget.color.withOpacity(0.7),
//                                     ],
//                                   ),
//                                   borderRadius: BorderRadius.circular(3),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ] else if (widget.subtitle != null) ...[
//                     const SizedBox(height: 4),
//                     Row(
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 8,
//                             vertical: 3,
//                           ),
//                           decoration: BoxDecoration(
//                             color: widget.color.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(6),
//                           ),
//                           child: Text(
//                             widget.subtitle!,
//                             style: TextStyle(
//                               fontSize: 11,
//                               fontWeight: FontWeight.w600,
//                               color: widget.color,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════
// // 🎨 MINI STAT CARD
// // ═══════════════════════════════════════
// class MiniStatCard extends StatelessWidget {
//   final String title;
//   final String value;
//   final IconData icon;
//   final Color color;

//   const MiniStatCard({
//     Key? key,
//     required this.title,
//     required this.value,
//     required this.icon,
//     required this.color,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(icon, color: color, size: 20),
//           ),
//           const SizedBox(width: 12),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 value,
//                 style: const TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               Text(
//                 title,
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.grey.shade600,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

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
                        final isCompact = availableHeight < 180; // Detect if card is constrained

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
                                    padding: EdgeInsets.all(isCompact ? 10 : 14),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(isCompact ? 12 : 16),
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
                                      horizontal: _isHovered ? (isCompact ? 10 : 14) : (isCompact ? 8 : 12),
                                      vertical: _isHovered ? (isCompact ? 6 : 8) : (isCompact ? 4 : 6),
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

                            SizedBox(height: isCompact ? 8 : 16), // Smaller spacing in compact mode

                            // Value (smaller font in compact mode)
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: TextStyle(
                                fontSize: _isHovered ? (isCompact ? 32 : 42) : (isCompact ? 28 : 38),
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.1,
                                letterSpacing: -1,
                              ),
                              child: Text(widget.value),
                            ),

                            SizedBox(height: isCompact ? 4 : 8), // Smaller spacing in compact mode

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
