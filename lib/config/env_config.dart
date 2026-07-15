enum Environment { local, prod }

class EnvConfig {
  /* Environment local/live */
  static const Environment env = Environment.prod;

  /*Api Urls*/
  static const String baseUrl = env == Environment.prod
      ? baseUrlProd
      : baseUrlLocal;
  static const String baseUrlLocal = "http://192.168.100.119:3000";
  static const String baseUrlProd = "http://adapi.smartermed.xyz";
}
