# Wallect — Your Premium Financial Companion 🏦

Wallect is a high-fidelity personal finance application designed for minimalist power users. Experience a secure, connected, and elegantly animated interface for managing your wealth across all devices.

![Wallect Banner Placeholder](https://via.placeholder.com/1200x400.png?text=Wallect+Finance+App)

## ✨ Core Features

*   **📱 Premium iOS Interface**: Glassmorphic UI with smooth entrance animations and interactive charts.
*   **📡 Hybrid Data Architecture**: API-first synchronization with shared backend and deep local caching.
*   **⏳ Persistent Sync Queue**: Seamlessly handle offline transactions that automatically sync when you're back online.
*   **💳 Multi-Wallet Support**: Dynamic wallet management (Cash, Bank, E-wallet) with personalized themes.
*   **📈 Smart Analytics**: Real-time spending insights with animated bar and donut charts.
*   **🔐 Secure Authentication**: Integrated Google & Apple Sign-In with JWT session security.

## 🛠️ Technology Stack

### iOS (Frontend)
*   **SwiftUI**: Modern, declarative UI framework.
*   **SwiftData**: Advanced local persistence for native performance.
*   **Async/Await**: Contemporary network concurrency.

### Fastify (Backend)
*   **TypeScript**: Type-safe development.
*   **Fastify**: Blazing fast, low-overhead web framework.
*   **Prisma & PostgreSQL**: Robust data modeling and reliable relational storage.
*   **Docker**: Multi-stage build for scalable, one-click production deployment.

## 🚀 Getting Started

### 1. Prerequisites
*   Xcode 15+
*   Node.js 18+
*   Docker (Optional, but recommended)

### 2. Backend Setup
```bash
cd wallect-api
npm install
# Configure your .env file
npx prisma generate
npm run dev
```

### 3. iOS Setup
1. Open the project in Xcode.
2. Select your development team and bundle identifier.
3. Build and Run! 🚀

## 🐳 Docker Deployment
```bash
cd wallect-api
docker-compose up -d
```

## 📄 License
This project is for internal development and personal use.

---

**Crafted with ❤️ by Iwan Harli**
