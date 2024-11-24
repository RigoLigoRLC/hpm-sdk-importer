# SPDX-License-Identifier: MIT
# Copyright 2024 RigoLigo <rigoligo@gmail.com>

# You must ensure that your HPM_SDK_BASE is either set in a system-global
# place or in your IDE. In any way, this env must contain a path to HPM
# SDK root, where you can find "VERSION" file describing SDK version.
#
# This script also assumes that you kept the SDK archive directory structure,
# which means, the parent directory of HPM_SDK_BASE should contain "toolchains"
# and "tools" directories.

if (NOT DEFINED ENV{HPM_SDK_BASE} OR $ENV{HPM_SDK_BASE} STREQUAL "")
    message(FATAL_ERROR "Please set environment variable HPM_SDK_BASE.")
endif ()

message(STATUS "HPM SDK Base: $ENV{HPM_SDK_BASE}/hpm_sdk")

# Cache some useful normalized paths.
cmake_path(SET _RIGO_HPM_SDK_PROLOGUE_TOOLS
    NORMALIZE $ENV{HPM_SDK_BASE}/../tools
)
cmake_path(SET _RIGO_HPM_SDK_PROLOGUE_TOOLCHAINS
    NORMALIZE $ENV{HPM_SDK_BASE}/../toolchains
)

if (
    NOT EXISTS $ENV{HPM_SDK_BASE} OR
    NOT EXISTS ${_RIGO_HPM_SDK_PROLOGUE_TOOLS} OR
    NOT EXISTS ${_RIGO_HPM_SDK_PROLOGUE_TOOLCHAINS}
)
    message(FATAL_ERROR
        "One or more directories weren't found in "
        "HPM_SDK_BASE parent directory: toolchains, tools."
    )
endif ()

# Add search paths for several tools that SDK will need.
# They'll be fetched by find_program(), and we will add their directories
# into CMAKE_PROGRAM_PATH.

if (
    NOT EXISTS ${_RIGO_HPM_SDK_PROLOGUE_TOOLS}/ninja OR
    NOT EXISTS ${_RIGO_HPM_SDK_PROLOGUE_TOOLS}/python3
)
    message(FATAL_ERROR
        "One or more directories weren't found in "
        "${_RIGO_HPM_SDK_PROLOGUE_TOOLS}: ninja, python3."
    )
endif ()

LIST(APPEND CMAKE_PROGRAM_PATH
    ${_RIGO_HPM_SDK_PROLOGUE_TOOLS}/ninja
    ${_RIGO_HPM_SDK_PROLOGUE_TOOLS}/python3
)

# HPM SDK requires a GNU Toolchain's root directory be specified in an env
# named "GNURISCV_TOOLCHAIN_PATH".
# It "seems" you can put multiple toolchains in there (don't know actually)
# but we make it possible to choose from if user actually had several of them.
#
# Iterate through all directories in the toolchains directory, and pick one
# as default if user has not specified one. And we do a simple check to see if
# that directory has file named like "bin/*gcc*" to make absolute sure we found
# a valid toolchain.
#
# User should set "RIGO_HPM_SDK_TOOLCHAIN" to a directory inside HPM SDK's
# toolchain directory to override the default behavior.

file(GLOB _RIGO_HPM_SDK_PROLOGUE_TOOLCHAIN_DIRS
    ${_RIGO_HPM_SDK_PROLOGUE_TOOLCHAINS}/*
)
if (NOT DEFINED ENV{GNURISCV_TOOLCHAIN_PATH} OR
    "$ENV{GNURISCV_TOOLCHAIN_PATH}" STREQUAL ""
    )
    foreach (TOOLCHAIN_ENTRY ${_RIGO_HPM_SDK_PROLOGUE_TOOLCHAIN_DIRS})
        if (NOT IS_DIRECTORY ${TOOLCHAIN_ENTRY})
            continue ()
        endif ()

        cmake_path(GET TOOLCHAIN_ENTRY FILENAME TOOLCHAIN_ENTRY_NAME)
        
        # Check if it's user specified directory
        if (DEFINED RIGO_HPM_SDK_TOOLCHAIN AND
            "${TOOLCHAIN_ENTRY_NAME}" STREQUAL "${RIGO_HPM_SDK_TOOLCHAIN}"
            )
            set($ENV{GNURISCV_TOOLCHAIN_PATH} ${TOOLCHAIN_ENTRY})
            break()
        endif ()

        # Check if it's a valid toolchain
        file(GLOB _RIGO_HPM_SDK_TOOLCHAIN_GCC
            ${TOOLCHAIN_ENTRY}/bin/*gcc*
        )
        if (DEFINED _RIGO_HPM_SDK_TOOLCHAIN_GCC)
            set(ENV{GNURISCV_TOOLCHAIN_PATH} ${TOOLCHAIN_ENTRY})
            break()
        endif ()
    endforeach ()
else ()
    message(STATUS "User forced toolchain: $ENV{GNURISCV_TOOLCHAIN_PATH}")
endif ()
# After trying, check if we had successfully detected
if ("$ENV{GNURISCV_TOOLCHAIN_PATH}" STREQUAL "")
    message(FATAL_ERROR
        "Appropriate GNU toolchain was not found.\n"
        "Please check if you have a working GNU RISC-V 32 toolchain in HPM SDK "
        "directory, or force an existing toolchain by specifying "
        "GNURISCV_TOOLCHAIN_PATH environment variable."
    )
else ()
    message(STATUS "Detected toolchain: $ENV{GNURISCV_TOOLCHAIN_PATH}")
endif ()

# Import SDK package.

find_package(hpm-sdk REQUIRED HINTS $ENV{HPM_SDK_BASE})
