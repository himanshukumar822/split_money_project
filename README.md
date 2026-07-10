# Split Money 💸

Split Money is a Flutter-based expense sharing application inspired by Splitwise. It allows users to create groups, add expenses, calculate balances, settle payments, and track group activities with a simple and user-friendly interface.

---

## ✨ Features

- 🔐 User Authentication (Signup & Login)
- 👥 Create and Manage Groups
- ➕ Add Members to Groups
- 💰 Add and Split Expenses
- 📊 Automatic Balance Calculation
- 🤝 Settle Up Feature
- 📜 Activity History
- 📱 Contact Picker Integration
- ☁️ Backend deployed on Render
- 🗄️ MongoDB Atlas Database

---

## 🛠️ Tech Stack

### Frontend
- Flutter
- Dart
- Provider
- HTTP Package

### Backend
- Node.js
- Express.js
- MongoDB Atlas
- Mongoose
- JWT Authentication

### Deployment
- Render (Backend)
- GitHub

---

## 📂 Project Structure

```
split_money_project/
│
├── backend/
│   ├── config/
│   ├── controllers/
│   ├── models/
│   ├── routes/
│   ├── server.js
│   └── package.json
│
└── flutter_app/
    ├── lib/
    ├── android/
    ├── ios/
    └── pubspec.yaml
```

---

## 🚀 Installation

### Clone the repository

```bash
git clone https://github.com/himanshukumar822/split_money_project.git
```

### Backend

```bash
cd backend
npm install
npm start
```

### Flutter App

```bash
cd flutter_app
flutter pub get
flutter run
```

---

## 🌐 Backend

Backend is deployed on Render.

```
https://split-money-backend.onrender.com
```

> **Note:** Since the backend is hosted on Render's free tier, the first request after inactivity may take a few seconds while the server wakes up.

---

## 📱 APK

Release APK can be generated using:

```bash
flutter build apk --release
```

---

## 🔮 Future Improvements

- Google Sign-In
- Push Notifications
- Expense Analytics
- Multi-Currency Support
- Profile Pictures
- Dark Mode
- Export Expenses to PDF

---

## 👨‍💻 Author

**Himanshu Kumar**

GitHub: https://github.com/himanshukumar822

---

## 📄 License

This project is developed for educational and learning purposes.
