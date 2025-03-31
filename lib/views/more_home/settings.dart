import 'package:flutter/material.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/sale_refer.dart';
import 'package:sheraaccerpoff/utility/colors.dart';
import 'package:sheraaccerpoff/utility/fonts.dart';
import 'package:sheraaccerpoff/views/sales.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool _isExpanded = false;
  bool isexpand = false;
  List settings = [];
  List stypelist=[];

  @override
  void initState() {
    super.initState();
    _fetchSettings();
    _fetchSType();
  }

  Future<void> _fetchSettings() async {
    try {
      List<Map<String, dynamic>> data = await SaleReferenceDatabaseHelper.instance.getAllsettings();
      print('Fetched stock data: $data');
      setState(() {
        settings = data;
      });
    } catch (e) {
      print('Error fetching stock data: $e');
    }
  }
Future<void> _fetchSType() async {
    try {
      List<Map<String, dynamic>> data = await SaleReferenceDatabaseHelper.instance.getAllStype();
      print('Fetched stock data: $data');
      setState(() {
        stypelist = data;
      });
    } catch (e) {
      print('Error fetching stock data: $e');
    }
  }
  void _toggleCheckbox(int index, bool? value) async {
    setState(() {
      settings[index]['Status'] = value! ? '1' : '0'; 
    });
    await SaleReferenceDatabaseHelper.instance.updateSetting(
      settings[index]['Name'],
      value! ? 1 : 0,
    );
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
              "Settings",
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
              onTap: () {},
              child: Icon(
                Icons.more_vert,
                color: Colors.white,
                size: 15,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 17),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 9),
                  child: Text("General", style: DrewerFonts()),
                ),
                IconButton(
                  icon: Icon(
                    _isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                ),
              ],
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton(
                    onPressed: () {
                      _showSalesOptionsDialog(); 
                    },
                    child: Text("General option", style: drewerFonts()),
                  ),
                  TextButton(
                    onPressed: () {
                      _showSalesTypeDialog();
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Text("Sale option", style: drewerFonts()),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Text("", style: drewerFonts()),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(left: 17),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 9),
                  child: Text("Printer", style: DrewerFonts()),
                ),
                IconButton(
                  icon: Icon(
                    isexpand ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      isexpand = !isexpand;
                    });
                  },
                ),
              ],
            ),
          ),
          if (isexpand)
            Row(
              children: [
                Column(
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: Text("", style: drewerFonts()),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Padding(
                        padding: const EdgeInsets.only(right: 40),
                        child: Text("", style: drewerFonts()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
void _showSalesOptionsDialog() {
  List<Map<String, dynamic>> tempSettings = List<Map<String, dynamic>>.from(settings);

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Sales Options', style: drewerFonts()),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(tempSettings.length, (index) {
                    bool isChecked = tempSettings[index]['Status'] == '1';

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: isChecked,
                          activeColor: isChecked ? Appcolors().maincolor : Colors.white,
                          onChanged: (bool? value) async{
                            if (value == null) return;

                            setState(() { 
                              tempSettings[index] = {
                                ...tempSettings[index], 
                                'Status': value ? '1' : '0', 
                              };
                            });
                            await SaleReferenceDatabaseHelper.instance.updateSetting(
                              tempSettings[index]['Name'],
                              value ? 1 : 0,
                            );
                          },
                        ),
                        Expanded(
                          child: Text(
                            tempSettings[index]['Name'] ?? "",
                            style: getFonts(14, Colors.black),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  settings = List<Map<String, dynamic>>.from(tempSettings);
                  Navigator.of(context).pop();
                },
                child: Text('Close'),
              ),
            ],
          );
        },
      );
    },
  );
}

void _showSalesTypeDialog() {
  List<Map<String, dynamic>> tempSalesType = List<Map<String, dynamic>>.from(stypelist);

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Sales Forms', style: drewerFonts()),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(tempSalesType.length, (index) {
                    bool isChecked = (tempSalesType[index]['isChecked'] ?? 0) == 1;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: isChecked,
                          activeColor: isChecked ? Appcolors().maincolor : Colors.grey, 
                          checkColor: Colors.white,
                          onChanged: (bool? value) async {
                            if (value == null) return;

                            setState(() { 
                              tempSalesType[index] = {
                                ...tempSalesType[index], 
                                'isChecked': value ? 1 : 0, 
                              };
                            });
                            await SaleReferenceDatabaseHelper.instance.updateSalesTypeCheck(
                              tempSalesType[index]['iD'], 
                              value,
                            );
                          },
                        ),
                        Expanded(
                          child: Text(
                            tempSalesType[index]['Name'] ?? "",
                            style: getFonts(14, isChecked ? Appcolors().maincolor : Colors.black),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  stypelist = List<Map<String, dynamic>>.from(tempSalesType);
                  Navigator.of(context).pop();
                },
                child: Text('Close'),
              ),
            ],
          );
        },
      );
    },
  );
}



}
