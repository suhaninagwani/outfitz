import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/ornaments.dart';
import 'features/home/presentation/home_page.dart';
import 'features/onboarding/presentation/onboarding_page.dart';
import 'features/planner/presentation/planner_page.dart';
import 'features/splash/presentation/splash_page.dart';
import 'features/wardrobe/presentation/add_item_page.dart';
import 'features/wardrobe/presentation/wardrobe_page.dart';

class OutfitzApp extends StatelessWidget {
  const OutfitzApp({super.key});

  /// Outfitz is a phone app. On the web build we say so out loud: the whole app
  /// is framed at phone width against an ink backdrop instead of stretching a
  /// bottom-nav layout across a laptop screen.
  static const _phoneWidth = 430.0;
  static const _phoneHeight = 932.0;

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Outfitz',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        themeMode: ThemeMode.light,
        // The layout is tuned to a fixed rhythm; let the OS scale text a little,
        // but not enough to break the grid.
        builder: (context, child) {
          final scaled = MediaQuery.withClampedTextScaling(
            minScaleFactor: 1,
            maxScaleFactor: 1.25,
            child: child!,
          );
          if (!kIsWeb) return scaled;
          return _PhoneFrame(child: scaled);
        },
        home: const RootGate(),
      );
}

class _PhoneFrame extends StatelessWidget {
  const _PhoneFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final size = Size(
      math.min(OutfitzApp._phoneWidth, media.size.width),
      math.min(OutfitzApp._phoneHeight, media.size.height),
    );

    return ColoredBox(
      color: AppColors.ink,
      child: Center(
        child: SizedBox.fromSize(
          size: size,
          child: MediaQuery(
            data: media.copyWith(
              size: size,
              padding: EdgeInsets.zero,
              viewPadding: EdgeInsets.zero,
              viewInsets: EdgeInsets.zero,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(size.width == OutfitzApp._phoneWidth ? 22 : 0),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Splash → (first run only) onboarding → shell.
class RootGate extends ConsumerStatefulWidget {
  const RootGate({super.key});

  @override
  ConsumerState<RootGate> createState() => _RootGateState();
}

class _RootGateState extends ConsumerState<RootGate> {
  bool _splashDone = false;

  @override
  Widget build(BuildContext context) {
    final seen = ref.watch(onboardingSeenProvider);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 420),
      child: !_splashDone
          // The cover waits. It leaves when it is swiped left, and only then.
          ? SplashPage(
              key: const ValueKey('splash'),
              onEnter: () => setState(() => _splashDone = true),
            )
          : seen
              ? const Shell(key: ValueKey('shell'))
              : const OnboardingPage(key: ValueKey('onboarding')),
    );
  }
}

/// The three real destinations plus the centre "add" action.
class Shell extends ConsumerWidget {
  const Shell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(shellTabProvider);

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: index,
        children: const [HomePage(), WardrobePage(), PlannerPage()],
      ),
      bottomNavigationBar: OutfitzNavBar(
        index: index,
        onSelect: (i) => ref.read(shellTabProvider.notifier).go(i),
        onAdd: () => startAddFlow(context, ref),
      ),
    );
  }
}

Future<void> startAddFlow(BuildContext context, WidgetRef ref) async {
  final saved = await Navigator.of(context).push<bool>(
    MaterialPageRoute(builder: (_) => const AddItemPage(), fullscreenDialog: true),
  );
  if (saved == true) {
    ref.read(shellTabProvider.notifier).go(1);
  }
}

/// Hand-built navigation bar: hairline top edge, wide-tracked labels, and the
/// add action sitting proud in wine.
class OutfitzNavBar extends StatelessWidget {
  const OutfitzNavBar({
    required this.index,
    required this.onSelect,
    required this.onAdd,
    super.key,
  });

  final int index;
  final ValueChanged<int> onSelect;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SizedBox(
        height: 64,
        child: Row(
          children: [
            _NavTab(
              label: 'Home',
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              selected: index == 0,
              onTap: () => onSelect(0),
            ),
            _NavTab(
              label: 'Wardrobe',
              icon: Icons.checkroom_outlined,
              activeIcon: Icons.checkroom,
              selected: index == 1,
              onTap: () => onSelect(1),
            ),
            _AddButton(onTap: onAdd),
            _NavTab(
              label: 'Planner',
              icon: Icons.calendar_today_outlined,
              activeIcon: Icons.calendar_today,
              selected: index == 2,
              onTap: () => onSelect(2),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                selected ? activeIcon : icon,
                size: 20,
                color: selected ? AppColors.wine : AppColors.muted,
              ),
              const SizedBox(height: 5),
              MicroLabel(
                label,
                size: 8.5,
                spacing: 1.6,
                color: selected ? AppColors.wine : AppColors.muted,
                weight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ],
          ),
        ),
      );
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.translate(
                offset: const Offset(0, -2),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.wine,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: AppColors.white, size: 22),
                ),
              ),
            ],
          ),
        ),
      );
}
