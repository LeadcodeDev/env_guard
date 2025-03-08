import 'dart:convert';

final class EnvParser {
  Map<String, dynamic> parse(String content) {
    final Map<String, String> values = {};
    final lines = const LineSplitter().convert(content);

    for (final line in lines.nonNulls.where((element) => element.isNotEmpty)) {
      final trimmed = line.trim();
      if (trimmed.startsWith('#')) {
        continue;
      }

      final [key, value] = switch (trimmed) {
        String(:final contains) when contains('=') => trimmed.split('='),
        String(:final contains) when contains(':') => trimmed.split(':'),
        _ => [null, null],
      };

      if (key != null && value != null) {
        values[key] = value;
      }
    }

    return values;
  }
}
