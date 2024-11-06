import 'package:flutter/material.dart';

class CustomBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final Color color1;
  final Color color2;

  const CustomBottomBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.color1,
    required this.color2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: color1.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomAppBar(
        elevation: 0,
        color: Colors.transparent,
        notchMargin: 8,
        shape: const CircularNotchedRectangle(),
        child: Container(
          height: 65,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_rounded,
                label: "Ana Sayfa",
                index: 0,
              ),
              _buildNavItem(
                icon: Icons.book_rounded,
                label: "Materyallerim",
                index: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: isSelected
              ? LinearGradient(
                  colors: [color1, color2],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : color1.withOpacity(0.7),
                size: 24,
              ),
              if (isSelected) ...[
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
