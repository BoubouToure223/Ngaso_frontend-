import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:myapp/core/network/dio_client.dart';

class AuthImage extends StatefulWidget {
  const AuthImage({super.key, required this.url, this.fit = BoxFit.cover});
  final String url;
  final BoxFit fit;

  @override
  State<AuthImage> createState() => _AuthImageState();
}

class _AuthImageState extends State<AuthImage> {
  Uint8List? _bytes;
  Object? _error;
  CancelToken? _cancel;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant AuthImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _load();
    }
  }

  Future<void> _load() async {
    _cancel?.cancel();
    _cancel = CancelToken();
    setState(() {
      _bytes = null;
      _error = null;
    });
    try {
      final dio = DioClient.I.dio;
      final res = await dio.get<List<int>>(widget.url,
          options: Options(responseType: ResponseType.bytes), cancelToken: _cancel);
      if (!mounted) return;
      final data = res.data;
      if (data == null) throw Exception('Empty image body');
      setState(() => _bytes = Uint8List.fromList(data));
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    }
  }

  @override
  void dispose() {
    _cancel?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_bytes != null) {
      return Image.memory(_bytes!, fit: widget.fit);
    }
    if (_error != null) {
      return const SizedBox.shrink();
    }
    return const Center(child: CircularProgressIndicator(strokeWidth: 2));
  }
}
