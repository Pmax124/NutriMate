import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/food_item.dart';
import '../models/user_profile.dart';

class AIService {
  // Lấy API key từ file .env
  static String get _apiKey => dotenv.env['OPENAI_API_KEY'] ?? '';

  /// 🍽 Nhận diện món ăn từ ảnh (dùng GPT-4o Vision)
  static Future<FoodItem> recognizeFoodFromImage(String base64Image) async {
    // Chế độ demo nếu không có API key
    if (_apiKey.isEmpty || _apiKey == 'YOUR_OPENAI_API_KEY_HERE') {
      return FoodItem(
        id: 'ai-${DateTime.now().millisecondsSinceEpoch}',
        name: 'Món ăn nhận diện (Demo)',
        calories: 350,
        protein: 20,
        carbs: 40,
        fat: 12,
        servingSize: '1 phần',
        emoji: '🍽️',
      );
    }

    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {
              'role': 'system',
              'content':
                  'Bạn là chuyên gia dinh dưỡng. Phân tích ảnh món ăn và trả về JSON: {"name":"tên món","calories":số,"protein":số,"carbs":số,"fat":số,"servingSize":"khẩu phần","emoji":"emoji"}. Chỉ trả về JSON, không giải thích.',
            },
            {
              'role': 'user',
              'content': [
                {'type': 'text', 'text': 'Phân tích món ăn trong ảnh.'},
                {
                  'type': 'image_url',
                  'image_url': {
                    'url': 'data:image/jpeg;base64,$base64Image'
                  }
                },
              ],
            },
          ],
          'response_format': {'type': 'json_object'},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        final parsed = jsonDecode(content);
        return FoodItem(
          id: 'ai-${DateTime.now().millisecondsSinceEpoch}',
          name: parsed['name'] ?? 'Món ăn',
          calories: (parsed['calories'] ?? 0).toDouble(),
          protein: (parsed['protein'] ?? 0).toDouble(),
          carbs: (parsed['carbs'] ?? 0).toDouble(),
          fat: (parsed['fat'] ?? 0).toDouble(),
          servingSize: parsed['servingSize'] ?? '1 phần',
          emoji: parsed['emoji'] ?? '🍽️',
        );
      } else {
        throw Exception('API error: ${response.statusCode}');
      }
    } catch (e) {
      print('AI Error: $e');
      rethrow;
    }
  }

  /// 💬 Chat với AI dinh dưỡng
  static Future<String> chat(String message, UserProfile? profile) async {
    if (_apiKey.isEmpty || _apiKey == 'YOUR_OPENAI_API_KEY_HERE') {
      return '''🤖 (Chế độ Demo)

Bạn hỏi: "$message"

💡 Mẹo chung:
• Ăn đủ protein (1.6-2g/kg cân nặng)
• Uống 2-3 lít nước/ngày
• Ngủ đủ 7-8 tiếng
• Ăn nhiều rau xanh

Để dùng AI thật, hãy thêm OpenAI API key vào file .env''';
    }

    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {
              'role': 'system',
              'content':
                  'Bạn là NutriBot - trợ lý dinh dưỡng tiếng Việt. Hồ sơ user: ${profile != null ? jsonEncode(profile.toJson()) : "chưa có"}. Trả lời ngắn gọn, thân thiện, có căn cứ khoa học.',
            },
            {'role': 'user', 'content': message},
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        return '❌ Lỗi kết nối AI. Vui lòng thử lại.';
      }
    } catch (e) {
      return '❌ Lỗi: $e';
    }
  }

  /// 📅 Gợi ý thực đơn
  static Future<String> suggestMealPlan(UserProfile? profile) async {
    return await chat('Gợi ý thực đơn 1 ngày phù hợp với mục tiêu của tôi', profile);
  }
}