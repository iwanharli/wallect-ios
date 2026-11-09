import SwiftUI
import SwiftData

struct DebtEditorSheet: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    var editDebt: Debt? = nil
    
    @State private var title = ""
    @State private var amount: String = ""
    @State private var personName = ""
    @State private var isDebt = true // true: Hutang, false: Piutang
    @State private var dueDate = Date()
    @State private var hasDueDate = false
    @State private var note = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Title/Header
                        VStack(spacing: 8) {
                            Text(editDebt == nil ? "Catat Pinjaman" : "Edit Catatan")
                                .font(.title2.bold())
                                .foregroundColor(.white)
                            Text("Catat uang yang Kamu pinjam atau pinjamkan")
                                .font(.caption)
                                .foregroundColor(Theme.textSecondary)
                        }
                        .padding(.top, 20)
                        
                        // Main Form
                        VStack(spacing: 20) {
                            // Amount Field (Premium Style)
                            VStack(spacing: 8) {
                                Text("NOMINAL")
                                    .font(.system(size: 10, weight: .black))
                                    .foregroundColor(Theme.textSecondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                TextField("0", text: $amount)
                                    .keyboardType(.decimalPad)
                                    .font(.system(size: 44, weight: .bold, design: .rounded))
                                    .foregroundColor(isDebt ? Theme.expense : Theme.income)
                                    .multilineTextAlignment(.center)
                                    .padding(.vertical, 10)
                                    .background(Color.white.opacity(0.03))
                                    .cornerRadius(15)
                            }
                            
                            // Segmented Picker for Type
                            HStack(spacing: 0) {
                                Button(action: { 
                                    HapticManager.shared.impact(.light)
                                    withAnimation { isDebt = true } 
                                }) {
                                    Text("SAYA PINJAM")
                                        .font(.system(size: 11, weight: .bold))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(isDebt ? Theme.expense.opacity(0.2) : Color.clear)
                                        .foregroundColor(isDebt ? Theme.expense : Theme.textSecondary)
                                }
                                
                                Button(action: { 
                                    HapticManager.shared.impact(.light)
                                    withAnimation { isDebt = false } 
                                }) {
                                    Text("SAYA MEMINJAMKAN")
                                        .font(.system(size: 11, weight: .bold))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(!isDebt ? Theme.income.opacity(0.2) : Color.clear)
                                        .foregroundColor(!isDebt ? Theme.income : Theme.textSecondary)
                                }
                            }
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), lineWidth: 1))
                            
                            // Input Fields
                            VStack(spacing: 15) {
                                CustomInputField(icon: "pencil.line", label: "JUDUL / KETERANGAN", text: $title, placeholder: "Contoh: Pinjam buat kopi")
                                CustomInputField(icon: "person.fill", label: "NAMA ORANG", text: $personName, placeholder: "Siapa pihak lainnya?")
                            }
                            
                            // Date Picker
                            VStack(alignment: .leading, spacing: 12) {
                                Toggle(isOn: $hasDueDate) {
                                    HStack {
                                        Image(systemName: "calendar")
                                            .foregroundColor(Theme.accent)
                                        Text("Deadline Pembayaran")
                                            .font(.subheadline)
                                            .foregroundColor(Theme.textMain)
                                    }
                                }
                                .toggleStyle(SwitchToggleStyle(tint: Theme.accent))
                                
                                if hasDueDate {
                                    DatePicker("", selection: $dueDate, displayedComponents: .date)
                                        .datePickerStyle(.graphical)
                                        .tint(Theme.accent)
                                        .background(Color.white.opacity(0.03))
                                        .cornerRadius(15)
                                }
                            }
                            .padding()
                            .background(Theme.cardBackground.opacity(0.4))
                            .cornerRadius(20)
                            
                            // Notes
                            VStack(alignment: .leading, spacing: 8) {
                                Text("CATATAN TAMBAHAN")
                                    .font(.system(size: 10, weight: .black))
                                    .foregroundColor(Theme.textSecondary)
                                    .padding(.leading, 5)
                                
                                TextField("Tulis catatan di sini...", text: $note, axis: .vertical)
                                    .lineLimit(3...5)
                                    .padding()
                                    .background(Theme.cardBackground.opacity(0.4))
                                    .cornerRadius(15)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Save Button
                        Button(action: saveDebt) {
                            Text(editDebt == nil ? "Simpan Catatan" : "Simpan Perubahan")
                                .font(.headline)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Theme.accent)
                                .cornerRadius(15)
                                .shadow(color: Theme.accent.opacity(0.4), radius: 15, x: 0, y: 5)
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        .padding(.bottom, 50)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Batal") { dismiss() }
                        .foregroundColor(Theme.textSecondary)
                }
            }
        }
        .onAppear {
            if let debt = editDebt {
                title = debt.title
                amount = String(format: "%.0f", debt.amount)
                personName = debt.personName
                isDebt = debt.isDebt
                if let dDate = debt.dueDate {
                    dueDate = dDate
                    hasDueDate = true
                }
                note = debt.note
            }
        }
    }
    
    private func saveDebt() {
        guard let debtAmount = Double(amount.replacingOccurrences(of: ",", with: ".")), !title.isEmpty else {
            return
        }
        
        HapticManager.shared.impact(.medium)
        
        if let existing = editDebt {
            existing.title = title
            existing.amount = debtAmount
            existing.personName = personName
            existing.isDebt = isDebt
            existing.dueDate = hasDueDate ? dueDate : nil
            existing.note = note
            
            // Sync Update
            SyncManager.shared.enqueue(endpoint: "debts", method: .post, body: existing.toDTO(), context: modelContext)
        } else {
            let newDebt = Debt(
                title: title,
                amount: debtAmount,
                personName: personName,
                isDebt: isDebt,
                dueDate: hasDueDate ? dueDate : nil,
                note: note
            )
            modelContext.insert(newDebt)
            
            // Sync Create
            SyncManager.shared.enqueue(endpoint: "debts", method: .post, body: newDebt.toDTO(), context: modelContext)
        }
        
        dismiss()
    }
}

struct CustomInputField: View {
    let icon: String
    let label: String
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 10, weight: .black))
                .foregroundColor(Theme.textSecondary)
                .padding(.leading, 5)
            
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .foregroundColor(Theme.accent)
                TextField(placeholder, text: $text)
                    .foregroundColor(.white)
            }
            .padding()
            .background(Theme.cardBackground.opacity(0.4))
            .cornerRadius(15)
        }
    }
}
