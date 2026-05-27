import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

class LoadingSkeleton extends StatefulWidget {
  final double? width;
  final double height;
  final double borderRadius;
  final int? itemCount;
  final EdgeInsetsGeometry? padding;

  const LoadingSkeleton({
    super.key,
    this.width,
    this.height = 18,
    this.borderRadius = AppSizes.radiusMd,
    this.itemCount,
    this.padding,
  });

  @override
  State<LoadingSkeleton> createState() => _LoadingSkeletonState();
}

class _LoadingSkeletonState extends State<LoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _singleSkeleton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + (_controller.value * 2), 0),
              end: Alignment(1.0 + (_controller.value * 2), 0),
              colors: isDark
                  ? [
                AppColors.slate800,
                AppColors.slate700,
                AppColors.slate800,
              ]
                  : [
                AppColors.slate100,
                AppColors.slate200,
                AppColors.slate100,
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.itemCount;

    if (count == null || count <= 1) {
      return Padding(
        padding: widget.padding ?? EdgeInsets.zero,
        child: _singleSkeleton(context),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: widget.padding ?? EdgeInsets.zero,
      itemCount: count,
      separatorBuilder: (context, index) => const SizedBox(height: AppSizes.md),
      itemBuilder: (context, index) => _singleSkeleton(context),
    );
  }
}

class LoadingSkeletonList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;

  const LoadingSkeletonList({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 96,
  });

  @override
  Widget build(BuildContext context) {
    return LoadingSkeleton(
      itemCount: itemCount,
      height: itemHeight,
      borderRadius: AppSizes.radiusLg,
    );
  }
}
