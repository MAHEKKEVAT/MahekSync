Here’s your **updated `mahek.md` (clean + improved + copy-friendly + pro version)** 👇

---

# 🚀 MahekSync - Developer Quick Guide

## 📦 Flutter Setup

```bash
flutter pub get
flutter run
```

---

## 🔄 Daily Git Workflow

### 👉 Start Work (IMPORTANT)

```bash
git pull origin main
```

### 👉 Verify manually (very important)

```bash
flutter build web --base-href "/MahekSync/"
xcopy build\web\* docs\ /E /H /Y
git add .
git commit -m "Add Payment Method"
git push origin main
```

---

### 👉 After Checking

```bash
flutter build web --base-href "/MahekSync/"
```

```bash
.\deploy.bat
```

---

## 🌿 Branch Workflow (Recommended 🚀)

### Create New Branch

```bash
git checkout -b feature/your-feature-name
```

### Switch Branch

```bash
git checkout main
```

### Push New Branch

```bash
git push origin feature/your-feature-name
```

---

## 🧹 Clean Build (Fix Errors)

```bash
flutter clean
flutter pub get
flutter run
```

---

## 🛠️ Useful Commands

### Check Status

```bash
git status
```

### Check Branch

```bash
git branch
```

### Check Remote

```bash
git remote -v
```

### Fix Flutter Issues

```bash
flutter doctor
```

---

## 🔥 Advanced (Useful for You)

### Force Pull (if conflict)

```bash
git fetch origin
git reset --hard origin/main
```

### Undo Last Commit

```bash
git reset --soft HEAD~1
```

### View Commit History

```bash
git log --oneline
```

---

## ⚠️ Important Rules

* Always run `git pull` before starting work
* Never work directly on `main` (use branches)
* Commit small and meaningful changes
* Use clear commit messages (feat, fix, update, etc.)
* Avoid editing same file on multiple devices simultaneously

---

## 💻 Workflow (Multi-Device)

Windows → Push
⬇
GitHub
⬇
Mac → Fetch → Pull

---

## 🧠 Notes

* Windows → VS Code / Terminal
* Mac → GitHub Desktop / Terminal
* Credentials are saved → no need to login again
* Always sync before switching devices

---

## 🚀 Pro Tips

* Use **VS Code Extensions**:

    * GitLens
    * Flutter
    * Dart

* Keep project clean:

```bash
flutter analyze
```

---

## 📁 Project Structure Tip

```
lib/
 ├── core/
 ├── features/
 ├── widgets/
 └── main.dart
```

---

🔥 Happy Coding, Mahek 🚀
