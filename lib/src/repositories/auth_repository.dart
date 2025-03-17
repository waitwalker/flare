import 'package:flare/src/database/database_connection.dart';
import 'package:postgres/postgres.dart';

class AuthRepository {
  Future<int?> findVerifyCodeByMobile(int mobile) async {
    Pool pool = DatabaseConnection.getConnectPool('flare_base');
    bool expired = false;
    Result result = await pool.run((conn) async {
      // 先查询当前手机号验证码是否过期
      var queryParameters = {'receiver': mobile, "scene": 'auth'};
      Result queryResult = await conn.execute(
        Sql.named('''
      SELECT expired_at FROM account_verify 
      WHERE receiver = @receiver
      AND scene = @scene
      AND expired_at > NOW()
      '''),
        parameters: queryParameters,
      );
      // 验证码不存在或已过期
      if (queryResult.isEmpty) {
        int timestamp = DateTime.now().millisecondsSinceEpoch;
        DateTime dateTimeUpdate = DateTime.fromMillisecondsSinceEpoch(timestamp);
        DateTime dateTimeExpire = DateTime.fromMillisecondsSinceEpoch(timestamp + 300 * 1000);
        var parameters = {
          'receiver': mobile,
          "scene": 'auth',
          "code": 1111,
          "receiverType": "sms",
          "createdAt": dateTimeUpdate,
          "updatedAt": dateTimeUpdate,
          "expiredAt": dateTimeExpire,
        };
        expired = true;
        return await conn.execute(
          Sql.named('''
      INSERT INTO account_verify (receiver, receiver_type, code, scene, expired_at, created_at, updated_at)
      VALUES (@receiver, @receiverType, @code, @scene, @expiredAt, @createdAt, @updatedAt)
      RETURNING id;
      '''),
          parameters: parameters,
        );
      } else {
        expired = false;
        return queryResult;
      }
    });

    if (result.isNotEmpty) {
      return expired ? 0 : 1;
    } else {
      return null;
    }
  }
}

// class AuthRepository {
//   Future<int?> findVerifyCodeByMobile(int mobile) async {
//     Pool pool = DatabaseConnection.getConnectPool('flare_base');
//     Result result = await pool.run((conn) async {
//       int timestamp = DateTime.now().millisecondsSinceEpoch;
//       DateTime dateTimeUpdate = DateTime.fromMillisecondsSinceEpoch(timestamp);
//       DateTime dateTimeExpire = DateTime.fromMillisecondsSinceEpoch(timestamp + 300 * 1000);
//       final updatedAt = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTimeUpdate);
//       final expiredAt = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTimeExpire);
//
//       var parameters = {
//         'receiver': mobile,
//         "scene": 'auth',
//         "code": 1111,
//         "receiverType": "sms",
//         "createdAt": updatedAt,
//         "updatedAt": updatedAt,
//         "expiredAt": expiredAt,
//       };
//       return await conn.execute(
//         Sql.named('''
//       INSERT INTO account_verify (receiver, receiver_type, code, scene, expired_at, created_at, updated_at)
//       VALUES (@receiver, @receiverType, @code, @scene, @expiredAt, @createdAt, @updatedAt)
//       ON CONFLICT (receiver, scene) DO UPDATE
//       SET code = EXCLUDED.code,
//           updated_at = EXCLUDED.updated_at
//       RETURNING id;
//       '''),
//         parameters: parameters,
//       );
//     });
//     if (result.isNotEmpty) {
//       return 0;
//     } else {
//       return null;
//     }
//   }
// }
