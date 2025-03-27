import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sheraaccerpoff/utility/colors.dart';
import 'package:sheraaccerpoff/utility/fonts.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
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


  Future<pw.Document> _generatePdf() async {
  final pdf = pw.Document();

  pdf.addPage(pw.Page(build: (pw.Context context) {
    return pw.Column(
      children: [
        pw.SizedBox(height: 10),
        pw.Container(
          decoration: pw.BoxDecoration(border: pw.Border.all(color:  PdfColors.black,)),
          child: pw.Column(
            children: [
               pw.Container(
                    width: 500,
                    height: 30,
                    color: PdfColors.grey,
                    child: pw.Center(child: pw.Text("Preview",style: pw.TextStyle(fontSize: 14,color: PdfColors.black,fontBold: pw.Font.courierBold(),),)),
                  ),
                  pw.SizedBox(height: 10,),
                   pw.Container(
                    padding: pw.EdgeInsets.symmetric(horizontal: 8),
                    child: pw.Column(
                      children: [
                         pw.Row(
          children: [
            pw.Text("No         :",style: pw.TextStyle(fontSize: 11,color: PdfColors.black,fontBold: pw.Font.courierBold(),)),
            pw.SizedBox(width: 8,),
            pw.Text("${widget.no}", style: pw.TextStyle(fontSize: 10,color: PdfColors.black))
          ],
        ),
         pw.Row(
          children: [
            pw.Text("Date     :",style: pw.TextStyle(fontSize: 11,color: PdfColors.black,fontBold: pw.Font.courierBold(),)),
            pw.SizedBox(width: 8,),
            pw.Text("${widget.date.toString()}", style: pw.TextStyle(fontSize: 10,color: PdfColors.black))
          ],
        ),
         pw.Row(
          children: [
            pw.Text("Name  :",style: pw.TextStyle(fontSize: 11,color: PdfColors.black,fontBold: pw.Font.courierBold()),),
            pw.SizedBox(width: 8,),
            pw.Text("${widget.name}", style: pw.TextStyle(fontSize: 10,color: PdfColors.black))
         
          ],
        ),
                      ],
                    ),
                  ),
            pw.SizedBox(height: 20),
              // pw.Table(
              //   border: pw.TableBorder.symmetric(outside: pw.BorderSide.none, inside: pw.BorderSide.none),
              //   columnWidths: {
              //     0: pw.FixedColumnWidth(50),
              //     1: pw.FixedColumnWidth(40),
              //     2: pw.FixedColumnWidth(103),
              //     3: pw.FixedColumnWidth(193),
              //   },
              //   children: [
              //     pw.TableRow(
              //       children: [
              //         _buildHeaderCell2p(''),
              //         _buildHeaderCell2p(''),
              //         _buildHeaderCell2p(''),
              //         _buildHeaderCell2p(''),
              //       ],
              //     ),
              //     pw.TableRow(
              //       children: [
              //         _buildDataCell2p("NO"),
              //         _buildDataCell2p(" : "),
              //         _buildDataCell2p("${widget.no}"),
              //         _buildDataCell2p(""),
              //       ],
              //     ),
              //     pw.TableRow(
              //       children: [
              //         _buildDataCell2p("DATE"),
              //         _buildDataCell2p(" : "),
              //         _buildDataCell2p("${widget.date.toString()}"),
              //         _buildDataCell2p(""),
              //       ],
              //     ),
              //     pw.TableRow(
              //       children: [
              //         _buildDataCell2p("TO"),
              //         _buildDataCell2p(" : "),
              //         _buildDataCell2p("${widget.name.toString()}"),
              //         _buildDataCell2p(""),
              //       ],
              //     ),
              //     pw.TableRow(
              //       children: [
              //         _buildDataCellp(""),
              //         _buildDataCellp("  "),
              //         _buildDataCellp(""),
              //         _buildDataCellp(""),
              //       ],
              //     ),
              //   ],
              // ),

              pw.Table(
                border: pw.TableBorder(
                  verticalInside: pw.BorderSide(),
                  horizontalInside: pw.BorderSide.none,
                ),
                columnWidths: {
                  0: pw.FixedColumnWidth(12),
                  1: pw.FixedColumnWidth(120),
                  2: pw.FixedColumnWidth(50),
                  3: pw.FixedColumnWidth(50),
                  4: pw.FixedColumnWidth(50),
                  5: pw.FixedColumnWidth(100),
                },
                children: [
                  pw.TableRow(
                    children: [
                      _buildHeaderCellp('No'),
                      _buildHeaderCellp('Description of Goods'),
                      _buildHeaderCellp('Qty'),
                      _buildHeaderCellp('Unit'),
                      _buildHeaderCellp('Rate'),
                      _buildHeaderCellp('Total'),
                    ],
                  ),
                  for (var i = 0; i < widget.tempdata!.length; i++) ...[
                    pw.TableRow(
                      children: [
                        _buildDataCellp((i + 1).toString()),
                        _buildDataCellleftp(widget.tempdata![i]["itemname"] ?? ""),
                        _buildDataCellrightp(widget.tempdata![i]["qty"]?.toString() ?? ""),
                        _buildDataCellp(widget.tempdata![i]["no"] ?? ""),
                        _buildDataCellrightp(widget.tempdata![i]["rate"]?.toString() ?? ""),
                        _buildDataCellrightp(widget.tempdata![i]["total"]?.toString() ?? ""),
                      ],
                    ),
                  ],
                  pw.TableRow(
                    children: [
                      _buildDataCellp(""),
                      _buildDataCellp(""),
                      _buildDataCellp(""),
                      _buildDataCellp(""),
                      _buildDataCellp(""),
                      _buildDataCellp(""),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _buildDataCellp(""),
                      _buildDataCellp(""),
                      _buildDataCellp(""),
                      _buildDataCellp(""),
                      _buildDataCellp(""),
                      _buildDataCellp(""),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _buildDataCellp(""),
                      _buildDataCellp(""),
                      _buildDataCellp(""),
                      _buildDataCellp(""),
                      _buildDataCellp(""),
                      _buildDataCellp(""),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _buildHeaderCellp(' .'),
                      _buildHeaderCellp('Total'),
                      _buildHeaderCellrightp('${_qty.toString()}'),
                      _buildHeaderCellp('. '),
                      _buildHeaderCellp('. '),
                      _buildHeaderCellrightp('${_grandTotal.toString()}'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
       
        pw.Container(
          decoration: pw.BoxDecoration(border: pw.Border.all(color:  PdfColors.black,)),
          child: pw.Row(
            children: [
               pw.SizedBox(height: 18),
              pw.Expanded(
                flex: 1,
                child: pw.Container(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        children: [
                          _listcontentsp("Amount In Words"),
                          pw.Expanded(flex: 3, child: pw.Text(" :  ", style: pw.TextStyle(fontSize: 11,color: PdfColors.black))),
                        ],
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.symmetric(horizontal: 5),
                        child: pw.Text("$amountInWords", style: pw.TextStyle(fontSize: 11,color: PdfColors.black)),
                      ),
                    ],
                  ),
                ),
              ),
              pw.Expanded(
                flex: 1,
                child: pw.Container(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        children: [
                          _listcontentsp("Return Amount"),
                          pw.Expanded(
                            flex: 3,
                            child: pw.Align(
                              alignment: pw.Alignment.centerRight,
                              child: pw.Text("${""}  ",  style: pw.TextStyle(fontSize: 11,color: PdfColors.black)),
                            ),
                          ),
                        ],
                      ),
                      pw.Row(
                        children: [
                          _listcontentsp("BILL AMOUNT "),
                          pw.Expanded(
                            flex: 3,
                            child: pw.Align(
                              alignment: pw.Alignment.centerRight,
                              child: pw.Text("${_grandTotal}  ", style: pw.TextStyle(fontSize: 11,color: PdfColors.black)),
                            ),
                          ),
                        ],
                      ),
                      pw.Row(
                        children: [
                          _listcontentsp("OB"),
                          pw.Expanded(
                            flex: 3,
                            child: pw.Align(
                              alignment: pw.Alignment.centerRight,
                              child: pw.Text(" ${widget.ob} ", style: pw.TextStyle(fontSize: 11,color: PdfColors.black)),
                            ),
                          ),
                        ],
                      ),
                      pw.Row(
                        children: [
                          _listcontentsp("Cash Received"),
                          pw.Expanded(
                            flex: 3,
                            child: pw.Align(
                              alignment: pw.Alignment.centerRight,
                              child: pw.Text("${widget.cashreci}  ",style: pw.TextStyle(fontSize: 11,color: PdfColors.black)),
                            ),
                          ),
                        ],
                      ),
                      pw.Row(
                        children: [
                          _listcontentsp("Balance"),
                          pw.Expanded(
                            flex: 3,
                            child: pw.Align(
                              alignment: pw.Alignment.centerRight,
                              child: pw.Text("  ", style: pw.TextStyle(fontSize: 11,color: PdfColors.black)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }));

  return pdf;
}

pw.Widget _listcontentsp(String text) {
  return pw.Expanded(
    flex: 3,
    child: pw.Padding(
      padding: pw.EdgeInsets.only(left: 9, top: 5),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 10, color: PdfColors.black),
      ),
    ),
  );
}

pw.Widget _buildHeaderCellrightp(String text) {
  return pw.Container(
    padding: pw.EdgeInsets.all(8),
    decoration: pw.BoxDecoration(
      color: PdfColors.grey300, 
    ),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: 10,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.black,
      ),
      textAlign: pw.TextAlign.right, 
    ),
  );
}

pw.Widget _buildDataCellrightp(String text) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 8.0),
    decoration: pw.BoxDecoration(
      color: PdfColors.white, 
    ),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: 10,
        color: PdfColors.black,
      ),
      textAlign: pw.TextAlign.right,
    ),
  );
}

pw.Widget _buildDataCellleftp(String text) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 8.0),
    decoration: pw.BoxDecoration(
      color: PdfColors.white,  
    ),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: 10,
        color: PdfColors.black,
      ),
      textAlign: pw.TextAlign.left,
    ),
  );
}

pw.Widget _buildDataCell2p(String text) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 8.0),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: 10,
        color: PdfColors.black,
      ),
      textAlign: pw.TextAlign.center,
    ),
  );
}


