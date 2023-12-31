import 'package:flutter/cupertino.dart';
import 'package:wakmusic/models_v2/category.dart';
import 'package:wakmusic/models_v2/faq.dart';
import 'package:wakmusic/services/apis/api.dart';

class FAQViewModel with ChangeNotifier {
  List<Category> _categories = [];
  Map<Category, List<FAQ>> _faqLists = {};

  List<Category> get categories => _categories;
  Map<Category, List<FAQ>> get faqLists => _faqLists;

  FAQViewModel();

  Future<void> getFAQ() async {
    if (_categories.isNotEmpty) return;

    _categories = await API.faq.categories;
    _categories.insert(0, Category.qnaAll);

    _faqLists = {
      Category.qnaAll: await API.faq.list,
    };

    _faqLists[Category.qnaAll]!.sort((a, b) {
      return b.createAt.compareTo(a.createAt);
    });

    for (Category category in _categories) {
      if (category == Category.qnaAll) continue;
      _faqLists[category] = _faqLists[Category.qnaAll]!
          .where((faq) => faq.category == category)
          .map((faq) => FAQ.clone(faq))
          .toList();
    }
    notifyListeners();
  }

  void onTap(FAQ faq) {
    faq.isExpanded = !faq.isExpanded;
    notifyListeners();
  }

  void collapseAll() {
    bool notExpanded = true;
    for (Category category in _categories) {
      for (FAQ faq in _faqLists[category]!) {
        if (faq.isExpanded) {
          notExpanded = false;
          faq.isExpanded = false;
        }
      }
    }
    if (!notExpanded) notifyListeners();
  }
}
