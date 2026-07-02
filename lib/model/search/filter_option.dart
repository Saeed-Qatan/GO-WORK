class FilterOption {
  final String label;      // النص المعروض للمستخدم (بالعربي مترجم لو لزم)
  final String? rawValue;  // الاسم الخام القادم من الـ API (اختياري، للعرض/اللوق فقط)
  final String? id;        // الـ ID الحقيقي اللي لازم يرسل للـ backend للفلترة

  const FilterOption({required this.label, this.rawValue, this.id});
}