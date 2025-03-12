import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sheraaccerpoff/utility/colors.dart';
import 'package:sheraaccerpoff/utility/fonts.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:number_to_words_english/number_to_words_english.dart';
import 'package:sheraaccerpoff/views/Home.dart';

class SalesPreview extends StatefulWidget {
  final List<Map<String, dynamic>>? tempdata;
    final List<Map<String, dynamic>>? Acctra;
    final String? no;
    final String? date;
    final String? add;
    final String? ob;
    final String? cashreci;
    final String? balance;
    final String? name;


  const SalesPreview({super.key,this.tempdata,this.Acctra,this.add,this.balance,this.cashreci,this.date,this.no,this.ob,this.name});

  @override
  State<SalesPreview> createState() => _SalesPreviewState();
}

class _SalesPreviewState extends State<SalesPreview> {

 late String amountInWords;
   @override
  void initState() {
    super.initState();
   _calculateGrandTotal();
    amountInWords = convertNumberToWords(_grandTotal);
  }

double _grandTotal = 0.0; 
double _qty = 0.0; 

void _calculateGrandTotal() {
  setState(() {
    _grandTotal = widget.tempdata!.fold(0.0, (sum, item) => sum + (double.tryParse(item['total'].toString()) ?? 0.0));
    _qty = widget.tempdata!.fold(0.0, (sum, item) => sum + (double.tryParse(item['qty'].toString()) ?? 0.0));

  });
}

