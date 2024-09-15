import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pet_buddy/utils/colors.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class DoctorReport extends StatefulWidget {
  const DoctorReport({super.key});

  @override
  State<DoctorReport> createState() => _DoctorReportState();
}

class _DoctorReportState extends State<DoctorReport> {
  String? selectedMonth;
  String? selectedYear;
  bool isLoading = false;

  final List<String> months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  late List<String> years;
  pw.Document? reportPdf; // To store the generated PDF

  @override
  void initState() {
    super.initState();
    years = _generateYears();
  }

  List<String> _generateYears() {
    int currentYear = DateTime.now().year;
    return List<String>.generate(15, (index) => (currentYear - index).toString());
  }

  Future<void> _fetchDeathPetDetails() async {
    if (selectedMonth != null && selectedYear != null) {
      setState(() {
        isLoading = true;
      });

      try {
        // Convert selected month and year to a date range
        int monthIndex = months.indexOf(selectedMonth!) + 1; // Month as number
        String startOfMonth = '$selectedYear-${monthIndex.toString().padLeft(2, '0')}-01';
        DateTime startDate = DateTime.parse(startOfMonth);
        DateTime endDate = DateTime(startDate.year, startDate.month + 1, 0); // Last day of the month

        // Query to find pets where 'death_date' is within the selected month
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('dead_pets')
            .where('death_date', isGreaterThanOrEqualTo: startDate.toIso8601String())
            .where('death_date', isLessThanOrEqualTo: endDate.toIso8601String())
            .get();

        if (snapshot.docs.isNotEmpty) {
          // Generate PDF
          final pdf = pw.Document();

          pdf.addPage(
            pw.Page(
              build: (pw.Context context) {
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Pet Death Report - $selectedMonth $selectedYear',
                      style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 20),
                    pw.Table.fromTextArray(
                      headers: ['Pet Name', 'Gender', 'Age', 'Death Date', 'Death Reason'],
                      data: snapshot.docs.map((doc) {
                        return [
                          doc['name'] ?? 'N/A',
                          doc['gender'] ?? 'N/A',
                          doc['age'] ?? 'N/A',
                          doc['death_date'] ?? 'N/A',
                          doc['death_reason'] ?? 'N/A'
                        ];
                      }).toList(),
                    ),
                  ],
                );
              },
            ),
          );

          // Store the generated PDF for preview
          setState(() {
            reportPdf = pdf;
          });

          // Show PDF preview
          _previewPdf();
          _savePdfToStorage(pdf);
        } else {
          _showSnackBar('No pets found for the selected month and year.');
        }
      } catch (e) {
        _showSnackBar('Error fetching data: $e');
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      _showSnackBar('Please select both month and year.');
    }
  }


  void _previewPdf() {
    if (reportPdf != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('PDF Preview',style: TextStyle(color: Colors.white),),
              backgroundColor: const Color(0xFF68548f),
            ),
            body: PdfPreview(
              build: (format) => reportPdf!.save(),
              canChangePageFormat: false,
              pdfFileName: 'Pet_Death_Report_$selectedMonth$selectedYear.pdf',
            ),
          ),
        ),
      );
    }
  }

  Future<void> _savePdfToStorage(pw.Document pdf) async {
    try {
      // Obtain the path to the external storage directory
      final directory = await getExternalStorageDirectory();

      // Construct the path to the Downloads folder
      final downloadsDirectory = Directory('/storage/emulated/0/Download');

      // Check if the Downloads directory exists
      if (!await downloadsDirectory.exists()) {
        // Create the Downloads directory if it doesn't exist
        await downloadsDirectory.create(recursive: true);
      }

      // Define the path for the PDF file
      final path = "${downloadsDirectory.path}/Pet_Death_Report_$selectedMonth$selectedYear.pdf";
      final file = File(path);

      // Write the PDF to the file
      await file.writeAsBytes(await pdf.save());

      // Show a snackbar or similar to notify the user
      _showSnackBar("PDF saved to Downloads folder at $path");
    } catch (e) {
      _showSnackBar("Failed to save PDF: $e");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: Colors.white),
      debugShowCheckedModeBanner: false,
      title: 'Doctor Report',
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: secondaryColor,
          leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white)),
          title: const Text("Death Report", style: TextStyle(color: Colors.white)),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),
                DropdownButtonFormField<String>(
                  value: selectedYear,
                  hint: const Text("Choose Year"),
                  decoration: const InputDecoration(
                    labelText: 'Year',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: secondaryColor,
                      ),
                    ),
                    floatingLabelStyle: TextStyle(
                      color: secondaryColor,
                    ),
                  ),
                  isExpanded: true,
                  items: years.map<DropdownMenuItem<String>>((String year) {
                    return DropdownMenuItem<String>(
                      value: year,
                      child: Text(year),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedYear = newValue;
                    });
                  },
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: selectedMonth,
                  hint: const Text("Choose Month"),
                  decoration: const InputDecoration(
                    labelText: 'Month',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: secondaryColor,
                      ),
                    ),
                    floatingLabelStyle: TextStyle(
                      color: secondaryColor,
                    ),
                  ),
                  isExpanded: true,
                  items: months.map<DropdownMenuItem<String>>((String month) {
                    return DropdownMenuItem<String>(
                      value: month,
                      child: Text(month),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedMonth = newValue;
                    });
                  },
                ),
                const SizedBox(height: 30),
                InkWell(
                  onTap: isLoading ? null : _fetchDeathPetDetails,
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      color: isLoading ? Colors.grey : secondaryColor,
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      'Download Report',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
