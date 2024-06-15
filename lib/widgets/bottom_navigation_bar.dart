import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BottomNavigationBarWidget extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final VoidCallback onAddButtonPressed;
  final bool isProfileScreen;

  const BottomNavigationBarWidget({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.onAddButtonPressed,
    this.isProfileScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color activeColor = Theme.of(context).colorScheme.primary;
    const Color inactiveColor = Colors.white;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Colors.white,
                width: 2.0,
              ),
            ),
          ),
          child: BottomAppBar(
            notchMargin: 6.0,
            color: Theme.of(context).colorScheme.surface,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: isProfileScreen
                  ? buildProfileTab(context)
                  : buildMainTab(context, activeColor, inactiveColor),
            ),
          ),
        ),
        if (isProfileScreen)
          Positioned(
            top: -28,
            left: MediaQuery.of(context).size.width / 2 - 28,
            child: ClipOval(
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(400),
                ),
                child: FloatingActionButton(
                  onPressed: () => onItemTapped(1),
                  backgroundColor: Colors.transparent,
                  elevation: 0.0,
                  child: const Icon(
                    Icons.home,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget buildMainTab(
      BuildContext context, Color activeColor, Color inactiveColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        buildTabItem(
          context,
          index: 0,
          icon: 'lib/assets/icons/astronaut.svg',
          label: 'Compte',
          isActive: selectedIndex == 0,
          activeColor: activeColor,
          inactiveColor: inactiveColor,
        ),
        const SizedBox(width: 65),
        buildTabItem(
          context,
          index: 1,
          icon: 'lib/assets/icons/rocket.svg',
          label: 'Event',
          isActive: selectedIndex == 1,
          activeColor: activeColor,
          inactiveColor: inactiveColor,
        ),
      ],
    );
  }

  Widget buildProfileTab(BuildContext context) {
    return Container(
      height: kBottomNavigationBarHeight,
      alignment: Alignment.center,
    );
  }

  Widget buildTabItem(BuildContext context,
      {required int index,
      required String icon,
      required String label,
      required bool isActive,
      required Color activeColor,
      required Color inactiveColor}) {
    return Expanded(
      child: InkWell(
        onTap: () => onItemTapped(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              icon,
              width: 24,
              height: 24,
              color: isActive ? activeColor : inactiveColor,
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isActive ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
