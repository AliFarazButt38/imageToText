import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfToText extends StatefulWidget {
  const PdfToText({Key? key}) : super(key: key);

  @override
  State<PdfToText> createState() => _PdfToTextState();
}

class _PdfToTextState extends State<PdfToText> {
  String? text;
  File? uploadedFile;
  String? extractedText;
  bool isUploading = false;
  bool isExtracting = false;
  Future<void> readTextFromImage() async {
    final inputImage = InputImage.fromFile(uploadedFile!);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText =
    await textRecognizer.processImage(inputImage);
    text = recognizedText.text;

    textRecognizer.close();

    // Process the extracted text as required (e.g., display in a dialog).
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Extracted Text'),
          content: Text(text!),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _uploadFile() async {
    setState(() {
      isUploading = true;
      isExtracting = false;
      extractedText = null;
    });

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'jpg', 'jpeg', 'png'], // Specify allowed file extensions
    );

    if (result != null) {
      if (result.files.isNotEmpty) {
        String filePath = result.files.single.path!;
        // Check if the selected file has a PDF, DOCX, or Image extension
        if (filePath.toLowerCase().endsWith('.pdf') ||
            filePath.toLowerCase().endsWith('.docx') ||
            filePath.toLowerCase().endsWith('.jpg') ||
            filePath.toLowerCase().endsWith('.jpeg') ||
            filePath.toLowerCase().endsWith('.png')) {
          // Simulating a delay for demonstration purposes
          await Future.delayed(Duration(seconds: 2));
          setState(() {
            uploadedFile = File(filePath);
            isUploading = false;
          });
        } else {
          // Show an error message for invalid file type
          _showSnackBar("Invalid file type. Please select a PDF, DOCX, or image file.");
        }
      } else {
        setState(() {
          uploadedFile = null; // Reset uploadedFile if no file is selected
          isUploading = false;
        });
      }
    } else {
      setState(() {
        uploadedFile = null; // Reset uploadedFile if no file is selected
        isUploading = false;
      });
    }
  }

  Future<void> _pdfToText() async {
    setState(() {
      isExtracting = true;
    });

    if (uploadedFile == null) {
      // No file uploaded
      _showSnackBar("Please select a file first.");
      setState(() {
        isExtracting = false;
      });
      return;
    }

    if (uploadedFile!.path.toLowerCase().endsWith('.pdf')) {
      try {
        final PdfDocument document = PdfDocument(inputBytes: uploadedFile!.readAsBytesSync());
        // Extract the text from all the pages.
        String text = PdfTextExtractor(document).extractText();
        // Dispose the document.
        document.dispose();

        setState(() {
          extractedText = text;
          isExtracting = false;
        });
      } catch (e) {
        print(e.toString());
        _showSnackBar("Error extracting text. Please try again.");
        setState(() {
          isExtracting = false;
        });
      }
    } else if (uploadedFile!.path.toLowerCase().endsWith('.docx')) {
      // Add code for extracting text from DOCX files here
      _showSnackBar("Text extraction from DOCX files is not yet implemented.");
      setState(() {
        isExtracting = false;
      });
    } else {
      // Handle image file
      // Add code for extracting text from image files here
      _showSnackBar("Text extraction from image files is not yet implemented.");
      setState(() {
        isExtracting = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF to Text'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isExtracting)
              CircularProgressIndicator()
            else if (extractedText != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      extractedText!,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ElevatedButton(
              onPressed: () {
                if (uploadedFile != null && (uploadedFile!.path.toLowerCase().endsWith('.jpg') ||
                    uploadedFile!.path.toLowerCase().endsWith('.jpeg') ||
                    uploadedFile!.path.toLowerCase().endsWith('.png'))) {
                  readTextFromImage();
                } else {
                  _pdfToText();
                }
              },
              child: Text("Extract Text"),
            ),

          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _uploadFile();
        },
        child: Icon(Icons.attach_file),
      ),
    );
  }
}
