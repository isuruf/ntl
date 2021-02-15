execute_process(COMMAND ${TEST_EXECUTABLE} INPUT_FILE "${TEST_INPUT_FILE}"
         OUTPUT_VARIABLE TEST_OUTPUT)
file(READ "${TEST_OUTPUT_FILE}" TEST_OUTPUT_EXPECTED)
if (NOT "${TEST_OUTPUT}" STREQUAL "${TEST_OUTPUT_EXPECTED}")
    message("Expected Output: ${TEST_OUTPUT_EXPECTED}")
    message("Found Output:    ${TEST_OUTPUT}")
    message(FATAL_ERROR "Output not expected")
endif()
