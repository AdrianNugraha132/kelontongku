class ApiConstants {
  ApiConstants._();

  // Gunakan http://10.0.2.2:8080/api_kelontongku untuk Android Emulator,
  // http://localhost:8080/api_kelontongku untuk Web/Desktop,
  // atau IP LAN (mis. http://192.168.1.51/api_kelontongku) untuk HP fisik.
  static const String baseUrl = 'http://10.0.2.2:8080/api_kelontongku';

  static const String createBarang = '$baseUrl/create.php';
  static const String readBarang = '$baseUrl/read.php';
  static const String updateBarang = '$baseUrl/edit.php';
  static const String deleteBarang = '$baseUrl/delete.php';
}
