import 'package:pub_api/pub_api.dart';

main() async {
  print(await PubPackage.fromName('schttp'));
}