pw.Widget _buildHeaderCellp(String text) {
  return pw.Container(
    padding: pw.EdgeInsets.all(8),
    decoration: pw.BoxDecoration(
      color: PdfColors.grey300,
    ),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: 10,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.black,
      ),
    ),
  );
}
pw.Widget _buildHeaderCell2p(String text) {
  return pw.Container(
    padding: pw.EdgeInsets.all(8),
    decoration: pw.BoxDecoration(
      color: PdfColors.grey300, 
    ),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: 10,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.black,
      ),
    ),
  );
}
pw.Widget _buildDataCellp(String text) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(8.0),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: 10,
        color: PdfColors.black,
      ),
      textAlign: pw.TextAlign.center,
    ),
  );
}

  void _downloadPdf() async {
    final pdf = await _generatePdf(); 

    Directory? downloadsDir;
    if (Platform.isAndroid) {
      downloadsDir = Directory('/storage/emulated/0/Download/');
    } else {
      downloadsDir = await getDownloadsDirectory();
    }
    final file = File('${downloadsDir!.path}/sales_preview.pdf');

    await file.writeAsBytes(await pdf.save());
    Fluttertoast.showToast(msg: 'PDF Downloaded');
  }
Future<void> _downloadPDF() async {
  try {
    var status = await Permission.storage.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Storage permission required!")),
      );
      return;
    }
    if (Platform.isAndroid && (await Permission.manageExternalStorage.isDenied)) {
      var permissionStatus = await Permission.manageExternalStorage.request();
      if (!permissionStatus.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Permission to manage external storage is required!")),
        );
        return;
      }
    }
    final pdf = await _generatePdf();
    final pdfBytes = await pdf.save(); 
    Directory? downloadsDir;
    if (Platform.isAndroid) {
      downloadsDir = Directory('/storage/emulated/0/Download');
    } else {
      downloadsDir = await getDownloadsDirectory();
    }

    if (downloadsDir == null || !downloadsDir.existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to access storage directory.")),
      );
      return;
    }
    final path = '${downloadsDir.path}/sales_preview.pdf';
    final file = File(path);
    await file.writeAsBytes(pdfBytes);

    Fluttertoast.showToast(msg: "PDF Downloaded Successfully");
    OpenFilex.open(path);
  } catch (e) {
    print("Error downloading or opening PDF: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to download or open PDF.")),
    );
  }
}
  void _sharePdf() async {
    final pdf = await _generatePdf(); 

    final directory = await getExternalStorageDirectory();
    final file = File('${directory!.path}/sales_preview.pdf');
    await file.writeAsBytes(await pdf.save());
    Share.shareXFiles([XFile(file.path)], text: 'Check out this Sales Preview PDF!');
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
            padding:  EdgeInsets.only(top: screenHeight*0.02, right: screenHeight*0.02),
            child: PopupMenuButton<String>(
              onSelected: (String selectedItem) async{
                if (selectedItem == 'Share PDF') {
                   _sharePdf();
                }else if (selectedItem== "Download PDF"){
                  _downloadPDF();
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem<String>(
                    value: 'Share PDF',
                    child: Text('Share PDF'),
                  ),
                  PopupMenuItem<String>(
                    value: 'Download PDF',
                    child: Text('Download PDF'),
                  ),
                ];
              },
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
padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),       
 child: Column(
          children: [
            SizedBox(height: screenHeight*0.03,),
            Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.black)),
              child: Column(
                
                children: [
                  Container(
                    width: screenHeight*0.5,
                    height: screenHeight*0.03,
                    color: Colors.grey,
                    child: Center(child: Text("Preview",style: getFonts(12, Colors.black),)),
                  ),
                  SizedBox(height: screenHeight*0.015,),
                   Container(
                    padding: EdgeInsets.symmetric(horizontal: screenHeight*0.01),
                    child: Column(
                      children: [
                         Row(
          children: [
            Text("No         :",style: getFonts(10,Colors.black),),
            SizedBox(width: screenHeight*0.02,),
            Text("${widget.no}", style: filedFonts())
          ],
        ),
         Row(
          children: [
            Text("Date     :",style: getFonts(10,Colors.black),),
            SizedBox(width: screenHeight*0.02,),
            Text("${widget.date.toString()}", style: filedFonts())
          ],
        ),
         Row(
          children: [
            Text("Name  :",style: getFonts(10,Colors.black),),
            SizedBox(width: screenHeight*0.02,),
            Text("${widget.name}", style: filedFonts())
         
          ],
        ),
                      ],
                    ),
                  ),
SizedBox(height: screenHeight*0.02,),
                  // Table(
                  //         border: TableBorder.symmetric(outside: BorderSide.none,inside: BorderSide.none),
                  //       columnWidths: {
                  //          0: FixedColumnWidth(50),
                  //         1: FixedColumnWidth(40),
                  //         2: FixedColumnWidth(103),
                  //         3: FixedColumnWidth(193),
                          
                  //       },
                  //       children: [
                  //           TableRow(
                  //           children: [
                              
                  //               _buildHeaderCell2(''),
                  //               _buildHeaderCell2(''),
                  //                _buildHeaderCell2('PREVIEW'),
                  //                _buildHeaderCell2(''),
                               
                  //           ],
                  //         ),
                  //         TableRow(
                  //           children: [
                  //            _buildDataCell2("NO"),
                  //         _buildDataCell2(" : "),
                  //         _buildDataCell2("${widget.no}"),
                  //         _buildDataCell2(""),
                  //           ]
                  //         ),
                  //         TableRow(
                  //           children: [
                  //            _buildDataCell2("DATE"),
                  //         _buildDataCell2(" : "),
                  //         _buildDataCell2("${widget.date.toString()}"),
                  //         _buildDataCell2(""),
                  //           ]
                  //         ),
                  //         TableRow(
                  //           children: [
                  //            _buildDataCell2("TO"),
                  //         _buildDataCell2(" : "),
                  //         _buildDataCell2("${widget.name.toString()}"),
                  //         _buildDataCell2(""),
                  //           ]
                  //         ),
                  //         TableRow(
                  //           children: [
                  //            _buildDataCell(""),
                  //         _buildDataCell("  "),
                  //         _buildDataCell(""),
                  //         _buildDataCell(""),
                  //           ]
                  //         ),
                          
                  //       ],                              
                  // ),
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
                         _buildDataCell((i + 1).toString()),
                          _buildDataCellleft(widget.tempdata![i]["itemname"] ?? ""),
                          _buildDataCellright(widget.tempdata![i]["qty"]?.toString() ?? ""),
                          _buildDataCell(widget.tempdata![i]["no"] ?? ""),
                          _buildDataCellright(widget.tempdata![i]["rate"]?.toString() ?? ""),
                          _buildDataCellright(widget.tempdata![i]["total"]?.toString() ?? ""),

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
                                 _buildHeaderCellright('${_qty.toString()}'),
                                 _buildHeaderCell(''),
                                 _buildHeaderCell(''),
                                 _buildHeaderCellright('${_grandTotal.toString()}'),
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
            Expanded(
              flex: 3, 
              child: Align(
                alignment: Alignment.centerRight,
                child: Text("${""}  ", style: filedFonts()),
              ),
            ),
          ],
        ),
        Row(
          children: [
            _listcontents("BILL AMOUNT "),
            Expanded(
              flex: 3, 
              child: Align(
                alignment: Alignment.centerRight, 
                child: Text("${_grandTotal}  ", style: filedFonts()),
              ),
            ),
          ],
        ),
        Row(
          children: [
            _listcontents("OB"),
            Expanded(
              flex: 3, 
              child: Align(
                alignment: Alignment.centerRight, 
                child: Text(" ${widget.ob} ", style: filedFonts()),
              ),
            ),
          ],
        ),
        Row(
          children: [
            _listcontents("Cash Received"),
            Expanded(
              flex: 3, 
              child: Align(
                alignment: Alignment.centerRight, 
                child: Text("${widget.cashreci}  ", style: filedFonts()),
              ),
            ),
          ],
        ),
        Row(
          children: [
            _listcontents("Balance"),
            Expanded(
              flex: 3, 
              child: Align(
                alignment: Alignment.centerRight, 
                child: Text("${widget.balance}", style: filedFonts()),
              ),
            ),
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
  Widget _buildHeaderCellright(String text) {
    return Container(
      color: Colors.grey,
      child: Padding(
        padding:  EdgeInsets.only(right: 5),
        child: Text(
          text,
          textAlign: TextAlign.right,
          style: TextStyle(fontWeight: FontWeight.bold,fontSize: 10),
          overflow: TextOverflow.ellipsis,  
          softWrap: false,  
        ),
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
   Widget _buildDataCellright(String text) {
    return Container(
      padding:  EdgeInsets.only(left: 4,right: 3,top: 6),
      child: Text(
        text,
        style: getFonts(10, Colors.black),
        textAlign: TextAlign.right,
      ),
    );
  }

   Widget _buildDataCellleft(String text) {
    return Container(
      padding: const EdgeInsets.all(6.0),
      child: Text(
        text,
        style: getFonts(10, Colors.black),
        textAlign: TextAlign.left,
      ),
    );
  }
   Widget _buildDataCell2(String text) {
        return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(
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
   Widget _listcontents2(String listtext) {
    return Expanded(
      flex: 1,
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