import 'package:flutter/material.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.onTitleTap,
    this.onHistoryTap,
    this.onNotificationTap,
    this.tabs,
    this.tabController,
    this.onTabChanged,
    this.showTabs = false,
    this.automaticallyImplyLeading = true,
    this.leading,
  });

  final String title;
  final VoidCallback? onTitleTap; // Callback for hidden actions
  final VoidCallback? onHistoryTap;
  final VoidCallback? onNotificationTap;
  final List<Widget>? tabs;
  final TabController? tabController;
  final ValueChanged<int>? onTabChanged;
  final bool showTabs;
  final bool automaticallyImplyLeading;
  final Widget? leading;

  @override
  CustomAppBarState createState() => CustomAppBarState();

  @override
  Size get preferredSize {
    if (showTabs && tabs != null) {
      return const Size.fromHeight(104);
    }
    return const Size.fromHeight(kToolbarHeight);
  }
}

class CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      elevation: 0,
      automaticallyImplyLeading: widget.automaticallyImplyLeading,
      leading: widget.leading,
      title: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          // Implement 5-tap logic internally or expose callback
          if (widget.onTitleTap != null) {
            widget.onTitleTap!();
          }
        },
        child: Text(
          widget.title.toUpperCase(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      centerTitle: true,
      actions: [
        if (widget.onNotificationTap != null)
          IconButton(
            tooltip: 'Thông báo',
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: widget.onNotificationTap,
          ),
      ],
      bottom: widget.showTabs && widget.tabs != null
          ? TabBar(
              controller: widget.tabController,
              onTap: widget.onTabChanged,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14,
              ),
              tabs: widget.tabs!,
            )
          : null,
    );
  }
}
