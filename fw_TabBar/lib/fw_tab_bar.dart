library;

import 'package:flutter/material.dart';

/// Sliding pill tab bar — hỗ trợ [TabController], N tabs, icon + text.
class FwTabBar extends StatefulWidget {
  final TabController? controller;
  final List<Widget> tabs;
  final Color? backgroundColor;
  final Color? unselectedBackgroundColor;
  final TextStyle? labelStyle;
  final TextStyle? unselectedLabelStyle;
  final EdgeInsetsGeometry contentPadding;
  final EdgeInsetsGeometry buttonMargin;
  final double radius;
  final double? width;
  final double? tabWidth;
  final bool center;
  final ScrollPhysics? physics;

  const FwTabBar({
    super.key,
    required this.tabs,
    this.controller,
    this.backgroundColor,
    this.unselectedBackgroundColor,
    this.labelStyle,
    this.unselectedLabelStyle,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 8,
    ),
    this.buttonMargin = const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
    this.radius = 36,
    this.width,
    this.tabWidth,
    this.center = false,
    this.physics,
  }) : assert(tabs.length >= 1, 'FwTabBar requires at least 1 tab');

  @override
  State<FwTabBar> createState() => _FwTabBarState();
}

class _FwTabBarState extends State<FwTabBar> with SingleTickerProviderStateMixin {
  TabController? _controller;
  bool _ownsController = false;

  TabController get _effectiveController {
    final c = _controller;
    assert(c != null, 'No TabController for FwTabBar');
    return c!;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncController();
  }

