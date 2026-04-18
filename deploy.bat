@echo off
chcp 65001 >nul

echo ================================
echo Building Flutter Web...
echo ================================

flutter build web --base-href "/MahekSync/"

echo ================================
echo Copying files to docs...
echo ================================

xcopy build\web* docs\ /E /H /Y

echo ================================
echo Pushing to GitHub...
echo ================================

git add .
git commit -m "Update site"
git push origin main

echo ================================
echo DONE 🚀
echo ================================

pause
