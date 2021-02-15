if (NOT EXISTS ${CMAKE_CURRENT_BINARY_DIR}/include/NTL/HAVE_${FEATURE}.h)
    execute_process(COMMAND
                    ${CMAKE_COMMAND} --build . --target Check${FEATURE} --config $<CONFIGURATION>
                    RESULT_VARIABLE ${FEATURE}_COMPILE_RESULT
                    OUTPUT_VARIABLE OUT
                    ERROR_VARIABLE ERR)

    set(${FEATURE}_RUN_RESULT "-1")

    if ("${${FEATURE}_COMPILE_RESULT}" STREQUAL "0")
        execute_process(COMMAND
                    ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CFG_INTDIR}/Check${FEATURE}${CMAKE_EXECUTABLE_SUFFIX_CXX}
                    RESULT_VARIABLE ${FEATURE}_RUN_RESULT)
    endif()

    if ("${${FEATURE}_RUN_RESULT}" STREQUAL "0")
        message("Looking for feature ${FEATURE} - found")
        file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/HAVE_${FEATURE}.h.in"
"#ifndef NTL_HAVE_${FEATURE}
#define NTL_HAVE_${FEATURE}
#endif
")
    else()
        file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/HAVE_${FEATURE}.h.in" "")
        message("Looking for feature ${FEATURE} - not found")
        #  ${${FEATURE}_COMPILE_RESULT} ${${FEATURE}_RUN_RESULT} ${ERR} ${OUT})
    endif()

    configure_file("${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/HAVE_${FEATURE}.h.in" "${CMAKE_CURRENT_BINARY_DIR}/include/NTL/HAVE_${FEATURE}.h")
endif()

