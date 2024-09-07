import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'EMAIL', obfuscate: true)
  static String email = _Env.email;

  @EnviedField(varName: 'PASSWORD', obfuscate: true)
  static String password = _Env.password;

  @EnviedField(varName: 'EMAILSUP', obfuscate: true)
  static String supportEmail = _Env.supportEmail;
}
