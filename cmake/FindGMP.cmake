find_path(GMP_INCLUDE_DIRS NAMES  gmp.h PATHS ${GMP_PREFIX}/include ${GMP_INCDIR})

find_library(GMP_LIBRARIES gmp PATHS ${GMP_PREFIX}/lib ${GMP_LIBDIR})

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(GMP DEFAULT_MSG
                                  GMP_INCLUDE_DIRS GMP_LIBRARIES)
mark_as_advanced(GMP_INCLUDE_DIRS GMP_LIBRARIES)
