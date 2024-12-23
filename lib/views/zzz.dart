// class _AddpaymantState extends State<Addpaymant> {
//   final TextEditingController _itemnameController = TextEditingController();
//   final TextEditingController _qtyController = TextEditingController();
//   final TextEditingController _unitController = TextEditingController();
//   final TextEditingController _rateController = TextEditingController();
//   final TextEditingController _taxController = TextEditingController();
  
//   List<String> _itemSuggestions = [];  // List of existing items for suggestions

//   // Method to fetch item names from the database
//   void _fetchItemNames() async {
//     List<String> items = await DatabaseHelper.instance.getItemNames();
//     setState(() {
//       _itemSuggestions = items;
//     });
//   }

//   void _saveData() async {
//     final itemName = _itemnameController.text.trim();
//     final unit = _unitController.text.trim();
//     final qty = double.tryParse(_qtyController.text.trim()) ?? 0.0;
//     final rate = double.tryParse(_rateController.text.trim()) ?? 0.0;
//     final tax = double.tryParse(_taxController.text.trim()) ?? 0.0;
//     final totalAmt = (rate * qty) + tax;

//     final existingItems = await DatabaseHelper.instance.getItemNames();

//     if (!existingItems.contains(itemName)) {
//       // If item doesn't exist, show the confirmation dialog to create a new item
//       _showCreateItemDialog(itemName, unit, qty, rate, tax, totalAmt);
//     } else {
//       // Item already exists, just save it
//       final creditsale = SalesCredit(
//         invoiceId: 0,
//         date: "", 
//         salesRate: 0.0,
//         customer: "",
//         phoneNo: "",
//         itemName: itemName,
//         qty: qty,
//         unit: unit,
//         rate: rate,
//         tax: tax,
//         totalAmt: totalAmt,
//       );
//       await DatabaseHelper.instance.insert(creditsale.toMap());
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved successfully')));
//     }
//   }

//   // Show dialog to ask user to create a new item
//   void _showCreateItemDialog(String itemName, String unit, double qty, double rate, double tax, double totalAmt) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Create a new item'),
//           content: Text('Item "$itemName" does not exist. Would you like to create it?'),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 // Cancel action
//                 Navigator.of(context).pop();
//               },
//               child: Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () async {
//                 // Create the new item and save it
//                 final creditsale = SalesCredit(
//                   invoiceId: 0,
//                   date: "",
//                   salesRate: 0.0,
//                   customer: "",
//                   phoneNo: "",
//                   itemName: itemName,
//                   qty: qty,
//                   unit: unit,
//                   rate: rate,
//                   tax: tax,
//                   totalAmt: totalAmt,
//                 );
//                 await DatabaseHelper.instance.insert(creditsale.toMap());
//                 Navigator.of(context).pop();  // Close the dialog
//                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Item created and saved')));
//               },
//               child: Text('Create'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   void initState() {
//     super.initState();
//     _fetchItemNames();  // Fetch the existing items when the screen is loaded
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//     return Scaffold(
//       backgroundColor: Appcolors().scafoldcolor,
//       appBar: AppBar(
//         toolbarHeight: screenHeight * 0.1,
//         backgroundColor: Appcolors().maincolor,
//         leading: Padding(
//           padding: const EdgeInsets.only(top: 20),
//           child: IconButton(
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             icon: Icon(
//               Icons.arrow_back_ios_new_sharp,
//               color: Colors.white,
//               size: 20,
//             ),
//           ),
//         ),
//         title: Center(
//           child: Padding(
//             padding: EdgeInsets.only(top: screenHeight * 0.02),
//             child: Text(
//               "Add Item To Sale",
//               style: appbarFonts(screenHeight * 0.02, Colors.white),
//             ),
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         physics: ScrollPhysics(),
//         child: Column(
//           children: [
//             // Item name input
//             TextFormField(
//               controller: _itemnameController,
//               decoration: InputDecoration(
//                 hintText: "Enter item name",
//                 suffixIcon: _itemSuggestions.isNotEmpty
//                     ? Icon(Icons.arrow_drop_down)
//                     : null,
//               ),
//               onChanged: (value) {
//                 setState(() {
//                   // Filter suggestions based on user input
//                   _itemSuggestions = DatabaseHelper.instance
//                       .getItemNames()
//                       .where((item) => item.contains(value))
//                       .toList();
//                 });
//               },
//             ),
//             // Suggestions dropdown (for simplicity, it can just show suggestions in a list below)
//             if (_itemSuggestions.isNotEmpty)
//               ListView.builder(
//                 shrinkWrap: true,
//                 itemCount: _itemSuggestions.length,
//                 itemBuilder: (context, index) {
//                   return ListTile(
//                     title: Text(_itemSuggestions[index]),
//                     onTap: () {
//                       _itemnameController.text = _itemSuggestions[index];
//                       setState(() {
//                         _itemSuggestions.clear(); // Clear the suggestions after selection
//                       });
//                     },
//                   );
//                 },
//               ),
//             // Other fields (Qty, Unit, Rate, etc.) go here...
//             // When user saves data, call _saveData()
//             ElevatedButton(
//               onPressed: _saveData,
//               child: Text("Save"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

