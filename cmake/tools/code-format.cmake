# Code formatting configuration with clang-format

# Find clang-format
find_program(CLANG_FORMAT "clang-format")

if(CLANG_FORMAT)
    message(STATUS "clang-format found: ${CLANG_FORMAT}")
    
    # Create .clang-format file if it doesn't exist
    if(NOT EXISTS "${CMAKE_SOURCE_DIR}/.clang-format")
        file(WRITE "${CMAKE_SOURCE_DIR}/.clang-format" 
"BasedOnStyle: LLVM
IndentWidth: 4
TabWidth: 4
UseTab: Never
ColumnLimit: 100
AllowShortFunctionsOnASingleLine: None
AllowShortIfStatementsOnASingleLine: false
AllowShortLoopsOnASingleLine: false
BreakBeforeBraces: Allman
IndentCaseLabels: true
PointerAlignment: Right
SortIncludes: true
")
    endif()
    
    # Add target to format all source files
    file(GLOB_RECURSE ALL_SOURCE_FILES 
        "${CMAKE_SOURCE_DIR}/src/*.c"
        "${CMAKE_SOURCE_DIR}/src/*.cpp"
        "${CMAKE_SOURCE_DIR}/src/*.h"
        "${CMAKE_SOURCE_DIR}/src/*.hpp"
        "${CMAKE_SOURCE_DIR}/include/*.h"
        "${CMAKE_SOURCE_DIR}/include/*.hpp"
    )
    
    add_custom_target(format
        COMMAND ${CLANG_FORMAT} -i -style=file ${ALL_SOURCE_FILES}
        COMMENT "Formatting source code with clang-format"
        VERBATIM
    )
else()
    message(WARNING "clang-format not found. Code formatting is disabled.")
endif()