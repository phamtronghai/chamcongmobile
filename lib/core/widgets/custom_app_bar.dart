import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:attendancebyface/core/cubits/user_cubit.dart';
import 'package:attendancebyface/core/cubits/user_state.dart';
import 'package:attendancebyface/core/widgets/gradient_ring.dart';
import 'package:attendancebyface/core/app_router.dart';

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
    this.avatarUrl,
    this.showAvatar = true,
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
  final String? avatarUrl;
  final bool showAvatar;
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
        // // Nút thông báo
        // if (widget.onNotificationTap != null)
        //   CustomButton(
        //     text: '',
        //     onPressed: widget.onNotificationTap,
        //     buttonType: ButtonType.circular,
        //     icon: Icons.notifications_outlined,
        //     tooltip: 'Thông báo',
        //   ),
        // Nút avatar (chỉ hiển thị khi showAvatar = true)
        if (widget.showAvatar)
          GestureDetector(
            onTap: () {
              AppRouter.goToPersonalInfo(context);
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: BlocBuilder<UserCubit, UserState>(
                builder: (context, state) {
                  String? imageUrl = widget.avatarUrl;
                  if ((imageUrl == null || imageUrl.isEmpty) &&
                      state is UserLoaded) {
                    imageUrl = state.user.image;
                  }

                  return GradientAvatarRing(
                    size: 48,
                    outerPadding: 2,
                    innerPadding: 1,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      backgroundImage: (imageUrl != null && imageUrl.isNotEmpty)
                          ? NetworkImage(imageUrl)
                          : null,
                      child: (imageUrl == null || imageUrl.isEmpty)
                          ? const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 18,
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
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
