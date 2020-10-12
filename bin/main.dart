import 'dart:io';

import 'package:github/github.dart';
import 'package:pub_api/pub_api.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_parse/pubspec_parse.dart';

Future<bool> versionIsOutdated(String name, VersionRange version) async =>
    version.isAny ||
    version.min < (await PubPackage.fromName(name)).latest.version;

Future<bool> dependencyIsOutdated(String name, HostedDependency dep) =>
    versionIsOutdated(name, dep.version);

Future<String> getGitRemoteUrl() async {
  final name = await Process.run('git', ['remote']);
  final url = await Process.run('git',
      ['remote', 'get-url', name.stdout.replaceAll(RegExp('[\r\n]'), '')]);
  return url.stdout.replaceAll(RegExp('[\r\n]'), '');
}

Future<RepositorySlug> getGithubRepo() async {
  final gitRemote = (await getGitRemoteUrl())
      .replaceFirst(RegExp('(https?|git):\\/\\/github\\.com\\/'), '')
      .replaceFirst(RegExp('\\.git\$'), '')
      .split('/');
  return RepositorySlug(gitRemote[0], gitRemote[1]);
}

main() async {
  final pubspec = Pubspec.parse(await File('pubspec.yaml').readAsString());
  final deps = pubspec.dependencies;
  for (final name in deps.keys)
    if (await dependencyIsOutdated(name, deps[name]))
      print(name + ' out of date');
  final github = GitHub();
  final repo = await getGithubRepo();
  return;
  github.issues.create(
      repo,
      IssueRequest(
        title: 'depampbot dependency detected out of date',
        body: 'The packages "bla" and "blabla" are out of date.',
        labels: ['depampbot', 'enhancement'],
      ));
}
