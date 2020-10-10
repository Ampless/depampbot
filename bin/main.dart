import 'dart:io';

import 'package:pub_api/pub_api.dart';
import 'package:version/version.dart';
import 'package:yaml/yaml.dart';

main() async {
  final pubspec = loadYaml(await File('pubspec.yaml').readAsString());
  final deps = pubspec['dependencies'];
  for (final name in deps.keys)
    if ((await PubPackage.fromName(name)).latest.version >
        Version.parse(deps[name].replaceFirst('^', '')))
      print(name + ' out of date');
}
