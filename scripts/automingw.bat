@echo off
setlocal enabledelayedexpansion

:: �Ǘ��Ҍ����̊m�F
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo �Ǘ��Ҍ�����v�����Ă��܂�...
    powershell -Command "Start-Process cmd -ArgumentList '/c %~dpnx0' -Verb RunAs"
    exit /b
)

:: �����m�F
echo ���̃X�N���v�g��MinGW-w64�̃C���X�g�[���Ɛݒ�������ōs���܂��B
echo.
set /p proceed="���s���܂����H (Y/N): "
if /i "!proceed!" neq "Y" (
    echo �Z�b�g�A�b�v�𒆎~���܂����B
    exit /b
)

:: �Z�b�g�A�b�v�t�@�C���̃_�E�����[�h
set "DOWNLOAD_URL=https://github.com/skeeto/w64devkit/releases/download/v2.1.0/w64devkit-x64-2.1.0.exe"
set "TARGET_DIR=%USERPROFILE%\Downloads\w64devkit-x64-2.1.0.exe"
echo MinGW-w64 �C���X�g�[���[���_�E�����[�h���Ă��܂�...
powershell -Command "Invoke-WebRequest -Uri '%DOWNLOAD_URL%' -OutFile '%TARGET_DIR%'"
if not exist "%TARGET_DIR%" (
    echo Error: �_�E�����[�h�Ɏ��s���܂����B�C���^�[�l�b�g�ڑ����m�F���Ă��������B
    pause
    exit /b
)

:: �t�@�C���̓W�J
echo C�h���C�u�����ɓW�J���Ă��܂�...
start /wait "" "%TARGET_DIR%" -o"C:" -y
if not exist "C:\w64devkit\bin\gcc.exe" (
    echo Error: �W�J�Ɏ��s���܂����B�C���X�g�[���[�t�@�C�����m�F���Ă��������B
    pause
    exit /b
)

:: PATH�̍X�V
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
    echo �V�X�e����PATH�𐳏�ɍX�V���܂����B
) else (
    echo PATH�ɂ͊���MinGW�̃f�B���N�g�����܂܂�Ă��܂��B
)

:: �ŏI�I�Ȏ菇
echo.
echo ============================================================
echo �Z�b�g�A�b�v���������܂����I
echo �ȉ��̎菇�ŃZ�b�g�A�b�v�������������m�F���Ă��������B
echo 1. �V�����R�}���h�v�����v�g���J��
echo 2. 'gcc -v' �Ɠ��͂��� Enter �L�[������
echo 3. �o�[�W������񂪕\������邱�Ƃ��m�F
echo ============================================================
pause