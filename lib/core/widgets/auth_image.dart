import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:myapp/core/network/dio_client.dart';
import 'package:myapp/core/network/api_config.dart';
import 'package:myapp/core/storage/token_storage.dart';

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
  static final Map<String, Uint8List> _cache = <String, Uint8List>{};
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

  Future<void> _load() async {
    _cancel?.cancel();
    _cancel = CancelToken();
    setState(() {
      _bytes = null;
      _error = null;
    });
    final candidates = _buildCandidates(widget.url);
    // Serve from cache if available
    for (final url in candidates) {
      final cached = _cache[url];
      if (cached != null) {
        if (!mounted) return;
        setState(() => _bytes = cached);
        return;
      }
    }
    // Use a dedicated Dio without PrettyDioLogger to avoid binary logs
    final dio = Dio();
    String? token;
    try {
      token = await TokenStorage.instance.readToken();
    } catch (_) {}
    DioError? lastErr;
    for (final url in candidates) {
      try {
        final res = await dio.get<List<int>>(url,
            options: Options(
              responseType: ResponseType.bytes,
              headers: {
                'Accept': 'image/*',
                if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
              },
            ),
            cancelToken: _cancel);
        if (!mounted) return;
        final data = res.data;
        if (data == null || data.isEmpty) {
          lastErr = DioError(requestOptions: RequestOptions(path: url), error: 'Empty image');
          continue;
        }
        final bytes = Uint8List.fromList(data);
        _cache[url] = bytes;
        setState(() => _bytes = bytes);
        return;
      } catch (e) {
        if (e is DioError) {
          lastErr = e;
          // On 404, try next candidate
          continue;
        }
        lastErr = DioError(requestOptions: RequestOptions(path: url), error: e);
      }
    }
    if (!mounted) return;
    setState(() => _error = lastErr ?? 'Image load failed');
  }

  List<String> _buildCandidates(String u) {
    final base = Uri.parse(ApiConfig.baseUrl);
    final List<String> urls = [];
    final origin = '${base.scheme}://${base.host}${base.hasPort ? ':${base.port}' : ''}';
    final basePath = base.path.isEmpty ? '' : (base.path.startsWith('/') ? base.path : '/${base.path}');
    // Absolute URL
    if (u.startsWith('http://') || u.startsWith('https://')) {
      final abs = Uri.parse(u);
      final absPath = abs.path; // keeps leading '/'
      if (abs.scheme == base.scheme && abs.host == base.host && abs.port == base.port && absPath.startsWith('/uploads/')) {
        final candidate = _join(origin, basePath, absPath);
        urls.add(candidate);
      } else {
        urls.add(u);
      }
      return urls.toSet().toList();
    }
    // Relative path
    var rel = u;
    if (!rel.startsWith('/')) rel = '/$rel';
    final candidate = _join(origin, basePath, rel);
    urls.add(candidate);
    return urls.toSet().toList();
  }

  String _join(String origin, String basePath, String path) {
    final a = basePath.endsWith('/') ? basePath.substring(0, basePath.length - 1) : basePath;
    final b = path.startsWith('/') ? path : '/$path';
    return '$origin$a$b';
  }
}
