import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/food_log.dart';
import '../models/food_item.dart';
import '../providers/food_provider.dart';
import '../services/ai_service.dart';

class ScanFoodScreen extends StatefulWidget {
  const ScanFoodScreen({super.key});

  @override
  State<ScanFoodScreen> createState() => _ScanFoodScreenState();
}

class _ScanFoodScreenState extends State<ScanFoodScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  bool _isLoading = false;
  FoodItem? _recognizedFood;
  String? _error;

  Future<void> _pickImage() async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Chọn nguồn ảnh'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, ImageSource.camera), child: Text('📷 Chụp ảnh')),
          TextButton(onPressed: () => Navigator.pop(ctx, ImageSource.gallery), child: Text('🖼️ Thư viện')),
        ],
      ),
    );

    if (source == null) return;

    final picked = await _picker.pickImage(source: source, imageQuality: 80);
    if (picked == null) return;

    setState(() {
      _imageFile = File(picked.path);
      _recognizedFood = null;
      _error = null;
    });

    await _recognizeFood();
  }

  Future<void> _recognizeFood() async {
    if (_imageFile == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final bytes = await _imageFile!.readAsBytes();
      final base64Image = base64Encode(bytes);
      final food = await AIService.recognizeFoodFromImage(base64Image);

      setState(() {
        _recognizedFood = food;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Lỗi: $e';
        _isLoading = false;
      });
    }
  }

  void _addToLog() {
    if (_recognizedFood == null) return;

    final log = FoodLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      food: _recognizedFood!,
      quantity: 1,
      mealType: 'snack',
      timestamp: DateTime.now(),
    );

    context.read<FoodProvider>().addFoodLog(log);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã thêm ${_recognizedFood!.name}')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quét món ăn'), backgroundColor: Color(0xFF2196F3), foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Image preview
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
                image: _imageFile != null ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover) : null,
              ),
              child: _imageFile == null ? Icon(Icons.camera_alt, size: 80, color: Colors.grey[400]) : null,
            ),
            SizedBox(height: 20),

            // Pick button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _pickImage,
                icon: Icon(Icons.camera_alt),
                label: Text(_imageFile == null ? 'Chụp/Chọn ảnh món ăn' : 'Chụp ảnh khác'),
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF2196F3), padding: EdgeInsets.symmetric(vertical: 16)),
              ),
            ),
            SizedBox(height: 20),

            // Loading
            if (_isLoading) CircularProgressIndicator(),

            // Error
            if (_error != null) Text(_error!, style: TextStyle(color: Colors.red), textAlign: TextAlign.center),

            // Recognized food
            if (_recognizedFood != null)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                color: Color(0xFFE3F2FD),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(_recognizedFood!.emoji, style: TextStyle(fontSize: 60)),
                      SizedBox(height: 12),
                      Text(_recognizedFood!.name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('${_recognizedFood!.calories.round()} kcal', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2196F3))),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _MacroChip(label: 'Protein', value: _recognizedFood!.protein),
                          _MacroChip(label: 'Carbs', value: _recognizedFood!.carbs),
                          _MacroChip(label: 'Fat', value: _recognizedFood!.fat),
                        ],
                      ),
                      SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _addToLog,
                          style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF4CAF50), padding: EdgeInsets.symmetric(vertical: 14)),
                          child: Text('Thêm vào nhật ký', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String label;
  final double value;

  const _MacroChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('${value.round()}g', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }
}