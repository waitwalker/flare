import 'package:flare/config/db_config.dart';
import 'package:postgres/postgres.dart';

class DatabaseConnection {
  static final Map<String, Pool> _pools = {};

  static Future<void> initialize() async {
    for (final entry in dbConfig.entries) {
      final dbName = entry.key;
      final config = entry.value;
      final endpoint = Endpoint(
        host: config['host'],
        port: config['port'],
        database: dbName,
        username: config['username'],
        password: config['password'],
      );
      final pool = Pool.withEndpoints([
        endpoint,
      ], settings: PoolSettings(maxConnectionCount: 10, maxConnectionAge: Duration(minutes: 15), sslMode: SslMode.disable));
      _pools[dbName] = pool;
    }
  }

  static Pool getConnectPool(String dbName) {
    final pool = _pools[dbName];
    if (pool == null) throw Exception('no pool found for database:$dbName');
    return pool;
  }

  static Future close() async {
    await Future.wait(_pools.values.map((pool) => pool.close()));
    _pools.clear();
  }
}
