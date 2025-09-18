# Portfolio.AI

Portfolio.AI is a modern iOS app for smart investment management, built with SwiftUI. It leverages Supabase for backend services and integrates Google Gemini for AI-powered insights.

---


## 🚀 Features

- **Secure Authentication** (Google Sign-In)
- **Portfolio Tracking** and Analysis
- **AI-Powered Investment Advice** (Gemini API)
- **Modern SwiftUI Interface**
- **Onboarding Flow** for new users
- **Custom Theming** and Dark Mode support

---

## Onboarding and Login
<img src="https://github.com/user-attachments/assets/d411ef8d-6a62-4589-ae34-fd49b024380e"  width="270" style="padding-right: 200px;"/>

## Home Screen and Portfolio Screen Empty States
<img src="https://github.com/user-attachments/assets/0abc2f45-9108-49c2-8052-e092f221c056"  width="270" style="padding-right: 200px;"/>


## Portfolio Ready State
<img src="https://github.com/user-attachments/assets/d68cd380-721f-4255-a1a9-5d64cd5c52ca"  width="270" style="padding-right: 200px;"/>

## Analysis State
<img src="https://github.com/user-attachments/assets/6bb78748-eafe-44d2-b34e-da2d07e7f62e"  width="270" style="padding-right: 200px;"/>

## Portfolio Analysis
<img src="https://github.com/user-attachments/assets/daeb7d20-706e-4d48-868f-4e72105909c9"  width="270" style="padding-right: 200px;"/>

## Theme
<img src="https://github.com/user-attachments/assets/fa82e9ce-9169-4c72-a7a2-71857100565f"  width="270" style="padding-right: 200px;"/>




## 🛠️ Project Structure

```
Portfolio.AI/
├── Core/
│   ├── config/           # AppConfig and environment management
│   └── utils/            # Utilities (e.g., ClearBackgroundView)
├── Module/
│   ├── Onboarding/       # Login and onboarding flows
│   └── Home/             # Main app features and widgets
|   └── Settings/         # User Settings
|   └── Portfolio/        # Add stocks page
├── Assets/               # Images, colors, and icons
├── Info.plist
├── Dev.xcconfig          # Development environment variables
└── ...
```

---

## ⚙️ Environment Setup

1. **Clone the repository**
2. **Install dependencies** (if any, e.g., via Swift Package Manager)
3. **Configure environment variables:**
   - Edit `Dev.xcconfig` with your Supabase and Gemini API keys:
     ```
     SUPABASE_INIT_URL=your-supabase-url
     ANON_KEY=your-supabase-anon-key
     GEMINI_API_KEY=your-gemini-api-key
     ```
   - In `Info.plist`, reference these variables:
     ```xml
     <key>SUPABASE_INIT_URL</key>
     <string>$(SUPABASE_INIT_URL)</string>
     <key>ANON_KEY</key>
     <string>$(ANON_KEY)</string>
     <key>GEMINI_API_KEY</key>
     <string>$(GEMINI_API_KEY)</string>
     ```

4. **Open in Xcode** and select the appropriate scheme.

---

## 🏗️ Building & Running

- Open `Portfolio.AI.xcodeproj` in Xcode.
- Select your target device or simulator.
- Build and run (`⌘R`).

---

## 🔒 Security Notes

- **Never commit real production API keys** to the repository.
- Use `.xcconfig` and CI/CD for managing secrets in production.

---

## 🤝 Contributing

Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.

---

## 📄 License

[MIT](LICENSE)

---

## 📬 Contact

For questions or support, please contact [Saransh Singhal](mailto:singhalsaransh40@gmail.com).
