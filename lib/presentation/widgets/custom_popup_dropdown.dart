import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomPopupDropdown extends StatefulWidget {
  final String? value;
  final List<String> items;
  final String hintText;
  final ValueChanged<String?>? onChanged;
  final FormFieldValidator<String>? validator;
  final Color? fillColor;
  final double borderRadius;

  const CustomPopupDropdown({
    super.key,
    this.value,
    required this.items,
    this.hintText = 'Select an option',
    this.onChanged,
    this.validator,
    this.fillColor,
    this.borderRadius = 14.0,
  });

  @override
  State<CustomPopupDropdown> createState() => _CustomPopupDropdownState();
}

class _CustomPopupDropdownState extends State<CustomPopupDropdown> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isDropdownOpen = false;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(CustomPopupDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.text = widget.value ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _toggleDropdown() {
    if (!mounted) return;

    if (_isDropdownOpen) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _showOverlay() {
    if (!mounted || _overlayEntry != null) return;

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: _removeOverlay,
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            Positioned(
              left: offset.dx,
              top: offset.dy + size.height + 5,
              width: size.width,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: widget.items.length,
                    itemBuilder: (context, index) {
                      final item = widget.items[index];
                      final isSelected = item == widget.value;

                      return InkWell(
                        onTap: () {
                          widget.onChanged?.call(item);
                          _removeOverlay();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blue.withValues(alpha: 0.1) : Colors.transparent,
                            borderRadius: index == 0
                                ? BorderRadius.only(
                                    topLeft: Radius.circular(widget.borderRadius),
                                    topRight: Radius.circular(widget.borderRadius),
                                  )
                                : index == widget.items.length - 1
                                    ? BorderRadius.only(
                                        bottomLeft: Radius.circular(widget.borderRadius),
                                        bottomRight: Radius.circular(widget.borderRadius),
                                      )
                                    : BorderRadius.zero,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    color: isSelected ? Colors.blue : Colors.black87,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isDropdownOpen = true);
  }

  void _removeOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
    if (mounted && _isDropdownOpen) {
      setState(() => _isDropdownOpen = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: AbsorbPointer(
          child: TextFormField(
            controller: _controller,
            style: GoogleFonts.inter(fontSize: 16),
            decoration: InputDecoration(
              hintText: widget.hintText,
              filled: true,
              fillColor: widget.fillColor ?? Colors.grey.shade100,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: BorderSide.none,
              ),
              suffixIcon: Icon(
                _isDropdownOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: Colors.grey.shade600,
              ),
            ),
            validator: widget.validator,
            readOnly: true,
          ),
        ),
      ),
    );
  }
}