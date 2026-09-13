# Split Money 💸

A full-stack expense-sharing application inspired by Splitwise.  
Users can create groups, split expenses, track balances, settle payments, and manage shared expenses easily.

## ✨ Features

- 🔐 Signup & Login with JWT authentication
- 👥 Create groups and add members
- 🏷️ Group types — Home, Travel, Sports, Others
- 💰 Add and split expenses
- 📊 Automatic balance calculation
- 🤝 Settle Up
- 📜 Activity history
- 📱 Contact picker for adding members
- 🗄️ Backup & Restore groups
- 🤖 Money AI powered by Google Gemini
- 💬 Persistent AI chat history
- ⏳ AI chat history automatically expires after 30 days

## 🛠️ Tech Stack

**Frontend**
- Flutter & Dart
- Provider
- HTTP
- SharedPreferences
- flutter_contacts

**Backend**
- Node.js
- Express.js
- MongoDB Atlas
- Mongoose
- JWT
- bcrypt

**AI & Deployment**
- Google Gemini API
- Render
- GitHub

## 🏗️ Architecture

```text
Flutter
   ↓
Node.js + Express
   ↓
MongoDB Atlas
   ↓
Google Gemini API
```

## 📂 Project Structure

```text
split_money_project/
├── backend/
├── flutter_app/
├── .gitignore
├── README.md
├── package.json
└── package-lock.json
```

## 🚀 Run Locally

### Backend

```bash
cd backend
npm install
npm start
```

### Flutter

```bash
cd flutter_app
flutter pub get
flutter run
```

### Environment Variables

Create a `.env` file in the backend:

```env
PORT=5000
MONGO_URI=your_mongodb_connection_string
JWT_SECRET=your_jwt_secret
GEMINI_API_KEY=your_gemini_api_key
```

> Never commit `.env` or API keys to GitHub.

## 🌐 Backend

Production API:

`https://split-money-backend.onrender.com`

> Render free tier may take a few seconds to wake up after inactivity.

## 📦 Android Build

### APK

```bash
flutter build apk --release
```

### Play Store AAB

```bash
flutter build appbundle --release
```

## 🔮 Future Improvements

- Google Sign-In
- Push Notifications
- Expense Analytics
- Multi-Currency Support
- Export Expenses to PDF

## 👨‍💻 Author

**Himanshu Kumar**

GitHub: https://github.com/himanshukumar822
