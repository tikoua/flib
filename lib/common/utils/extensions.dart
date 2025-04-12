//通用的扩展类
extension Nullablet<T> on T? {
  //实现类似kotlin中let函数
  R? let<R>(R Function(T t) operation) {
    final self = this;
    return self == null ? null : operation(self);
  }

  //实现类似kotlin中apply函数
  T? apply(dynamic Function(T t) operation) {
    final self = this;
    if (self != null) {
      operation(self);
    }
    return self;
  }
}
