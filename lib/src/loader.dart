import 'dart:io';

typedef EnvEntry = ({String name, String content});

final class Loader {
  final Directory root;

  Loader(this.root);

  List<EnvEntry> load() {
    final List<EnvEntry> values = [];
    final elements = root.listSync();

    final environments =
        elements
            .whereType<File>()
            .where((element) => element.uri.pathSegments.last.contains('.env'))
            .toList();

    for (final file in environments) {
      values.add((name: file.uri.pathSegments.last, content: file.readAsStringSync()));
    }

    return values;
  }
}
