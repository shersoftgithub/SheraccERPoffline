import 'dart:io';
import 'dart:typed_data';
import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sheraaccerpoff/utility/colors.dart';
import 'package:sheraaccerpoff/utility/fonts.dart';

class PayPDFscreen extends StatefulWidget {
  final File pdfFile;

  const PayPDFscreen(this.pdfFile, {super.key});

  @override
  State<PayPDFscreen> createState() => _SalePDFscreenState();
}

class _SalePDFscreenState extends State<PayPDFscreen> {
  late Future<PDFDocument> _pdfDocumentFuture;

  @override
  void initState() {
    super.initState();
    _pdfDocumentFuture = loadDocument();
  }

  Future<PDFDocument> loadDocument() async {
    try {
      if (!widget.pdfFile.existsSync()) {
        throw Exception("File does not exist: ${widget.pdfFile.path}");
      }
      print("Loading PDF from: ${widget.pdfFile.path}");

      return await PDFDocument.fromFile(widget.pdfFile);
    } catch (e) {
      print("Error loading PDF: $e");
      rethrow;
    }
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
    Directory? downloadsDir;
    if (Platform.isAndroid) {
      downloadsDir = Directory('/storage/emulated/0/Download/');
    } else {
      downloadsDir = await getDownloadsDirectory();
    }

    if (downloadsDir == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to access storage directory.")),
      );
      return;
    }
    final path = '${downloadsDir.path}/Payment_report.pdf';
    File newFile = File(path);
    Uint8List bytes = await widget.pdfFile.readAsBytes();
    await newFile.writeAsBytes(bytes);
   Fluttertoast.showToast(msg: "PDF Download Succesfully");
    OpenFilex.open(path);
  } catch (e) {
    print("Error downloading PDF: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to download PDF.")),
    );
  }
}

  Future<void> _sharePDF() async {
    try {
      String filePath = widget.pdfFile.path;
            await Share.shareXFiles([XFile(filePath)], text: 'Here is the PDF!');
    } catch (e) {
      print("Error sharing PDF: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to share PDF.")),
      );
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
              "PDF Viewer",
              style: appbarFonts(screenWidth * 0.04, Colors.white),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: IconButton(
              onPressed: _downloadPDF,
              icon: Icon(Icons.download, color: Colors.white),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: IconButton(
              onPressed: _sharePDF,
              icon: Icon(Icons.share, color: Colors.white),
            ),
          ),
        ],
      ),
      body: FutureBuilder<PDFDocument>(
        future: _pdfDocumentFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading PDF: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return PDFViewer(
              backgroundColor: Appcolors().scafoldcolor,
              document: snapshot.data!,
            );
          } else {
            return const Center(child: Text('No PDF document found.'));
          }
        },
      ),
    );
  }
}
