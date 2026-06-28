import 'dart:async';
import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../core/app_constants.dart';

/// Search bar — dark with green accents.
class AtlasSearchBar extends StatefulWidget {
  final ValueChanged<String>? onSearch;
  final VoidCallback? onScanTap;
  final TextEditingController? controller;

  const AtlasSearchBar({
    super.key,
    this.onSearch,
    this.onScanTap,
    this.controller,
  });

  @override
  State<AtlasSearchBar> createState() => _AtlasSearchBarState();
}

class _AtlasSearchBarState extends State<AtlasSearchBar> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode.addListener(() => setState(() => _isFocused = _focusNode.hasFocus));
  }

  void _onTextChanged(String text) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 100), () {
      widget.onSearch?.call(text);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    if (widget.controller == null) {
      _controller.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppConstants.animFast,
      height: AppConstants.searchBarHeight,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        border: Border.all(
          color: _isFocused ? AppTheme.green : AppTheme.border,
          width: 1.0,
        ),
        boxShadow: _isFocused
            ? [BoxShadow(color: AppTheme.greenGlow, blurRadius: 16, spreadRadius: 0)]
            : null,
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Text(
            '>',
            style: AppTheme.titleLarge.copyWith(
              color: _isFocused ? AppTheme.green : AppTheme.textDim,
              fontSize: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              style: AppTheme.bodyLarge.copyWith(color: AppTheme.textPrimary),
              cursorColor: AppTheme.green,
              decoration: InputDecoration(
                hintText: 'search screenshots...',
                hintStyle: AppTheme.bodyLarge.copyWith(color: AppTheme.textDim),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              onChanged: _onTextChanged,
              onSubmitted: widget.onSearch,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              widget.onSearch?.call(_controller.text);
            },
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                border: Border.all(color: AppTheme.border, width: 0.5),
              ),
              child: const Icon(
                Icons.search_rounded,
                color: AppTheme.green,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: widget.onScanTap,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppTheme.green,
                borderRadius: BorderRadius.circular(AppConstants.radiusSM),
              ),
              child: const Icon(
                Icons.document_scanner_rounded,
                color: AppTheme.black,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
