import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/finance_provider.dart';
import '../models/transaction.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  TransactionType _type = TransactionType.expense;
  String? _category = 'other';
  bool _isRecurring = false;
  File? _image;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickImage({ImageSource source = ImageSource.camera}) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 80);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _scanQR() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (c) => Scaffold(
          appBar: AppBar(title: const Text('مسح رمز QR')),
          body: MobileScanner(
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  Navigator.of(context).pop(barcode.rawValue);
                }
              }
            },
          ),
        ),
      ),
    );
    if (result != null) {
      setState(() => _amountController.text = result);
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<FinanceProvider>(context, listen: false);
      final dateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );
      final tx = FinanceTransaction(
        id: const Uuid().v4(),
        title: _titleController.text,
        amount: double.parse(_amountController.text),
        date: dateTime,
        type: _type,
        category: _category,
        note: _noteController.text.isEmpty ? null : _noteController.text,
        isRecurring: _isRecurring,
        imagePath: _image?.path,
      );
      provider.addTransaction(tx);
      Navigator.of(context).pop();
    }
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('التقاط صورة'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(source: ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('من المعرض'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(source: ImageSource.gallery);
              },
            ),
            if (_image != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('حذف الصورة',
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  setState(() => _image = null);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('yyyy/MM/dd').format(_selectedDate);
    final timeStr = _selectedTime.format(context);

    return Scaffold(
      appBar: AppBar(title: const Text('إضافة عملية')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Type selector
              SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(
                    value: TransactionType.expense,
                    label: Text('مصروف'),
                    icon: Icon(Icons.remove),
                  ),
                  ButtonSegment(
                    value: TransactionType.income,
                    label: Text('دخل'),
                    icon: Icon(Icons.add),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (set) => setState(() => _type = set.first),
              ),
              const SizedBox(height: 20),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'العنوان (مثلاً: بقالة، راتب...)',
                  prefixIcon: Icon(Icons.edit_note),
                ),
                validator: (v) => v!.isEmpty ? 'يرجى إدخال العنوان' : null,
              ),
              const SizedBox(height: 16),

              // Amount
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'المبلغ (ج.م)',
                  prefixIcon: const Icon(Icons.attach_money),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.qr_code_scanner),
                    tooltip: 'مسح QR',
                    onPressed: _scanQR,
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    double.tryParse(v!) == null ? 'يرجى إدخال مبلغ صحيح' : null,
              ),
              const SizedBox(height: 16),

              // Category
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'الفئة',
                  prefixIcon: Icon(Icons.category),
                ),
                items: const [
                  DropdownMenuItem(value: 'food', child: Text('🍽️ طعام')),
                  DropdownMenuItem(
                      value: 'transportation', child: Text('🚌 مواصلات')),
                  DropdownMenuItem(value: 'rent', child: Text('🏠 إيجار')),
                  DropdownMenuItem(value: 'bills', child: Text('🧾 فواتير')),
                  DropdownMenuItem(value: 'health', child: Text('🏥 صحة')),
                  DropdownMenuItem(value: 'work', child: Text('💼 عمل')),
                  DropdownMenuItem(value: 'other', child: Text('📦 أخرى')),
                ],
                onChanged: (v) => setState(() => _category = v),
                value: _category,
              ),
              const SizedBox(height: 16),

              // Date & Time row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label:
                          Text(dateStr, style: const TextStyle(fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickTime,
                      icon: const Icon(Icons.access_time, size: 18),
                      label:
                          Text(timeStr, style: const TextStyle(fontSize: 13)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Note
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'ملاحظة (اختياري)',
                  prefixIcon: Icon(Icons.note),
                ),
              ),
              const SizedBox(height: 16),

              // Recurring toggle
              SwitchListTile(
                title: const Text('مصروف متكرر شهرياً؟'),
                value: _isRecurring,
                onChanged: (v) => setState(() => _isRecurring = v),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              const SizedBox(height: 16),

              // Image area
              GestureDetector(
                onTap: _showImageOptions,
                child: Container(
                  width: double.infinity,
                  height: _image != null ? 180 : 70,
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(12),
                    color:
                        Theme.of(context).colorScheme.surface.withOpacity(0.3),
                  ),
                  child: _image != null
                      ? Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(_image!,
                                  width: double.infinity,
                                  height: 180,
                                  fit: BoxFit.cover),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: CircleAvatar(
                                backgroundColor: Colors.black54,
                                radius: 16,
                                child: IconButton(
                                  icon: const Icon(Icons.edit,
                                      size: 14, color: Colors.white),
                                  onPressed: _showImageOptions,
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo,
                                color: Theme.of(context).colorScheme.onSurface),
                            const SizedBox(width: 8),
                            Text('إرفاق صورة (اختياري)',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 28),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'حفظ العملية',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
