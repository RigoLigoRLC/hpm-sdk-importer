
cmake_minimum_required(VERSION 3.20)

# SDK Config
set(BOARD hpm5301evklite)
set(HPM_BUILD_TYPE flash_xip)

# Import SDK
include(hpm-sdk-importer.cmake)

# Start a project. Toolchain file will be included here, must be after
# importing SDK
project(hello_world)
sdk_app_src(src/main.c)

generate_ide_projects()
