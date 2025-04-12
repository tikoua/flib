extension IterableExt<T> on Iterable<T> {
  /// 返回第一个满足条件的元素，如果没有则返回 null
  T? firstOrNullWhere(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }

  /// 返回最后一个满足条件的元素，如果没有则返回 null
  T? lastOrNullWhere(bool test(T element)) {
    try {
      return this.lastWhere(test);
    } catch (e) {
      return null;
    }
  }
}
