
# HPM SDK Importer

This project is for Visual Studio Code users. It's recommended to use Clangd extension with Microsoft C++ IntelliSense disabled.

This project can be seen as a simple HPMicro MCU project template. You can build a project from scratch with this rather than copy-pasting HPMicro's boilerplate.

Based on: **HPM SDK 1.7**

**I have only personally been using this project on HPM5301Evklite. Other platforms may work incorrectly and I would not fix them unless it's trivial or has actually affected my workflow.**

# Usage

1. Necessary files:

    - hpm-sdk-importer.cmake
    - .vscode/
    - CMakeLists.txt

    Copy files to your new project.

2. Initialization

    Edit .vscode/cmake-kits.json. It contains a "GCC (HPM SDK)" toolchain entry which defines an environment variable named "HPM_SDK_BASE". You need to fill in your machine's HPM SDK path. Note that the path is from the "hpm_sdk" directory inside the SDK folder, not the SDK folder root.

    Select "GCC (HPM SDK)" kit in the status bar of Visual Studio Code.

3. Configuration

    Open `CMakeLists.txt` and change configuration entries.

    Create project files like `main.c`, add them to your CMake project.

    Configure CMake project. SEGGER Embedded Studio project should be generated under `build/`.

# License

MIT