 String convertNumberToWords(double number) {
    String words = NumberToWordsEnglish.convert(number.toInt()); 
    return words;
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
             Navigator.of(context).push(MaterialPageRoute(builder: (context)=>HomePageERP()));
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
            padding: EdgeInsets.only(top: screenHeight * 0.02),
            child: Text(
              "Sales Preview",
              style: appbarFonts(screenHeight * 0.02, Colors.white),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(top: screenHeight * 0.02, right: screenHeight*0.02),
            child: GestureDetector(
              onTap: () {},
              child: Icon(Icons.picture_as_pdf,color: Colors.white,size: screenHeight *0.03,),
            ),
          ),
           Padding(
            padding: EdgeInsets.only(top: screenHeight * 0.02, right: screenHeight*0.02),
            child: GestureDetector(
              onTap: () {},
              child: Icon(Icons.print,color: Colors.white,size: screenHeight *0.03,),
            ),
          ),
        ],
      ),
      body: Padding(
padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),        child: Column(
          children: [
            SizedBox(height: screenHeight*0.03,),
            Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.black)),
              child: Column(
                
                children: [
                  Table(
                          border: TableBorder.symmetric(outside: BorderSide.none,inside: BorderSide.none),
                        columnWidths: {
                           0: FixedColumnWidth(50),
                          1: FixedColumnWidth(40),
                          2: FixedColumnWidth(103),
                          3: FixedColumnWidth(193),
                          
                        },
                        children: [
                            TableRow(
                            children: [
                              
                                _buildHeaderCell2(''),
                                _buildHeaderCell2(''),
                                 _buildHeaderCell2('PREVIEW'),
                                 _buildHeaderCell2(''),
                               
                            ],
                          ),
                          TableRow(
                            children: [
                             _buildDataCell2("NO"),
                          _buildDataCell2(" : "),
                          _buildDataCell2("${widget.no}"),
                          _buildDataCell2(""),
                            ]
                          ),
                          TableRow(
                            children: [
                             _buildDataCell2("DATE"),
                          _buildDataCell2(" : "),
                          _buildDataCell2("${widget.date.toString()}"),
                          _buildDataCell2(""),
                            ]
                          ),
                          TableRow(
                            children: [
                             _buildDataCell2("TO"),
                          _buildDataCell2(" : "),
                          _buildDataCell2("${widget.name.toString()}"),
                          _buildDataCell2(""),
                            ]
                          ),
                          TableRow(
                            children: [
                             _buildDataCell(""),
                          _buildDataCell("  "),
                          _buildDataCell(""),
                          _buildDataCell(""),
                            ]
                          ),
                          
                        ],                              
                  ),
                  Table(
                    border: TableBorder(
                      verticalInside: BorderSide(),horizontalInside: BorderSide.none
                    ),
                        columnWidths: {
                           0: FixedColumnWidth(15),
                          1: FixedColumnWidth(120),
                          2: FixedColumnWidth(50),
                          3: FixedColumnWidth(50),
                          4: FixedColumnWidth(50),
                          5: FixedColumnWidth(100),
                        },
                        children: [
                            TableRow(
                            children: [
                                 _buildHeaderCell('No'),
                                 _buildHeaderCell('Description of Goods'),
                                 _buildHeaderCell('Qty'),
                                 _buildHeaderCell('Unit'),
                                 _buildHeaderCell('Rate'),
                                 _buildHeaderCell('Total'),
                            ],
                          ),
                          for (var i = 0; i < widget.tempdata!.length; i++) ...[
                        TableRow(
                          children: [
                          _buildDataCell(widget.tempdata![i]["no"] ?? ""),
_buildDataCell(widget.tempdata![i]["itemname"] ?? ""),
_buildDataCell(widget.tempdata![i]["qty"]?.toString() ?? ""),
_buildDataCell(widget.tempdata![i]["no"] ?? ""),
_buildDataCell(widget.tempdata![i]["rate"]?.toString() ?? ""),
_buildDataCell(widget.tempdata![i]["total"]?.toString() ?? ""),

                          ],
                        ),
                      ],
                          TableRow(
                            children: [
                          _buildDataCell(""),
                          _buildDataCell(""),
                          _buildDataCell(""),
                          _buildDataCell(""),
                          _buildDataCell(""),
                          _buildDataCell(""),
                            ]
                          ),
                          TableRow(
                            children: [
                          _buildDataCell(""),
                          _buildDataCell(""),
                          _buildDataCell(""),
                          _buildDataCell(""),
                          _buildDataCell(""),
                          _buildDataCell(""),
                            ]
                          ),
                          TableRow(
                            children: [
                          _buildDataCell(""),
                          _buildDataCell(""),
                          _buildDataCell(""),
                          _buildDataCell(""),
                          _buildDataCell(""),
                          _buildDataCell(""),
                            ]
                          ),
                          TableRow(
                            children: [
                                 _buildHeaderCell(''),
                                 _buildHeaderCell('Total'),
                                 _buildHeaderCell('${_qty.toString()}'),
                                 _buildHeaderCell(''),
                                 _buildHeaderCell(''),
                                 _buildHeaderCell('${_grandTotal.toString()}'),
                            ],
                          ),
                        ],                              
                  ),
                ],
              ),
            ),
            Container(
                          decoration: BoxDecoration(border: Border.all(color: Colors.black)),
            
              child: Row(
                children: [
                  Expanded(
                    flex: 1, 
                    child: Container(
                      
                      child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                Row(
                  children: [
                    _listcontents("Amount In Words"),
                    Expanded(flex: 3, child: Text(" :  ", style: filedFonts())),
                  ],
                ),
                Padding(
                  padding:  EdgeInsets.symmetric(horizontal: screenHeight*0.012),
                  child: Text("$amountInWords",style: getFonts(10, Colors.black),),
                ), 
              ],
                      ),
                    ),
                  ),
                  
                  Expanded(
                    flex: 1, 
                    child: Container(
                      child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                Row(
                  children: [
                    _listcontents("Return Amount"),
                    Expanded(flex: 3, child: Text(" :${""}  ", style: filedFonts())),
                  ],
                ),
                Row(
                  children: [
                    _listcontents("BILL AMOUNT :"),
                    Expanded(flex: 3, child: Padding(
                      padding:  EdgeInsets.symmetric(horizontal: screenHeight*0.03),
                      child: Text("${_grandTotal}  ", style: filedFonts()),
                    )),
                  ],
                ),
                Row(
                  children: [
                    _listcontents("OB"),
                    Expanded(flex: 3, child: Text(" : ${widget.ob} ", style: filedFonts())),
                  ],
                ),
                Row(
                    children: [
                    _listcontents("Cash Received"),
                    Expanded(flex: 3, child: Text(" :${widget.cashreci}  ", style: filedFonts())),
                  ],
                ),
                Row(
                    children: [
                    _listcontents("Balance"),
                    Expanded(flex: 3, child: Text(" :  ", style: filedFonts())),
                  ],
                ),
              ],
                      ),
                    ),
                  ),
                ],
              ),
            )
        
          ],
        ),
      ),
    );
  } 

  Widget _buildHeaderCell(String text) {
    return Container(
      color: Colors.grey,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold,fontSize: 10),
        overflow: TextOverflow.ellipsis,  
        softWrap: false,  
      ),
    );
  }
    Widget _buildHeaderCell2(String text) {
    return Container(
      color: Colors.grey,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold,),
        overflow: TextOverflow.ellipsis,  
        softWrap: false,  
      ),
    );
  }

    Widget _buildDataCell(String text) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: getFonts(10, Colors.black),
        textAlign: TextAlign.center,
      ),
    );
  }
   Widget _buildDataCell2(String text) {
    return Container(
padding: const EdgeInsets.symmetric( horizontal: 8.0),      child: Text(
        text,
        style: getFonts(10, Colors.black),
        textAlign: TextAlign.center,
      ),
    );
  }
   Widget _listcontents(String listtext) {
    return Expanded(
      flex: 3,
      child: Padding(
        padding: const EdgeInsets.only(left: 9, top: 5),
        child: Text(
          listtext,
          style: getFonts(10, Colors.black),
        ),
      ),
    );
  }
}