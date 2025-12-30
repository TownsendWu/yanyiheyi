/// 字符串工具类
/// 类似 Java 的 Apache Commons Lang StringUtils
class StringUtils {
  // 私有构造函数，防止实例化
  StringUtils._();

  /// 判断字符串是否为空（null 或空字符串或只有空白字符）
  ///
  /// 示例:
  /// ```dart
  /// StringUtils.isEmpty(null)              // true
  /// StringUtils.isEmpty('')                // true
  /// StringUtils.isEmpty('   ')             // true
  /// StringUtils.isEmpty('  \n  \t  ')      // true
  /// StringUtils.isEmpty('hello')           // false
  /// StringUtils.isEmpty('  hello  ')       // false
  /// ```
  static bool isEmpty(String? str) {
    if (str == null) {
      return true;
    }
    return str.trim().isEmpty;
  }

  /// 判断字符串是否不为空
  ///
  /// 示例:
  /// ```dart
  /// StringUtils.isNotEmpty(null)           // false
  /// StringUtils.isNotEmpty('')             // false
  /// StringUtils.isNotEmpty('   ')          // false
  /// StringUtils.isNotEmpty('hello')        // true
  /// ```
  static bool isNotEmpty(String? str) {
    return !isEmpty(str);
  }

  /// 判断字符串是否为空白（null 或空字符串或只有空白字符）
  /// 与 isEmpty 相同，但命名更符合语义
  ///
  /// 示例:
  /// ```dart
  /// StringUtils.isBlank(null)              // true
  /// StringUtils.isBlank('')                // true
  /// StringUtils.isBlank('   ')             // true
  /// StringUtils.isBlank('  \n  \t  ')      // true
  /// StringUtils.isBlank('hello')           // false
  /// ```
  static bool isBlank(String? str) {
    return isEmpty(str);
  }

  /// 判断字符串是否不为空白
  ///
  /// 示例:
  /// ```dart
  /// StringUtils.isNotBlank(null)           // false
  /// StringUtils.isNotBlank('')             // false
  /// StringUtils.isNotBlank('   ')          // false
  /// StringUtils.isNotBlank('hello')        // true
  /// ```
  static bool isNotBlank(String? str) {
    return !isBlank(str);
  }

  /// 如果字符串为空白，返回默认值，否则返回原字符串
  ///
  /// 示例:
  /// ```dart
  /// StringUtils.defaultIfBlank(null, 'default')      // 'default'
  /// StringUtils.defaultIfBlank('', 'default')        // 'default'
  /// StringUtils.defaultIfBlank('   ', 'default')     // 'default'
  /// StringUtils.defaultIfBlank('hello', 'default')   // 'hello'
  /// ```
  static String defaultIfBlank(String? str, String defaultValue) {
    return isBlank(str) ? defaultValue : str!;
  }

  /// 如果字符串为空，返回默认值，否则返回原字符串
  /// 注意：只检查 null 和空字符串，不检查空白字符
  ///
  /// 示例:
  /// ```dart
  /// StringUtils.defaultIfEmpty(null, 'default')      // 'default'
  /// StringUtils.defaultIfEmpty('', 'default')        // 'default'
  /// StringUtils.defaultIfEmpty('   ', 'default')     // '   '
  /// StringUtils.defaultIfEmpty('hello', 'default')   // 'hello'
  /// ```
  static String defaultIfEmpty(String? str, String defaultValue) {
    return (str == null || str.isEmpty) ? defaultValue : str;
  }

  /// 去除字符串两端的空白字符，如果为 null 返回空字符串
  ///
  /// 示例:
  /// ```dart
  /// StringUtils.trimToNull(null)              // null
  /// StringUtils.trimToNull('')                // null
  /// StringUtils.trimToNull('   ')             // null
  /// StringUtils.trimToNull('  hello  ')       // 'hello'
  /// ```
  static String? trimToNull(String? str) {
    if (str == null) {
      return null;
    }
    final trimmed = str.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  /// 去除字符串两端的空白字符，如果为 null 返回空字符串
  ///
  /// 示例:
  /// ```dart
  /// StringUtils.trimToEmpty(null)            // ''
  /// StringUtils.trimToEmpty('')              // ''
  /// StringUtils.trimToEmpty('  hello  ')     // 'hello'
  /// ```
  static String trimToEmpty(String? str) {
    return str?.trim() ?? '';
  }

  /// 截取字符串，最大长度为 maxLength
  /// 如果字符串长度超过 maxLength，会在末尾添加 '...'
  ///
  /// 示例:
  /// ```dart
  /// StringUtils.abbreviate('hello', 3)       // '...'
  /// StringUtils.abbreviate('hello', 5)       // 'hello'
  /// StringUtils.abbreviate('hello world', 8) // 'hello...'
  /// ```
  static String abbreviate(String str, int maxLength) {
    if (str.length <= maxLength) {
      return str;
    }
    return '${str.substring(0, maxLength)}...';
  }

  /// 将字符串列表合并为一个字符串，用分隔符连接
  ///
  /// 示例:
  /// ```dart
  /// StringUtils.join(['a', 'b', 'c'], ',')  // 'a,b,c'
  /// StringUtils.join(['a', 'b', 'c'], '-')  // 'a-b-c'
  /// StringUtils.join([], ',')                // ''
  /// ```
  static String join(List<String> parts, String separator) {
    return parts.join(separator);
  }
}
