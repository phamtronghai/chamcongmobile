library;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Sliding pill tab bar — hỗ trợ [TabController], N tabs, icon + text.
///
/// Mặc định mỗi tab **fit-content**. Tràn bề ngang → cuộn trái/phải.
/// Truyền [tabWidth] để ép chiều rộng cố định (hành vi cũ).
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
  final ScrollController _scrollController = ScrollController();
  late List<GlobalKey> _tabKeys;
  List<double> _tabWidths = const [];

  TabController get _effectiveController {
    final c = _controller;
    assert(c != null, 'No TabController for FwTabBar');
    return c!;
  }

  @override
  void initState() {
    super.initState();
    _tabKeys = List.generate(widget.tabs.length, (_) => GlobalKey());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncController();
  }

  @override
  void didUpdateWidget(covariant FwTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tabs.length != widget.tabs.length) {
      _tabKeys = List.generate(widget.tabs.length, (_) => GlobalKey());
      _tabWidths = const [];
    }
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
    if (!mounted) return;
    setState(() {});
    _scrollSelectedIntoView();
  }

  @override
  void dispose() {
    final c = _controller;
    c?.animation?.removeListener(_onControllerTick);
    c?.removeListener(_onControllerTick);
    if (_ownsController) c?.dispose();
    _scrollController.dispose();
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

  void _scheduleMeasure() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _measureTabs();
    });
  }

  void _measureTabs() {
    if (widget.tabWidth != null) return;
    final widths = <double>[];
    var changed = _tabWidths.length != _tabKeys.length;
    for (var i = 0; i < _tabKeys.length; i++) {
      final box =
          _tabKeys[i].currentContext?.findRenderObject() as RenderBox?;
      final w = box?.hasSize == true ? box!.size.width : 0.0;
      widths.add(w);
      if (!changed &&
          (i >= _tabWidths.length || (w - _tabWidths[i]).abs() > 0.5)) {
        changed = true;
      }
    }
    if (!changed) return;
    setState(() => _tabWidths = widths);
    _scrollSelectedIntoView();
  }

  double _leftOf(int index, EdgeInsets margin) {
    var left = margin.left;
    for (var i = 0; i < index; i++) {
      left += _widthAt(i) + margin.horizontal;
    }
    return left;
  }

  double _widthAt(int index) {
    if (widget.tabWidth != null) return widget.tabWidth!;
    if (index < _tabWidths.length && _tabWidths[index] > 0) {
      return _tabWidths[index];
    }
    return 88;
  }

  void _scrollSelectedIntoView() {
    if (!_scrollController.hasClients) return;
    final count = widget.tabs.length;
    if (count == 0) return;
    final margin = widget.buttonMargin.resolve(Directionality.of(context));
    final index = _effectiveController.index.clamp(0, count - 1);
    final left = _leftOf(index, margin);
    final right = left + _widthAt(index) + margin.right;
    final viewStart = _scrollController.offset;
    final viewEnd = viewStart + _scrollController.position.viewportDimension;
    double? target;
    if (left < viewStart) {
      target = left;
    } else if (right > viewEnd) {
      target = right - _scrollController.position.viewportDimension;
    }
    if (target == null) return;
    target = target.clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
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
    if (_tabKeys.length != count) {
      _tabKeys = List.generate(count, (_) => GlobalKey());
    }

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
        final fitContent = widget.tabWidth == null;

        late final List<double> widths;
        if (!fitContent) {
          widths = List.filled(count, widget.tabWidth!);
        } else if (_tabWidths.length == count &&
            _tabWidths.every((w) => w > 0)) {
          widths = _tabWidths;
        } else {
          widths = List.filled(count, 88);
          _scheduleMeasure();
        }

        final contentTotal =
            widths.fold<double>(0, (sum, w) => sum + w) + marginsTotal;
        final scrollable =
            maxWidth.isFinite && contentTotal > maxWidth + 0.5;
        final physics = scrollable
            ? (widget.physics ?? const BouncingScrollPhysics())
            : const NeverScrollableScrollPhysics();

        final trackWidth = scrollable
            ? contentTotal
            : (maxWidth.isFinite ? maxWidth : contentTotal);

        // Pill lerp theo animation giữa 2 tab.
        double leftOf(int i) {
          var left = margin.left;
          for (var j = 0; j < i; j++) {
            left += widths[j] + margin.horizontal;
          }
          return left;
        }

        final from = animationValue.floor().clamp(0, count - 1);
        final to = animationValue.ceil().clamp(0, count - 1);
        final t = (animationValue - from).clamp(0.0, 1.0);
        final pillLeft = leftOf(from) + (leftOf(to) - leftOf(from)) * t;
        final pillWidth = widths[from] + (widths[to] - widths[from]) * t;

        final track = Container(
          width: fitContent && !scrollable ? null : trackWidth,
          decoration: BoxDecoration(
            color: unselectedBg,
            borderRadius: BorderRadius.circular(widget.radius),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned(
                left: pillLeft,
                top: margin.top,
                bottom: margin.bottom,
                width: pillWidth,
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
                  final tabChild = Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _onTap(i),
                      borderRadius: BorderRadius.circular(widget.radius),
                      child: Padding(
                        padding: widget.contentPadding,
                        child: Center(
                          child: DefaultTextStyle(
                            style: selected ? selectedStyle : unselectedStyle,
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
                  );

                  return Padding(
                    padding: margin,
                    child: KeyedSubtree(
                      key: _tabKeys[i],
                      child: fitContent
                          ? tabChild
                          : SizedBox(width: widths[i], child: tabChild),
                    ),
                  );
                }),
              ),
            ],
          ),
        );

        _scheduleMeasure();

        Widget child;
        if (scrollable) {
          child = SizedBox(
            width: maxWidth.isFinite ? maxWidth : null,
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: physics,
              child: track,
            ),
          );
        } else if (widget.center) {
          child = Center(child: track);
        } else {
          child = track;
        }
        return child;
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
            softWrap: false,
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
