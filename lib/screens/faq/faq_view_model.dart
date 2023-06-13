import 'package:flutter/cupertino.dart';
import 'package:wakmusic/models_v2/category.dart';
import 'package:wakmusic/models_v2/faq.dart';
import 'package:wakmusic/services/apis/api.dart';

class FAQViewModel with ChangeNotifier {
  late List<Category> _categories;
  late Map<Category, List<FAQ?>> _faqLists;
  bool _isFirst = true;

  List<Category> get categories => _categories;
  Map<Category, List<FAQ?>> get faqLists => _faqLists;

  FAQViewModel();

  void clear() {
    _categories = [Category.qnaAll];
    _faqLists = {
      Category.qnaAll: [],
    };
  }

  Future<void> getFAQ() async {
    if (_isFirst) {
      clear();
      _isFirst = false;
      _categories = await API.faq.categories;
      _categories.insert(0, Category.qnaAll);
      _faqLists = {
        Category.qnaAll: await API.faq.list,
      };
      _faqLists[Category.qnaAll]!.sort((a, b) {
        int categoryIdxA, categoryIdxB;
        categoryIdxA = _categories.indexOf(a!.category);
        categoryIdxB = _categories.indexOf(b!.category);
        return categoryIdxA.compareTo(categoryIdxB);
      });
      for (Category category in _categories) {
        if (category == Category.qnaAll) continue;
        _faqLists[category] = _faqLists[Category.qnaAll]!
            .where((faq) => faq!.category == category)
            .map((faq) => FAQ.clone(faq!))
            .toList();
      }
      notifyListeners();
    }
  }

  void onTap(FAQ faq) {
    faq.isExpanded = !faq.isExpanded;
    notifyListeners();
  }

  void collapseAll() {
    for (Category category in _categories) {
      for (FAQ? faq in _faqLists[category]!) {
        faq?.isExpanded = false;
      }
    }
    notifyListeners();
  }
}
