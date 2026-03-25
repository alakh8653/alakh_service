import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class JsonViewer extends StatefulWidget {
  final dynamic jsonData;

  const JsonViewer({super.key, required this.jsonData});

  @override
  State<JsonViewer> createState() => _JsonViewerState();
}

class _JsonViewerState extends State<JsonViewer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF30363D))),
            ),
            child: Row(
              children: [
                const Text(
                  'JSON',
                  style: TextStyle(
                    color: Color(0xFF8B949E),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.copy, size: 14),
                  onPressed: () => _copyToClipboard(context),
                  color: const Color(0xFF8B949E),
                  tooltip: 'Copy JSON',
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: _JsonNode(data: widget.jsonData, depth: 0),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context) {
    final jsonStr = const JsonEncoder.withIndent('  ').convert(widget.jsonData);
    Clipboard.setData(ClipboardData(text: jsonStr));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('JSON copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class _JsonNode extends StatefulWidget {
  final dynamic data;
  final int depth;

  const _JsonNode({required this.data, required this.depth});

  @override
  State<_JsonNode> createState() => _JsonNodeState();
}

class _JsonNodeState extends State<_JsonNode> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final data = widget.data;

    if (data is Map<String, dynamic>) {
      return _buildObject(data);
    } else if (data is List<dynamic>) {
      return _buildArray(data);
    } else {
      return _buildPrimitive(data);
    }
  }

  Widget _buildObject(Map<String, dynamic> map) {
    if (map.isEmpty) {
      return const Text(
        '{}',
        style: TextStyle(color: Color(0xFF8B949E), fontFamily: 'monospace'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _expanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                size: 14,
                color: const Color(0xFF8B949E),
              ),
              const Text(
                '{',
                style: TextStyle(
                  color: Color(0xFF8B949E),
                  fontFamily: 'monospace',
                  fontSize: 13,
                ),
              ),
              if (!_expanded)
                Text(
                  ' ${map.length} ${map.length == 1 ? 'key' : 'keys'} }',
                  style: const TextStyle(
                    color: Color(0xFF8B949E),
                    fontFamily: 'monospace',
                    fontSize: 13,
                  ),
                ),
            ],
          ),
        ),
        if (_expanded) ...[
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: map.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '"${entry.key}": ',
                        style: const TextStyle(
                          color: Color(0xFF7EE787),
                          fontFamily: 'monospace',
                          fontSize: 13,
                        ),
                      ),
                      Expanded(
                        child: _JsonNode(
                          data: entry.value,
                          depth: widget.depth + 1,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const Text(
            '}',
            style: TextStyle(
              color: Color(0xFF8B949E),
              fontFamily: 'monospace',
              fontSize: 13,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildArray(List<dynamic> list) {
    if (list.isEmpty) {
      return const Text(
        '[]',
        style: TextStyle(
          color: Color(0xFF8B949E),
          fontFamily: 'monospace',
          fontSize: 13,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _expanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                size: 14,
                color: const Color(0xFF8B949E),
              ),
              const Text(
                '[',
                style: TextStyle(
                  color: Color(0xFF8B949E),
                  fontFamily: 'monospace',
                  fontSize: 13,
                ),
              ),
              if (!_expanded)
                Text(
                  ' ${list.length} ${list.length == 1 ? 'item' : 'items'} ]',
                  style: const TextStyle(
                    color: Color(0xFF8B949E),
                    fontFamily: 'monospace',
                    fontSize: 13,
                  ),
                ),
            ],
          ),
        ),
        if (_expanded) ...[
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: list.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '[${entry.key}]: ',
                        style: const TextStyle(
                          color: Color(0xFF79C0FF),
                          fontFamily: 'monospace',
                          fontSize: 13,
                        ),
                      ),
                      Expanded(
                        child: _JsonNode(
                          data: entry.value,
                          depth: widget.depth + 1,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const Text(
            ']',
            style: TextStyle(
              color: Color(0xFF8B949E),
              fontFamily: 'monospace',
              fontSize: 13,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPrimitive(dynamic value) {
    if (value == null) {
      return const Text(
        'null',
        style: TextStyle(
          color: Color(0xFF8B949E),
          fontFamily: 'monospace',
          fontSize: 13,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    if (value is bool) {
      return Text(
        value.toString(),
        style: const TextStyle(
          color: Color(0xFFD2A679),
          fontFamily: 'monospace',
          fontSize: 13,
        ),
      );
    }

    if (value is num) {
      return Text(
        value.toString(),
        style: const TextStyle(
          color: Color(0xFF79C0FF),
          fontFamily: 'monospace',
          fontSize: 13,
        ),
      );
    }

    return Text(
      '"$value"',
      style: const TextStyle(
        color: Color(0xFFA5D6FF),
        fontFamily: 'monospace',
        fontSize: 13,
      ),
    );
  }
}
