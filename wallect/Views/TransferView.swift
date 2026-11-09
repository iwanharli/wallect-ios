#if !WIDGET_EXTENSION
import SwiftUI
import SwiftData

struct TransferView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @Query var wallets: [Wallet]
    
    @State private var amount: String = "0"
    @State private var sourceWallet: Wallet?
    @State private var destinationWallet: Wallet?
    @State private var notes: String = ""
    @State private var date: Date = .now
    
    // PRE-SELECTION SUPPORT
    var initialDestination: Wallet? = nil
    
    @State private var isProcessing = false
    @State private var animateGlow = false
    
    // Filtered lists
    private var availableSourceWallets: [Wallet] {
        wallets.filter { !$0.isArchived && $0.id != destinationWallet?.id }
    }
    
    private var availableDestWallets: [Wallet] {
        wallets.filter { !$0.isArchived && $0.id != sourceWallet?.id }
    }
    
    private var sourceAccent: Color {
        sourceWallet != nil ? Theme.walletAccent(for: sourceWallet!.walletType) : Theme.accent
    }
    
    private var destAccent: Color {
        destinationWallet != nil ? Theme.walletAccent(for: destinationWallet!.walletType) : Theme.accent
    }
    
    private var isValid: Bool {
        let val = CurrencyFormatter.toDouble(amount)
        let balanceOk = (sourceWallet?.currentBalance ?? 0) >= val
        return val > 0 && sourceWallet != nil && destinationWallet != nil && balanceOk
    }
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            // PREMIER AMBIENT BACKGROUND
            ZStack {
                Circle()
                    .fill(sourceAccent.opacity(0.12))
                    .frame(width: 450)
                    .blur(radius: 100)
                    .offset(x: animateGlow ? -120 : -180, y: animateGlow ? -250 : -200)
                
                Circle()
                    .fill(destAccent.opacity(0.08))
                    .frame(width: 400)
                    .blur(radius: 120)
                    .offset(x: animateGlow ? 150 : 200, y: animateGlow ? 180 : 250)
            }
            .animation(.easeInOut(duration: 5).repeatForever(autoreverses: true), value: animateGlow)
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header: Minimalist & Clean
                VStack(spacing: 12) {
                    // DRAG INDICATOR
                    Capsule()
                        .fill(Color.white.opacity(0.12))
                        .frame(width: 36, height: 4)
                    
                    Text("ALOKASI SALDO")
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(.white.opacity(0.3))
                        .tracking(2.5)
                }
                .padding(.top, 12)
                .padding(.bottom, 8)
                
                // FIXED HERO AMOUNT
                amountPlate
                    .padding(.horizontal, 40)
                    .padding(.bottom, 12)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // UNIFIED FLOW CONTAINER
                        VStack(spacing: 0) {
                            unifiedWalletPicker(
                                title: "DARI",
                                selected: $sourceWallet,
                                options: availableSourceWallets,
                                accent: sourceAccent,
                                isTop: true
                            )
                            
                            Divider()
                                .background(Color.white.opacity(0.05))
                                .padding(.horizontal, 16)
                            
                            unifiedWalletPicker(
                                title: "KE",
                                selected: $destinationWallet,
                                options: availableDestWallets,
                                accent: destAccent,
                                isTop: false
                            )
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 28)
                                .fill(.white.opacity(0.03))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 28)
                                        .stroke(.white.opacity(0.06), lineWidth: 1)
                                )
                        )
                        .padding(.horizontal, 40)
                        .padding(.vertical, 12)
                        
                        // BALANCE WARNING
                        if let source = sourceWallet {
                            let transferAmount = CurrencyFormatter.toDouble(amount)
                            if transferAmount > source.currentBalance {
                                balanceWarning(source: source)
                            }
                        }
                        
                        // OPTIONAL DETAILS (Notes & Date)
                        detailsStrip
                            .padding(.horizontal, 40)
                        
                        // MODERN KEYPAD
                        ModernKeypad(amount: $amount, accentColor: sourceAccent)
                            .padding(.top, 24)
                        
                        // CONFIRMATION BUTTON
                        confirmButton
                            .padding(.horizontal, 40)
                            .padding(.bottom, 48)
                    }
                    .padding(.top, 16)
                }
            }
        }
        .onAppear {
            ensureInitialWallets()
            animateGlow = true
        }
    }
    
    // MARK: - Subviews
    
    private func unifiedWalletPicker(title: String, selected: Binding<Wallet?>, options: [Wallet], accent: Color, isTop: Bool) -> some View {
        Menu {
            ForEach(options) { wallet in
                Button(action: {
                    HapticManager.shared.impact(.medium)
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        selected.wrappedValue = wallet
                    }
                }) {
                    Label(wallet.name, systemImage: wallet.icon)
                }
            }
        } label: {
            HStack(spacing: 16) {
                // Visual Indicator
                ZStack {
                    Circle()
                        .fill(accent.opacity(0.12))
                        .frame(width: 42, height: 42)
                    Image(systemName: selected.wrappedValue?.icon ?? (isTop ? "tray.and.arrow.down.fill" : "tray.and.arrow.up.fill"))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(accent)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 9, weight: .black))
                        .foregroundColor(.white.opacity(0.3))
                        .tracking(1.5)
                    
                    Text(selected.wrappedValue?.name ?? "Pilih Dompet")
                        .font(.system(size: 15, weight: .black))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("SALDO")
                        .font(.system(size: 8, weight: .black))
                        .foregroundColor(.white.opacity(0.2))
                    
                    if let wallet = selected.wrappedValue {
                        Text(CurrencyFormatter.format(wallet.currentBalance))
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                
                Image(systemName: "chevron.up.chevron.down")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.2))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
    }
    
    private var amountPlate: some View {
        VStack(spacing: 8) {
            Text(CurrencyFormatter.formatRawString(amount))
                .font(.system(size: 48, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .monospacedDigit()
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            
            Text("NOMINAL ALOKASI")
                .font(.system(size: 9, weight: .black))
                .foregroundColor(.white.opacity(0.3))
                .tracking(2)
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(.ultraThinMaterial.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 32)
                        .stroke(
                            LinearGradient(colors: [.white.opacity(0.15), .clear], startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: 1
                        )
                )
        )
    }
    
    private func balanceWarning(source: Wallet) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 14))
            Text("Saldo tidak mencukupi (\(CurrencyFormatter.format(source.currentBalance)))")
                .font(.system(size: 11, weight: .bold))
        }
        .foregroundColor(Theme.expense)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.white.opacity(0.04))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.expense.opacity(0.2), lineWidth: 1))
        .transition(.move(edge: .top).combined(with: .opacity))
    }
    
    private var detailsStrip: some View {
        HStack(spacing: 12) {
            // DATE PICKER
            HStack(spacing: 10) {
                Image(systemName: "calendar")
                    .font(.system(size: 14))
                    .foregroundColor(sourceAccent)
                DatePicker("", selection: $date, displayedComponents: .date)
                    .labelsHidden()
                    .colorScheme(.dark)
                    .tint(sourceAccent)
            }
            .padding(.horizontal, 16)
            .frame(height: 60)
            .background(.white.opacity(0.04))
            .cornerRadius(20)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(.white.opacity(0.08), lineWidth: 1))
            
            // NOTES
            HStack(spacing: 12) {
                Image(systemName: "pencil.and.outline")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.3))
                TextField("Tulis catatan...", text: $notes)
                    .font(.system(size: 13, weight: .bold))
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(.white.opacity(0.04))
            .cornerRadius(20)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(.white.opacity(0.08), lineWidth: 1))
        }
    }
    
    private var confirmButton: some View {
        Button(action: performTransfer) {
            HStack(spacing: 12) {
                if isProcessing {
                    ProgressView().tint(.black)
                } else {
                    Text("KONFIRMASI ALOKASI")
                    Image(systemName: "arrow.right.circle.fill")
                }
            }
            .font(.system(size: 15, weight: .black))
            .tracking(1.5)
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 68)
            .background(
                Group {
                    if isValid && !isProcessing {
                        LinearGradient(colors: [sourceAccent, sourceAccent.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    } else {
                        Color.white.opacity(0.08)
                    }
                }
            )
            .cornerRadius(24)
            .shadow(color: isValid ? sourceAccent.opacity(0.3) : .clear, radius: 20, y: 10)
        }
        .disabled(!isValid || isProcessing)
    }
    
    // MARK: - Logic
    
    private func ensureInitialWallets() {
        if sourceWallet == nil && !wallets.isEmpty {
            sourceWallet = wallets.first { $0.name == "Dompet Utama" } ?? wallets.first { !$0.isGoal && !$0.isArchived }
        }
        
        if destinationWallet == nil {
            if let initial = initialDestination {
                destinationWallet = initial
            } else if wallets.count > 1 {
                destinationWallet = wallets.first { $0.isGoal && !$0.isArchived && $0.id != sourceWallet?.id } ??
                                   wallets.first { !$0.isArchived && $0.id != sourceWallet?.id }
            }
        }
    }
    
    private func performTransfer() {
        guard let source = sourceWallet, let dest = destinationWallet else { return }
        let transferAmount = CurrencyFormatter.toDouble(amount)
        guard transferAmount > 0 else { return }
        
        HapticManager.shared.impact(.heavy)
        withAnimation { isProcessing = true }
        
        let outTx = Transaction(
            title: "Alokasi ke \(dest.name)",
            amount: transferAmount,
            category: "Sistem",
            date: date,
            note: notes,
            isExpense: true,
            wallet: source
        )
        
        let inTx = Transaction(
            title: "Alokasi dari \(source.name)",
            amount: transferAmount,
            category: "Sistem",
            date: date,
            note: notes,
            isExpense: false,
            wallet: dest
        )
        
        TransactionService.shared.createTransaction(outTx, context: modelContext)
        TransactionService.shared.createTransaction(inTx, context: modelContext)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation {
                isProcessing = false
                dismiss()
            }
        }
    }
}

#endif
