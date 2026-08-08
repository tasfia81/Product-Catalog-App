import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomSearchBar extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;
  final String hintText;

  const CustomSearchBar({
    super.key,
    required this.initialValue,
    required this.onChanged,
    this.hintText = 'Search products...',
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant CustomSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SearchBar(
      controller: _controller,
      hintText: widget.hintText,
      onChanged: widget.onChanged,
      leading: Icon(
        Icons.search_rounded,
        color: theme.colorScheme.primary,
        size: 22.r,
      ),
      trailing: [
        if (_controller.text.isNotEmpty)
          IconButton(
            icon: Icon(Icons.clear_rounded, size: 20.r),
            onPressed: () {
              _controller.clear();
              widget.onChanged('');
            },
          ),
      ],
      elevation: const WidgetStatePropertyAll(0),
      backgroundColor: WidgetStatePropertyAll(
        theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      ),
      textStyle: WidgetStatePropertyAll(
        theme.textTheme.bodyMedium?.copyWith(fontSize: 14.sp),
      ),
    );
  }
}
