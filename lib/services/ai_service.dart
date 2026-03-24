class AIService {
  static String trend(List<double> data) {
    if (data.length < 2) return "stable";

    final diff = data.last - data.first;

    if (diff > 0) return "📈 Growth";
    if (diff < 0) return "📉 Decline";

    return "➖ Stable";
  }
}