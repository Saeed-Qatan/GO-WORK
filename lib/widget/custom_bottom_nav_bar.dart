import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../core/constants/app_constants.dart';

/// A premium floating glassmorphism bottom navigation bar.
///
/// Design:
/// - A frosted-glass pill floats above the app background with a colored shadow.
/// - A gradient indicator rect slides smoothly between the active tab (280ms cubic).
/// - Active tab: white icon + white label (on top of the colored indicator).
/// - Inactive tab: soft grey icon + grey label.
/// - Icon pops with an elastic scale spring on selection.
/// - Haptic selection click fires on every tap.
class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const List<_NavItem> _items = [
    _NavItem(
      icon: Icons.space_dashboard_outlined,
      activeIcon: Icons.space_dashboard_rounded,
      label: AppConstants.navHome,
    ),
    _NavItem(
      icon: Icons.search_rounded,
      activeIcon: Icons.manage_search_rounded,
      label: AppConstants.navSearch,
    ),
    _NavItem(
      icon: Icons.description_outlined,
      activeIcon: Icons.description_rounded,
      label: AppConstants.navApplications,
    ),
    _NavItem(
      icon: Icons.calendar_month_outlined,
      activeIcon: Icons.calendar_month_rounded,
      label: AppConstants.navInterviews,
    ),
    _NavItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings_rounded,
      label: AppConstants.navSettings,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // The outer container matches the app's body background so the pill
    // appears to float above the screen content.
    return Container(
      color: const Color(0xFFF5F5F5),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: _buildFloatingPill(),
        ),
      ),
    );
  }

  Widget _buildFloatingPill() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
        child: Container(
          height: 66,
          decoration: BoxDecoration(
            // Slightly more transparent for a deeper glass effect
            color: Colors.white.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(36),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.9),
              width: 1.0,
            ),
            boxShadow: [
              // Premium, ultra-soft brand-colored glow
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.12),
                blurRadius: 40,
                spreadRadius: 4,
                offset: const Offset(0, 12),
              ),
              // Subtle dark shadow for depth
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 24,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double itemWidth = constraints.maxWidth / _items.length;
              return Stack(
                alignment: Alignment.center,
                children: [
                  // ── Sliding circular indicator ──────────────────────────
                  // Uses AnimatedPositionedDirectional to support RTL languages (Arabic).
                  AnimatedPositionedDirectional(
                    duration: const Duration(milliseconds: 400),
                    curve:
                        Curves.fastLinearToSlowEaseIn, // Apple-like fluid snap
                    start:
                        (itemWidth * currentIndex) +
                        (itemWidth / 2) -
                        20, // Center 40px circle
                    top: 6, // Centered perfectly behind the icon (not the text)
                    width: 40,
                    height: 40,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withValues(alpha: 0.80),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.50),
                            blurRadius: 16,
                            spreadRadius: 0,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Tab items (rendered above the indicator) ────────────
                  Row(
                    children: List.generate(_items.length, (index) {
                      return Expanded(
                        child: _NavTabItem(
                          item: _items[index],
                          isSelected: currentIndex == index,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            onTap(index);
                          },
                        ),
                      );
                    }),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual tab item
// ─────────────────────────────────────────────────────────────────────────────

/// Renders a single tab: icon on top, label below.
///
/// Selected:   white icon + white label (sits on gradient indicator).
/// Unselected: grey icon  + grey label.
/// On selection: icon plays an elastic scale spring (1.0 → 1.3 → 1.0).
class _NavTabItem extends StatefulWidget {
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavTabItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_NavTabItem> createState() => _NavTabItemState();
}

class _NavTabItemState extends State<_NavTabItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // High-quality fluid spring pop using TweenSequence
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.25,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.25,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 70,
      ),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(_NavTabItem old) {
    super.didUpdateWidget(old);
    if (widget.isSelected && !old.isSelected) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Icon sits inside the blue circle when selected.
    final Color iconColor = widget.isSelected
        ? Colors.white
        : const Color(0xFF9E9E9E);

    // Text sits below the circle, so it needs to be primary colored when selected.
    final Color textColor = widget.isSelected
        ? AppColors.primary
        : const Color(0xFF9E9E9E);

    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 66,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Elastic icon pop
            AnimatedBuilder(
              animation: _scaleAnim,
              builder: (context, child) {
                return Transform.scale(scale: _scaleAnim.value, child: child);
              },
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (child, anim) =>
                    FadeTransition(opacity: anim, child: child),
                child: Icon(
                  widget.isSelected ? widget.item.activeIcon : widget.item.icon,
                  key: ValueKey<bool>(widget.isSelected),
                  size: 22,
                  color: iconColor,
                ),
              ),
            ),
            const SizedBox(height: 3),
            // Animated label color
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              style: Theme.of(context).textTheme.labelSmall!.copyWith(
                fontSize: 10,
                fontWeight: widget.isSelected
                    ? FontWeight.w700
                    : FontWeight.w400,
                color: textColor,
                letterSpacing: 0.1,
              ),
              child: Text(
                widget.item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data model
// ─────────────────────────────────────────────────────────────────────────────

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
