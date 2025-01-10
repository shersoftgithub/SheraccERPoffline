import 'package:flutter/material.dart';
import 'package:mssql_connection/mssql_connection.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/databse_Export/syncDB.dart';

class ServerConfig extends StatefulWidget {
  @override
  _ServerConfigState createState() => _ServerConfigState();
}

class _ServerConfigState extends State<ServerConfig> {
  final TextEditingController serverNameController = TextEditingController();
  final TextEditingController dbNameController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isConnecting = false;
  final connection = MssqlConnection.getInstance();

  // Store the connection details
  String? connectedDbName;

  Future<void> connectToDatabase() async {
    setState(() {
      isConnecting = true;
    });

    try {
      // Set up the connection
      await connection.connect(
        ip: serverNameController.text.trim(),
        port: 1433.toString(), // Default MSSQL port
        databaseName: dbNameController.text.trim(),
        username: userNameController.text.trim(),
        password: passwordController.text.trim(),
      );

      setState(() {
        connectedDbName = dbNameController.text.trim(); // Store the connected DB name
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connected to the database successfully!')),
      );

    
    } catch (e) {
      // Handle connection errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error connecting to the database: $e')),
      );
    } finally {
      setState(() {
        isConnecting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MSSQL Server Config'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: serverNameController,
              decoration: InputDecoration(labelText: 'Server IP'),
            ),
            TextField(
              controller: dbNameController,
              decoration: InputDecoration(labelText: 'Database Name'),
            ),
            TextField(
              controller: userNameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: isConnecting ? null : connectToDatabase,
              child: isConnecting
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Connect to Database'),
            ),
          ],
        ),
      ),
    );
  }
}
