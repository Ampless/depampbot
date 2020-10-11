import 'dart:io';

import 'package:github/github.dart';
import 'package:pub_api/pub_api.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_parse/pubspec_parse.dart';

main() async {
  final pubspec = Pubspec.parse(await File('pubspec.yaml').readAsString());
  final deps = pubspec.dependencies;
  for (final name in deps.keys)
    if (deps[name] is HostedDependency &&
            ((deps[name] as HostedDependency).version.isAny) ||
        ((deps[name] as HostedDependency).version as VersionRange).min <
            (await PubPackage.fromName(name)).latest.version)
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
