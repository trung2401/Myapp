class AttributeFilter {
  final String code;
  final String label;
  final List<FilterValue> values;

  AttributeFilter({
    required this.code,
    required this.label,
    required this.values,
  });

  factory AttributeFilter.fromJson(Map<String, dynamic> json) {
    return AttributeFilter(
      code: json['code'] ?? '',
      label: json['label'] ?? '',
      values: (json['values'] as List)
          .map((v) => FilterValue.fromJson(v))
          .toList(),
    );
  }
}

class FilterValue {
  final String value;
  final String label;

  FilterValue({required this.value, required this.label});

  factory FilterValue.fromJson(Map<String, dynamic> json) {
    return FilterValue(
      value: json['value'] ?? '',
      label: json['label'] ?? '',
    );
  }
}
