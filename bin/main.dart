import 'dart:io';

import 'package:github/github.dart';
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
  final github = GitHub();
  final gitRemote =
      (await Process.run('sh', ['-c', 'git remote get-url \$(git remote)']))
          .stdout
          .replaceAll(RegExp('[\r\n]'), '')
          .replaceFirst(RegExp('(https?|git):\\/\\/github\\.com\\/'), '')
          .replaceFirst(RegExp('\\.git\$'), '')
          .split('/');
  return;
  github.issues.create(
      RepositorySlug(gitRemote[0], gitRemote[1]),
      IssueRequest(
        title: 'depampbot dependency detected out of date',
        body: 'The packages "bla" and "blabla" are out of date.',
        labels: ['depampbot', 'enhancement'],
      ));
}
