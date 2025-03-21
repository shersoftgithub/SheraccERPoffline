import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sheraaccerpoff/utility/colors.dart';
import 'package:sheraaccerpoff/utility/fonts.dart';

class SalePDFscreen extends StatefulWidget {
  final File pdfFile;
  const SalePDFscreen(this.pdfFile, {super.key});

  @override
  State<SalePDFscreen> createState() => _ReciPDFscreenState();
}

class _ReciPDFscreenState extends State<SalePDFscreen> {
  int totalPages = 0;
  int currentPage = 0;

 Future<void> _downloadPDF() async {
  try {
    var status = await Permission.storage.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Storage permission required!")),
      );
      return;
    }
    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.isGranted) {
      } else {
        var permissionStatus = await Permission.manageExternalStorage.request();
        if (!permissionStatus.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Permission to manage external storage is required!")),
          );
          return;
        }
      }
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

    final path = '${downloadsDir.path}/Sale_report.pdf';
    File newFile = File(path);
    await newFile.writeAsBytes(await widget.pdfFile.readAsBytes());

    Fluttertoast.showToast(msg: "PDF Downloaded Successfully");
    OpenFilex.open(path);

  } catch (e) {
    print("Error downloading or opening PDF: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to download or open PDF.")),
    );
  }
}

  Future<void> _sharePDF() async {
    try {
      await Share.shareXFiles([XFile(widget.pdfFile.path)], text: 'Here is the PDF!');
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
            onPressed: () => Navigator.pop(context),
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
      body: PDFView(
        filePath: widget.pdfFile.path,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: true,
        pageFling: true,
        onRender: (pages) {
          setState(() => totalPages = pages ?? 0);
        },
        onPageChanged: (page, _) {
          setState(() => currentPage = page ?? 0);
        },
      ),
    );
  }
}
