import 'package:flutter/material.dart';

class CustomSearchHeader extends StatelessWidget {
  final VoidCallback? onBackTap;
  final VoidCallback? onFilterTap;
  final ValueChanged<String>? onSearchChanged;
  final TextEditingController? searchController;

  const CustomSearchHeader({
    super.key,
    this.onBackTap,
    this.onFilterTap,
    this.onSearchChanged,
    this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2962FF), Color(0xFF448AFF)], // Blue Gradient
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Navigation Row
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_forward, color: Colors.white),
                  onPressed: onBackTap ?? () => Navigator.maybePop(context),
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
              ),
              const Expanded(
                child: Text(
                  'البحث عن وظائف',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo', // Assuming font usage or standard
                  ),
                ),
              ),
              // Empty container to balance the back button
              const SizedBox(width: 40),
            ],
          ),
          const SizedBox(height: 24),

          // Search Row
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.grey, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          onChanged: onSearchChanged,
                          style: const TextStyle(fontSize: 16),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'ابحث عن وظيفة أو شركة...',
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Filter Button (Full width or under?)
          // Screenshot usually shows filter as a smaller button.
          // Let's add the Filter Button ALIGNED LEFT (Start) explicitly as requested "componnets".
          // If the search bar takes full width, maybe filter is below?
          // Let's assume Filter is below Search Bar aligned to the Start (Left in LTR, Right in RTL).
          // Actually, standard is: Search Bar | Filter Button.
          // Let's try putting Filter Button distinctively.
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: InkWell(
              onTap: onFilterTap,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.tune, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'فلترة', // Filter
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
