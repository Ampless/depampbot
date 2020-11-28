import 'dart:io';

import 'package:github/github.dart';
import 'package:pub_api/pub_api.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_parse/pubspec_parse.dart';

bool versionIsOutdated(PubPackage package, VersionRange version) =>
    version.isAny || version.min < package.latest.version;

bool dependencyIsOutdated(PubPackage package, HostedDependency dep) =>
    versionIsOutdated(package, dep.version);

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
  final github = GitHub();
  final repo = await getGithubRepo();
  for (final name in deps.keys) {
    final package = await PubPackage.fromName(name);
    if (await dependencyIsOutdated(package, deps[name])) {
      print(name + ' out of date');
      github.issues.create(
          repo,
          IssueRequest(
            title: '[DepAmpBot] $name out of date',
            body: 'The pub package "$name" is out of date, '
                '${package.latest} is available.',
            labels: ['depampbot', 'enhancement'],
          ));
    }
  }
}
