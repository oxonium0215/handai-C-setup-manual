@echo off
setlocal enabledelayedexpansion

:: 管理者権限の確認
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo 管理者権限を要求しています...
    powershell -Command "Start-Process cmd -ArgumentList '/c %~dpnx0' -Verb RunAs"
    exit /b
)

:: 初期確認
echo このスクリプトはMinGW-w64のインストールと設定を自動で行います。
echo.
set /p proceed="続行しますか？ (Y/N): "
if /i "!proceed!" neq "Y" (
    echo セットアップを中止しました。
    exit /b
)

:: セットアップファイルのダウンロード
set "DOWNLOAD_URL=https://github.com/skeeto/w64devkit/releases/download/v2.1.0/w64devkit-x64-2.1.0.exe"
set "TARGET_DIR=%USERPROFILE%\Downloads\w64devkit-x64-2.1.0.exe"
echo MinGW-w64 インストーラーをダウンロードしています...
powershell -Command "Invoke-WebRequest -Uri '%DOWNLOAD_URL%' -OutFile '%TARGET_DIR%'"
if not exist "%TARGET_DIR%" (
    echo Error: ダウンロードに失敗しました。インターネット接続を確認してください。
    pause
    exit /b
)

:: ファイルの展開
echo Cドライブ直下に展開しています...
start /wait "" "%TARGET_DIR%" -o"C:" -y
if not exist "C:\w64devkit\bin\gcc.exe" (
    echo Error: 展開に失敗しました。インストーラーファイルを確認してください。
    pause
    exit /b
)

:: PATHの更新
set "NEW_PATH=C:\w64devkit\bin"
set "PATH_UPDATED=0"
for /f "tokens=2*" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path 2^>nul ^| find "REG_EXPAND_SZ"') do (
    set "current_path=%%b"
    echo ;%%b; | find /i ";%NEW_PATH%;" >nul
    if !errorLevel! neq 0 (
        setx /M PATH "%%b;%NEW_PATH%"
        set "PATH_UPDATED=1"
    )
)

if %PATH_UPDATED% equ 1 (
    echo システムのPATHを正常に更新しました。
) else (
    echo PATHには既にMinGWのディレクトリが含まれています。
)

:: 最終的な手順
echo.
echo ============================================================
echo セットアップが完了しました！
echo 以下の手順でセットアップが成功したか確認してください。
echo 1. 新しくコマンドプロンプトを開く
echo 2. 'gcc -v' と入力して Enter キーを押す
echo 3. バージョン情報が表示されることを確認
echo ============================================================
pause