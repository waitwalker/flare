import 'package:flare/src/database/database_connection.dart';
import 'package:postgres/postgres.dart';

class UserRepository {
  Future<dynamic> findUserByID(int id) async {
    Pool pool = DatabaseConnection.getConnectPool('db_user');

    /// 查询sql
    Result result = await pool.run((conn) async {
      var parameters = {"id": '$id'};
      return await conn.execute('SELECT id, name, email FROM users WHERE id=@id', parameters: parameters);
    });

    if (result.isEmpty) {
      return 'not find user id = $id';
    } else {
      return result.first.toColumnMap();
    }
  }
}
