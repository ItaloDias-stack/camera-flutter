import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

showPdfDetails(String pdfPath, BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
      topLeft: Radius.circular(20),
      topRight: Radius.circular(20),
    )),
    builder: (context) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          height: 350,
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.all(2),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: PDFView(
              filePath: pdfPath,
            ),
          ),
        ),
      );
    },
  );
}
