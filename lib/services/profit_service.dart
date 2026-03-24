class ProfitService {
  /// Calculates jewelry billing breakdown
  static Map<String, double> calculate({
    required double weight,          // grams
    required double goldRate,        // ₹ per gram
    required double making,          // ₹ making charge
    required double wastagePercent,  // %
  }) {
    // ================= GOLD VALUE =================
    final goldValue = weight * goldRate;

    // ================= WASTAGE =================
    final wastage = goldValue * (wastagePercent / 100);

    // ================= SUBTOTAL =================
    final subtotal = goldValue + making + wastage;

    // ================= GST =================
    final gst = subtotal * 0.03;

    // ================= FINAL TOTAL =================
    final total = subtotal + gst;

    // ================= COST & PROFIT =================
    final cost = goldValue;
    final profit = making + wastage;

    // ================= ROUNDING (₹ precision) =================
    double round(double v) => double.parse(v.toStringAsFixed(2));

    // ================= RETURN =================
    return {
      "total": round(total),
      "profit": round(profit),
      "gst": round(gst),
      "cost": round(cost),
      "goldValue": round(goldValue),
      "making": round(making),
      "wastage": round(wastage),
    };
  }
}