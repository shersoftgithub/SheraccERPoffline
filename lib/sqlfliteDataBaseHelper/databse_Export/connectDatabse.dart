// import 'package:dart_mssql/dart_mssql.dart';

// class ConnectionClass {
//   // Method to establish a connection
//   Future<Connection?> connectToDatabase(String ip, String db, String username, String password) async {
//     Connection? connection;
//     try {
//       // Connection settings
//       var config = ConnectionSettings(
//         address: ip,
//         port: 1433, // Default SQL Server port
//         database: db,
//         username: username,
//         password: password,
//       );

//       // Initialize connection
//       connection = await Connection.connect(config);
//       print('Database connection successful!');
//     } catch (e) {
//       print('Error connecting to the database: $e');
//       return null;
//     }
//     return connection;
//   }
// }

// class ConnectionSettings {
// }
