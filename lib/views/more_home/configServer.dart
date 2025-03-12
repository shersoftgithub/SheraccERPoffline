import 'package:flutter/material.dart';
import 'package:mssql_connection/mssql_connection.dart';
import 'package:sheraaccerpoff/utility/colors.dart';
import 'package:sheraaccerpoff/utility/fonts.dart';

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

  String? connectedDbName;

  Future<void> connectToDatabase() async {
    setState(() {
      isConnecting = true;
    });

    try {
      await connection.connect(
        ip: serverNameController.text.trim(),
        port: 1433.toString(), 
        databaseName: dbNameController.text.trim(),
        username: userNameController.text.trim(),
        password: passwordController.text.trim(),
      );

      setState(() {
        connectedDbName = dbNameController.text.trim(); 
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connected to the database successfully!')),
      );

    
    } catch (e) {
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
            backgroundColor: Appcolors().scafoldcolor,

      appBar: AppBar(
        toolbarHeight: screenHeight * 0.1,
        backgroundColor: Appcolors().maincolor,
        leading: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: IconButton(
            onPressed: () {
            Navigator.pop(context);
            },
              icon: Icon(
              Icons.arrow_back_ios_new_sharp,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        title: Center(
          child: Padding(
            padding: EdgeInsets.only(
              top: screenHeight * 0.02,
              right: screenHeight * 0.01,
            ),
            child: Text(
              "DataBase Config",
              style: appbarFonts(screenWidth * 0.04, Colors.white),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(
              top: screenHeight * 0.02,
              right: screenHeight * 0.02,
            ),
            child: GestureDetector(
              onTap: () {

              },
              child: Icon(
                Icons.more_vert,
                color: Colors.white,
                size: 15,
              ),
            ),
          ),
        ],
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
       GestureDetector(
         onTap: isConnecting ? null : connectToDatabase,
        child: Padding(
          padding: EdgeInsets.all(screenHeight * 0.03),
          child: Container(
            height: screenHeight * 0.05,
            width: screenWidth * 0.8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Color(0xFF0A1EBE),
            ),
            child: Center(
              child: isConnecting
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Connect to Database',style: getFonts(15, Colors.white),),
            ),
          ),
        ),
      ),

            // ElevatedButton(
            //   onPressed: isConnecting ? null : connectToDatabase,
            //   child: isConnecting
            //       ? CircularProgressIndicator(color: Colors.white)
            //       : Text('Connect to Database'),
            // ),
          ],
        ),
      ),
    );
  }
}
