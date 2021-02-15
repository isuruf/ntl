
find_path(GF2X_INCLUDE_DIRS NAMES gf2x.h PATHS ${GF2X_PREFIX}/include ${GF2X_INCDIR})

find_library(GF2X_LIBRARIES gf2x PATHS ${GF2X_PREFIX}/lib ${GF2X_LIBDIR})

try_run(GF2X_RUN_RESULT GF2X_COMPILE_RESULT
    ${CMAKE_CURRENT_BINARY_DIR}
    SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/src/gf2x_version_1_2_or_later_required.cpp"
    LINK_LIBRARIES ${NTL_LINK_LIBRARIES} ${GF2X_LIBRARIES}
    CMAKE_FLAGS INCLUDE_DIRECTORIES ${GF2X_INCLUDE_DIRS}
)

if (NOT "${GF2X_RUN_RESULT}" STREQUAL "0")
    message(FATAL_ERROR "can't use gf2x, but requested")
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(GF2X DEFAULT_MSG
                                  GF2X_INCLUDE_DIRS GF2X_LIBRARIES)
mark_as_advanced(GF2X_INCLUDE_DIRS GF2X_LIBRARIES)
