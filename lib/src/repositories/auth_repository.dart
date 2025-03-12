import 'package:flare/src/database/database_connection.dart';
import 'package:intl/intl.dart';
import 'package:postgres/postgres.dart';

class AuthRepository {
  Future<int?> findVerifyCodeByMobile(int mobile) async {
    Pool pool = DatabaseConnection.getConnectPool('flare_base');
    Result result = await pool.run((conn) async {
      int timestamp = DateTime.now().millisecondsSinceEpoch;
      DateTime dateTimeUpdate = DateTime.fromMillisecondsSinceEpoch(timestamp);
      DateTime dateTimeExpire = DateTime.fromMillisecondsSinceEpoch(timestamp + 300 * 1000);
      final updatedAt = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTimeUpdate);
      final expiredAt = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTimeExpire);

      var parameters = {
        'receiver': mobile,
        "scene": 'auth',
        "code": 1111,
        "receiverType": "sms",
        "createdAt": updatedAt,
        "updatedAt": updatedAt,
        "expiredAt": expiredAt,
      };
      return await conn.execute(
        Sql.named('''
      INSERT INTO account_verify (receiver, receiver_type, code, scene, expired_at, created_at, updated_at)
      VALUES (@receiver, @receiverType, @code, @scene, @expiredAt, @createdAt, @updatedAt)
      ON CONFLICT (receiver, scene) DO UPDATE 
      SET code = EXCLUDED.code,
          updated_at = EXCLUDED.updated_at
      RETURNING id;
      '''),
        parameters: parameters,
      );
    });
    if (result.isNotEmpty) {
      return 0;
    } else {
      return null;
    }
  }
}
