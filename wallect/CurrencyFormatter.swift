import Foundation

struct CurrencyFormatter {
    static let currencySymbol = "Rp"
    
    private static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "id_ID")
        formatter.groupingSeparator = "."
        formatter.currencySymbol = "Rp. "
        formatter.maximumFractionDigits = 0
        return formatter
    }()
    
    static func format(_ value: Double) -> String {
        return formatter.string(from: NSNumber(value: value)) ?? "Rp. 0"
    }
    
    static func formatRawString(_ input: String) -> String {
        // Remove everything except numbers
        let cleanInput = input.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        guard let number = Double(cleanInput) else { return "Rp. 0" }
        return format(number)
    }
    
    static func toDouble(_ input: String) -> Double {
        let cleanInput = input.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        return Double(cleanInput) ?? 0
    }
}
