import '../models/food_item.dart';

class FoodDatabase {
  static final List<FoodItem> foods = [
    // Cơm & tinh bột
    FoodItem(id: '1', name: 'Cơm trắng', calories: 130, protein: 2.7, carbs: 28, fat: 0.3, servingSize: '1 chén (100g)', emoji: '🍚'),
    FoodItem(id: '2', name: 'Cơm gạo lứt', calories: 110, protein: 2.5, carbs: 23, fat: 0.8, servingSize: '1 chén (100g)', emoji: '🍚'),
    FoodItem(id: '3', name: 'Bánh mì', calories: 250, protein: 9, carbs: 45, fat: 3, servingSize: '1 ổ', emoji: '🥖'),
    FoodItem(id: '4', name: 'Phở bò', calories: 400, protein: 25, carbs: 50, fat: 10, servingSize: '1 tô', emoji: '🍜'),
    FoodItem(id: '5', name: 'Bún bò Huế', calories: 500, protein: 30, carbs: 60, fat: 15, servingSize: '1 tô', emoji: '🍜'),
    FoodItem(id: '6', name: 'Bún chả', calories: 450, protein: 20, carbs: 55, fat: 18, servingSize: '1 suất', emoji: '🍜'),
    FoodItem(id: '7', name: 'Hủ tiếu', calories: 380, protein: 18, carbs: 55, fat: 8, servingSize: '1 tô', emoji: '🍜'),

    // Đạm
    FoodItem(id: '8', name: 'Ức gà nướng', calories: 165, protein: 31, carbs: 0, fat: 3.6, servingSize: '100g', emoji: '🍗'),
    FoodItem(id: '9', name: 'Trứng gà luộc', calories: 78, protein: 6, carbs: 0.6, fat: 5, servingSize: '1 quả', emoji: '🥚'),
    FoodItem(id: '10', name: 'Cá hồi áp chảo', calories: 208, protein: 20, carbs: 0, fat: 13, servingSize: '100g', emoji: '🐟'),
    FoodItem(id: '11', name: 'Thịt heo luộc', calories: 242, protein: 27, carbs: 0, fat: 14, servingSize: '100g', emoji: '🥩'),
    FoodItem(id: '12', name: 'Đậu phụ', calories: 76, protein: 8, carbs: 1.9, fat: 4.8, servingSize: '100g', emoji: '🧈'),
    FoodItem(id: '13', name: 'Tôm luộc', calories: 99, protein: 24, carbs: 0.2, fat: 0.3, servingSize: '100g', emoji: '🦐'),

    // Rau củ
    FoodItem(id: '14', name: 'Bông cải xanh', calories: 34, protein: 2.8, carbs: 7, fat: 0.4, servingSize: '100g', emoji: '🥦'),
    FoodItem(id: '15', name: 'Cà chua', calories: 18, protein: 0.9, carbs: 3.9, fat: 0.2, servingSize: '100g', emoji: '🍅'),
    FoodItem(id: '16', name: 'Dưa chuột', calories: 15, protein: 0.7, carbs: 3.6, fat: 0.1, servingSize: '100g', emoji: '🥒'),
    FoodItem(id: '17', name: 'Rau muống luộc', calories: 19, protein: 2.6, carbs: 3.1, fat: 0.2, servingSize: '100g', emoji: '🥬'),

    // Trái cây
    FoodItem(id: '18', name: 'Chuối', calories: 89, protein: 1.1, carbs: 23, fat: 0.3, servingSize: '1 quả', emoji: '🍌'),
    FoodItem(id: '19', name: 'Táo', calories: 52, protein: 0.3, carbs: 14, fat: 0.2, servingSize: '100g', emoji: '🍎'),
    FoodItem(id: '20', name: 'Cam', calories: 47, protein: 0.9, carbs: 12, fat: 0.1, servingSize: '100g', emoji: '🍊'),
    FoodItem(id: '21', name: 'Dưa hấu', calories: 30, protein: 0.6, carbs: 7.6, fat: 0.2, servingSize: '100g', emoji: '🍉'),

    // Đồ uống
    FoodItem(id: '22', name: 'Sữa tươi không đường', calories: 54, protein: 3.2, carbs: 4.8, fat: 2.4, servingSize: '100ml', emoji: '🥛'),
    FoodItem(id: '23', name: 'Sữa đậu nành', calories: 45, protein: 3.5, carbs: 3, fat: 1.8, servingSize: '100ml', emoji: '🥛'),
    FoodItem(id: '24', name: 'Cà phê đen', calories: 2, protein: 0.3, carbs: 0, fat: 0, servingSize: '1 ly', emoji: '☕'),
    FoodItem(id: '25', name: 'Trà sữa', calories: 300, protein: 3, carbs: 50, fat: 8, servingSize: '1 ly 500ml', emoji: '🧋'),
    FoodItem(id: '26', name: 'Nước dừa', calories: 19, protein: 0.7, carbs: 3.7, fat: 0.2, servingSize: '100ml', emoji: '🥥'),

    // Fast food & ăn vặt
    FoodItem(id: '27', name: 'Bánh mì ốp la', calories: 350, protein: 15, carbs: 40, fat: 14, servingSize: '1 ổ', emoji: '🥪'),
    FoodItem(id: '28', name: 'Gà rán', calories: 320, protein: 20, carbs: 15, fat: 20, servingSize: '1 miếng', emoji: '🍗'),
    FoodItem(id: '29', name: 'Pizza', calories: 270, protein: 11, carbs: 33, fat: 10, servingSize: '1 lát', emoji: '🍕'),
    FoodItem(id: '30', name: 'Bánh tráng trộn', calories: 280, protein: 8, carbs: 45, fat: 10, servingSize: '1 phần', emoji: '🥗'),
    FoodItem(id: '31', name: 'Xôi', calories: 220, protein: 5, carbs: 45, fat: 3, servingSize: '1 phần', emoji: '🍚'),
  ];

  static List<FoodItem> search(String query) {
    if (query.trim().isEmpty) return foods;
    final q = query.toLowerCase().trim();
    return foods.where((f) => f.name.toLowerCase().contains(q)).toList();
  }

  static FoodItem? findById(String id) {
    try {
      return foods.firstWhere((f) => f.id == id);
    } catch (e) {
      return null;
    }
  }
}