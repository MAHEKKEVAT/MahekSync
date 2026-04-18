@echo off
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
git commit -m "Auto deploy update"
git push origin main

echo ================================
echo DONE 🚀 Your site is updating...
echo ================================

pause
