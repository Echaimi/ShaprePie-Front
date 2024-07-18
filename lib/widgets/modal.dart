// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class Modal extends StatefulWidget {
  final Widget child;
  final VoidCallback onClose;

  const Modal({super.key, required this.child, required this.onClose});

  @override
  _ModalState createState() => _ModalState();
}

class _ModalState extends State<Modal> {
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showOverlay());
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  void _showOverlay() {
    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            onTap: () {},
            child: Container(
              color: const Color(0x66000000),
            ),
          ),
          Center(
            child: Stack(
              children: [
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    width: MediaQuery.of(context).size.width - 32,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFF373455),
                        offset: Offset(
                          8.0,
                          8.0,
                        ),
                        spreadRadius: 2.0,
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            icon: Icon(Icons.close,
                                color: Theme.of(context).colorScheme.secondary),
                            onPressed: () {
                              _overlayEntry?.remove();
                              widget.onClose();
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: widget.child,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
