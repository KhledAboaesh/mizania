import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/transaction.dart';

class PdfService {
  static Future<void> generateReport(
      List<FinanceTransaction> transactions) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text('Financial Report - Mizania',
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                context: context,
                data: <List<String>>[
                  <String>['Title', 'Amount', 'Date', 'Type'],
                  ...transactions.map((tx) => [
                        tx.title,
                        tx.amount.toStringAsFixed(2),
                        '${tx.date.day}/${tx.date.month}/${tx.date.year}',
                        tx.type == TransactionType.income ? 'Income' : 'Expense'
                      ])
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(
        bytes: await pdf.save(), filename: 'mizania_report.pdf');
  }
}