  @override
  void didUpdateWidget(covariant FwTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller ||
        oldWidget.tabs.length != widget.tabs.length) {
      _syncController();
    }
  }

  void _syncController() {
    final next = widget.controller ?? DefaultTabController.maybeOf(context);
    if (next != null) {
      if (!identical(_controller, next)) {
        _detach(_controller);
        if (_ownsController) _controller?.dispose();
        _ownsController = false;
        _controller = next;
        _attach(_controller!);
      }
      return;
    }

    if (_controller == null ||
        (_ownsController && _controller!.length != widget.tabs.length)) {
      _detach(_controller);
      if (_ownsController) _controller?.dispose();
      _controller = TabController(
        length: widget.tabs.length,
        vsync: this,
      );
      _ownsController = true;
      _attach(_controller!);
    }
  }

  void _onControllerTick() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    final c = _controller;
    c?.animation?.removeListener(_onControllerTick);
    c?.removeListener(_onControllerTick);
    if (_ownsController) c?.dispose();
    super.dispose();
  }

  void _attach(TabController c) {
    c.addListener(_onControllerTick);
    c.animation?.addListener(_onControllerTick);
  }

  void _detach(TabController? c) {
    c?.animation?.removeListener(_onControllerTick);
    c?.removeListener(_onControllerTick);
  }

  void _onTap(int index) {
    final c = _effectiveController;
    if (c.index == index) return;
    c.animateTo(index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedBg = widget.backgroundColor ?? colorScheme.primary;
    final unselectedBg =
        widget.unselectedBackgroundColor ??
        colorScheme.onSurface.withValues(alpha: 0.12);
    final selectedStyle =
        widget.labelStyle ??
        theme.textTheme.labelLarge?.copyWith(color: colorScheme.onPrimary) ??
        TextStyle(
          fontWeight: FontWeight.w700,
          color: colorScheme.onPrimary,
        );
    final unselectedStyle =
        widget.unselectedLabelStyle ??
        theme.textTheme.labelLarge?.copyWith(color: colorScheme.onSurface) ??
        TextStyle(
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        );

    final count = widget.tabs.length;
    final animationValue =
        _effectiveController.animation?.value ??
        _effectiveController.index.toDouble();
    final index = animationValue.round().clamp(0, count - 1);

    final bar = LayoutBuilder(
      builder: (context, constraints) {
        final margin = widget.buttonMargin.resolve(Directionality.of(context));
        final maxWidth = widget.width ??
            (constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : double.infinity);
        final marginsTotal = margin.horizontal * count;

        // Chiều rộng mỗi tab + có cần scroll không.
        late final double eachWidth;
        late final bool scrollable;

        if (widget.tabWidth != null) {
          eachWidth = widget.tabWidth!;
          final total = eachWidth * count + marginsTotal;
          scrollable = maxWidth.isFinite && total > maxWidth + 0.5;
        } else if (maxWidth.isFinite) {
          final equalWidth = (maxWidth - marginsTotal) / count;
          const minReadable = 88.0;
          if (equalWidth >= minReadable) {
            eachWidth = equalWidth;
            scrollable = false;
          } else {
            eachWidth = minReadable;
            scrollable = true;
          }
        } else {
          eachWidth = 120;
          scrollable = true;
        }

        // physics NeverScrollable mà nội dung vẫn tràn → vẫn bật scroll
        // (tránh overflow khi nhiều tab).
        final physics = scrollable
            ? (widget.physics is NeverScrollableScrollPhysics ||
                    widget.physics == null
                ? const BouncingScrollPhysics()
                : widget.physics!)
            : const NeverScrollableScrollPhysics();

        final totalWidth = eachWidth * count + marginsTotal;
        final trackWidth = scrollable ? totalWidth : maxWidth;

        final track = Container(
          width: trackWidth,
          decoration: BoxDecoration(
            color: unselectedBg,
            borderRadius: BorderRadius.circular(widget.radius),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned(
                left: margin.left +
                    animationValue * (eachWidth + margin.horizontal),
                top: margin.top,
                bottom: margin.bottom,
                width: eachWidth,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: selectedBg,
                    borderRadius: BorderRadius.circular(widget.radius),
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(count, (i) {
                  final selected = i == index;
                  return Padding(
                    padding: margin,
                    child: SizedBox(
                      width: eachWidth,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _onTap(i),
                          borderRadius:
                              BorderRadius.circular(widget.radius),
                          child: Padding(
                            padding: widget.contentPadding,
                            child: Center(
                              child: DefaultTextStyle(
                                style: selected
                                    ? selectedStyle
                                    : unselectedStyle,
                                child: IconTheme(
                                  data: IconThemeData(
                                    size: 18,
                                    color: selected
                                        ? selectedStyle.color
                                        : unselectedStyle.color,
                                  ),
                                  child: _FwTabLabel(tab: widget.tabs[i]),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );

        if (scrollable) {
          return SizedBox(
            width: maxWidth.isFinite ? maxWidth : null,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: physics,
              child: track,
            ),
          );
        }

        if (widget.center) return Center(child: track);
        return track;
      },
    );

    if (widget.width != null) {
      return SizedBox(width: widget.width, child: bar);
    }
    return bar;
  }
}

class _FwTabLabel extends StatelessWidget {
  final Widget tab;

  const _FwTabLabel({required this.tab});

  @override
  Widget build(BuildContext context) {
    if (tab is Tab) {
      final t = tab as Tab;
      final children = <Widget>[];
      if (t.icon != null) children.add(t.icon!);
      if (t.text != null) {
        if (children.isNotEmpty) children.add(const SizedBox(width: 6));
        children.add(
          Text(
            t.text!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        );
      } else if (t.child != null) {
        if (children.isNotEmpty) children.add(const SizedBox(width: 6));
        children.add(t.child!);
      }
      if (children.isEmpty) return const SizedBox.shrink();
      if (children.length == 1) return children.first;
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: children,
      );
    }
    return tab;
  }
}

/// API tương thích ngược (2 tab cố định) — ưu tiên dùng [FwTabBar].
@Deprecated('Use FwTabBar instead')
class TabBarWidget extends StatelessWidget {
  final String firstTab;
  final String secondTab;
  final ValueChanged<int> onTabChanged;
  final BoxDecoration selectedTabDecoration;
  final BoxDecoration backgroundBoxDecoration;
  final TextStyle selectedTabTextStyle;
  final TextStyle unselectedTabTextStyle;

  const TabBarWidget({
    super.key,
    required this.firstTab,
    required this.secondTab,
    required this.onTabChanged,
    this.selectedTabDecoration = const BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(50)),
      border: Border.fromBorderSide(BorderSide(color: Color(0xFFD9D9D9))),
      color: Color(0xFFFFFFFF),
    ),
    this.backgroundBoxDecoration = const BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(50)),
      color: Color(0xFF2F2F2F),
    ),
    this.selectedTabTextStyle = const TextStyle(
      fontWeight: FontWeight.bold,
      color: Color(0xFFFFFFFF),
      fontSize: 16,
    ),
    this.unselectedTabTextStyle = const TextStyle(
      fontWeight: FontWeight.normal,
      color: Color(0xFF2F2F2F),
      fontSize: 16,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Builder(
        builder: (context) {
          final controller = DefaultTabController.of(context);
          return FwTabBar(
            controller: controller,
            width: 220,
            tabWidth: 100,
            radius: 50,
            backgroundColor: backgroundBoxDecoration.color,
            unselectedBackgroundColor: selectedTabDecoration.color,
            labelStyle: selectedTabTextStyle,
            unselectedLabelStyle: unselectedTabTextStyle,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            buttonMargin: const EdgeInsets.all(5),
            tabs: [
              Tab(text: firstTab),
              Tab(text: secondTab),
            ],
          );
        },
      ),
    );
  }
}
