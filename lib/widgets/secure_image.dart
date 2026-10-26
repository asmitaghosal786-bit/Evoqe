import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/security/secure_media_store.dart';

class SecureImage extends StatefulWidget {
  final String? fileName;
  final BoxFit fit;
  final Widget placeholder;

  const SecureImage({
    super.key,
    required this.fileName,
    this.fit = BoxFit.cover,
    this.placeholder = const SizedBox.shrink(),
  });

  @override
  State<SecureImage> createState() => _SecureImageState();
}

class _SecureImageState extends State<SecureImage> {
  Future<Uint8List?>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load();
  }

  @override
  void didUpdateWidget(SecureImage old) {
    super.didUpdateWidget(old);
    if (old.fileName != widget.fileName) _load();
  }

  void _load() {
    final name = widget.fileName;
    _future =
    name == null ? null : context.read<SecureMediaStore>().load(name);
  }

  @override
  Widget build(BuildContext context) {
    final future = _future;
    if (future == null) return widget.placeholder;
    return FutureBuilder<Uint8List?>(
      future: future,
      builder: (context, snap) {
        final bytes = snap.data;
        if (bytes == null) return widget.placeholder;
        return Image.memory(bytes, fit: widget.fit, gaplessPlayback: true);
      },
    );
  }
}