// lib/widgets/reports/common/report_search_field.dart

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:tilework/widget/reports/report_theme.dart';

class ReportSearchField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(String)? onChanged;
  final VoidCallback? onClear;
  final double? width;
  final bool autofocus;
  final int debounceMilliseconds;
  final String? label;

  const ReportSearchField({
    Key? key,
    required this.controller,
    this.hintText = 'Search...',
    this.onChanged,
    this.onClear,
    this.width,
    this.autofocus = false,
    this.debounceMilliseconds = 300,
    this.label,
  }) : super(key: key);

  @override
  State<ReportSearchField> createState() => _ReportSearchFieldState();
}

class _ReportSearchFieldState extends State<ReportSearchField> {
  Timer? _debounce;
  bool _hasFocus = false;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(Duration(milliseconds: widget.debounceMilliseconds), () {
      widget.onChanged?.call(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width ?? 280,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.label != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                widget.label!,
                style: ReportTheme.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: ReportTheme.textSecondary,
                ),
              ),
            ),
          Focus(
            onFocusChange: (hasFocus) {
              setState(() => _hasFocus = hasFocus);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: _hasFocus ? Colors.white : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _hasFocus
                      ? ReportTheme.primaryColor
                      : widget.controller.text.isNotEmpty
                          ? ReportTheme.primaryColor.withOpacity(0.5)
                          : ReportTheme.dividerColor,
                  width: _hasFocus ? 2 : 1,
                ),
                boxShadow: _hasFocus
                    ? [
                        BoxShadow(
                          color: ReportTheme.primaryColor.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: TextField(
                controller: widget.controller,
                autofocus: widget.autofocus,
                onChanged: _onSearchChanged,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: TextStyle(
                    color: ReportTheme.textHint,
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                  ),
                  prefixIcon: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.search_rounded,
                      color: _hasFocus
                          ? ReportTheme.primaryColor
                          : ReportTheme.textSecondary,
                      size: 20,
                    ),
                  ),
                  suffixIcon: widget.controller.text.isNotEmpty
                      ? IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              color: ReportTheme.textSecondary,
                              size: 14,
                            ),
                          ),
                          onPressed: () {
                            widget.controller.clear();
                            widget.onClear?.call();
                            widget.onChanged?.call('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Search with suggestions
class ReportSearchWithSuggestions extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final List<String> suggestions;
  final Function(String) onChanged;
  final Function(String) onSuggestionSelected;
  final double? width;
  final String? label;

  const ReportSearchWithSuggestions({
    Key? key,
    required this.controller,
    this.hintText = 'Search...',
    required this.suggestions,
    required this.onChanged,
    required this.onSuggestionSelected,
    this.width,
    this.label,
  }) : super(key: key);

  @override
  State<ReportSearchWithSuggestions> createState() =>
      _ReportSearchWithSuggestionsState();
}

class _ReportSearchWithSuggestionsState
    extends State<ReportSearchWithSuggestions> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _hasFocus = false;
  List<String> _filteredSuggestions = [];

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showOverlay() {
    _removeOverlay();

    if (_filteredSuggestions.isEmpty) return;

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 4),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                shrinkWrap: true,
                itemCount: _filteredSuggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = _filteredSuggestions[index];
                  return ListTile(
                    dense: true,
                    leading: Icon(
                      Icons.search,
                      size: 18,
                      color: ReportTheme.textSecondary,
                    ),
                    title: Text(
                      suggestion,
                      style: const TextStyle(fontSize: 13),
                    ),
                    onTap: () {
                      widget.controller.text = suggestion;
                      widget.onSuggestionSelected(suggestion);
                      _removeOverlay();
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _updateSuggestions(String query) {
    if (query.isEmpty) {
      _filteredSuggestions = [];
    } else {
      _filteredSuggestions = widget.suggestions
          .where((s) => s.toLowerCase().contains(query.toLowerCase()))
          .take(5)
          .toList();
    }
    
    if (_hasFocus) {
      if (_filteredSuggestions.isNotEmpty) {
        _showOverlay();
      } else {
        _removeOverlay();
      }
    }
    
    widget.onChanged(query);
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Focus(
        onFocusChange: (hasFocus) {
          setState(() => _hasFocus = hasFocus);
          if (!hasFocus) {
            Future.delayed(const Duration(milliseconds: 200), _removeOverlay);
          } else if (_filteredSuggestions.isNotEmpty) {
            _showOverlay();
          }
        },
        child: ReportSearchField(
          controller: widget.controller,
          hintText: widget.hintText,
          label: widget.label,
          width: widget.width,
          onChanged: _updateSuggestions,
          onClear: () {
            _filteredSuggestions = [];
            _removeOverlay();
          },
        ),
      ),
    );
  }
}