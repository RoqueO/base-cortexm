# Static Analysis Configuration

# Try to find clang-tidy
find_program(CLANG_TIDY "clang-tidy")

if(CLANG_TIDY)
    message(STATUS "clang-tidy found: ${CLANG_TIDY}")
    
    # Create .clang-tidy file if it doesn't exist
    if(NOT EXISTS "${CMAKE_SOURCE_DIR}/.clang-tidy")
        file(WRITE "${CMAKE_SOURCE_DIR}/.clang-tidy" 
"Checks: '
  bugprone-*,
  cert-*,
  cppcoreguidelines-*,
  clang-analyzer-*,
  misc-*,
  performance-*,
  portability-*,
  readability-*,
  -cppcoreguidelines-avoid-magic-numbers,
  -readability-magic-numbers'
WarningsAsErrors: ''
HeaderFilterRegex: '.*'
FormatStyle: file
")
    endif()
    
    # Set clang-tidy command for all targets
    set(CMAKE_C_CLANG_TIDY ${CLANG_TIDY})
    set(CMAKE_CXX_CLANG_TIDY ${CLANG_TIDY})
    
    # Add target to run clang-tidy manually
    file(GLOB_RECURSE ALL_SOURCE_FILES 
        "${CMAKE_SOURCE_DIR}/src/*.c"
        "${CMAKE_SOURCE_DIR}/src/*.cpp"
    )
    
    add_custom_target(clang-tidy
        COMMAND ${CLANG_TIDY} ${ALL_SOURCE_FILES} -- -I${CMAKE_SOURCE_DIR}/include
        COMMENT "Running clang-tidy analysis"
        VERBATIM
    )
else()
    message(WARNING "clang-tidy not found. Static analysis is disabled.")
endif()

# Try to find cppcheck
find_program(CPPCHECK "cppcheck")

if(CPPCHECK)
    message(STATUS "cppcheck found: ${CPPCHECK}")
    
    add_custom_target(cppcheck
        COMMAND ${CPPCHECK} --enable=all --std=c++14 --inconclusive --xml --xml-version=2 
                --output-file=${CMAKE_BINARY_DIR}/cppcheck_results.xml
                -I${CMAKE_SOURCE_DIR}/include
                ${CMAKE_SOURCE_DIR}/src
        COMMENT "Running cppcheck analysis"
        VERBATIM
    )
else()
    message(WARNING "cppcheck not found. cppcheck analysis is disabled.")
endif()