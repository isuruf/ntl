cmake_minimum_required(VERSION 3.10)

set(CMAKE_USER_MAKE_RULES_OVERRIDE ${CMAKE_CURRENT_SOURCE_DIR}/cmake/UserOverride.cmake)
if ("${CMAKE_CURRENT_SOURCE_DIR}" STREQUAL "${CMAKE_CURRENT_BINARY_DIR}")
    message(FATAL_ERROR "NTL build system doesn't allow building in-source. "
            "Create a build directory and run cmake from there")
endif()

project(NTL)

set(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake)
include(CheckCXXCompilerFlag)

# Make sure that CMAKE_BUILD_TYPE is either Debug or Release:
if (NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE RelWithDebInfo
        CACHE STRING "Build type (Debug, Release, RelWithDebInfo, MinSizeRel)" FORCE)
endif ()
if (NOT (CMAKE_BUILD_TYPE MATCHES "^Debug|Release|RelWithDebInfo|MinSizeRel$"))
    message(FATAL_ERROR "CMAKE_BUILD_TYPE must be one of: Debug, Release (current value: '${CMAKE_BUILD_TYPE}')")
endif ()
string(TOUPPER "${CMAKE_BUILD_TYPE}" CMAKE_BUILD_TYPE_UPPER)

option(BUILD_SHARED_LIBS "Build shared libs" no)
option(NATIVE "Build native" no)

if (NOT WIN32)
    set(NTL_LINK_LIBRARIES -lm)
endif ()

set(TUNE "generic" CACHE STRING "Tuning method")

option(NTL_LEGACY_NO_NAMESPACE "Legacy no namespace" off)
option(NTL_LEGACY_INPUT_ERROR "Legacy input error" off)
option(NTL_DISABLE_LONGDOUBLE "Disable longdouble" off)
option(NTL_DISABLE_LONGLONG "Disable longlong" off)
option(NTL_DISABLE_LL_ASM "Disable ll asm" off)
option(NTL_MAXIMIZE_SP_NBITS "Maximize sp nbits" off)
option(NTL_LEGACY_SP_MULMOD "Legacy sp mulmod" off)
option(NTL_THREADS "Threads" on)
option(NTL_TLS_HACK "Tls hack" on)
option(NTL_EXCEPTIONS "Exceptions" off)
option(NTL_STD_CXX11 "std cxx11" on)
option(NTL_STD_CXX14 "stf cxx14" off)
option(NTL_DISABLE_MOVE_ASSIGN "Disable move assign" on)
option(NTL_DISABLE_MOVE "Disable move" off)
option(NTL_THREAD_BOOST "Thread boost" on)
option(NTL_GMP_LIP "GMP lip" on)
option(NTL_GF2X_LIB "GF2X lib" off)
option(NTL_X86_FIX "x86 fix" off)
option(NTL_NO_X86_FIX "No x86 fix" off)
option(NTL_NO_INIT_TRANS "No init trans" on)
option(NTL_CLEAN_INT "Clean int" off)
option(NTL_CLEAN_PTR "Clean ptr" on)
option(NTL_SAFE_VECTORS "Safe vectors" on)
option(NTL_RANGE_CHECK "Range check" off)
option(NTL_ENABLE_AVX_FFT "Enable AVX FFT" off)
option(NTL_AVOID_AVX512 "Avoid AVX512" off)
option(NTL_SPMM_ULL "SPMM ULL" off)
option(NTL_AVOID_BRANCHING "Avoid branching" off)
option(NTL_FFT_BIGTAB "FFT bigtab" off)
option(NTL_FFT_LAZYMUL "FFT lazymul" off)
option(NTL_TBL_REM "TBL REM" off)
option(NTL_CRT_ALTCODE "Crt altcode" off)
option(NTL_CRT_ALTCODE_SMALL "Crt altcode small" off)
option(NTL_GF2X_NOINLINE "GF2X noinline" off)
option(NTL_GF2X_ALTCODE "GF2X altcode" off)
option(NTL_GF2X_ALTCODE1 "GF2X altcode1" off)

if (NTL_UNSIGNED_LONG_LONG_TYPE)
    set(FLAG_UNSIGNED_LONG_LONG_TYPE "1" CACHE STRING "is unsigned long long type defined by user")
else ()
    set(FLAG_UNSIGNED_LONG_LONG_TYPE "0" CACHE STRING "is unsigned long long type defined by user")
    set(NTL_UNSIGNED_LONG_LONG_TYPE "unsigned long long"  CACHE STRING "unsigned long long type" )
endif()


# warn against -O3, -Ofast, -ffast-math
if ("${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_${CMAKE_BUILD_TYPE_UPPER}}" MATCHES "-O3")
    message(WARNING "-O3 flag may yield incorrect code")
endif()

if ("${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_${CMAKE_BUILD_TYPE_UPPER}}" MATCHES "-Ofast")
    message(WARNING "-Ofast flag may yield incorrect code")
endif()

if ("${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_${CMAKE_BUILD_TYPE_UPPER}}" MATCHES "-ffast-math")
    message(WARNING "-ffast-math flag may yield incorrect code")
endif()

if (NOT NTL_THREADS)
    set(NTL_THREAD_BOOST off)
endif()

if ("${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_${CMAKE_BUILD_TYPE_UPPER}}" MATCHES "-march=")
    set(NATIVE off)
    message(STATUS "Turning off NATIVE as there is a -march flag in CXXFLAGS")
endif()

if (NTL_X86_FIX AND NTL_NO_X86_FIX)
    message(FATAL_ERROR "at most one of NTL_X86_FIX and NTL_NO_X86_FIX may be on")
endif()

if (NTL_GF2X_ALTCODE AND NTL_GF2X_ALTCODE1)
    message(FATAL_ERROR "at most one of NTL_GF2X_ALTCODE and NTL_GF2X_ALTCODE1 may be on")
endif()

if (NTL_CRT_ALTCODE AND NTL_CRT_ALTCODE_SMALL)
    message(FATAL_ERROR "at most one of NTL_CRT_ALTCODE and NTL_CRT_ALTCODE_SMALL may be on")
endif()

foreach (opt NATIVE NTL_LEGACY_NO_NAMESPACE NTL_LEGACY_INPUT_ERROR NTL_DISABLE_LONGDOUBLE NTL_DISABLE_LONGLONG NTL_DISABLE_LL_ASM NTL_MAXIMIZE_SP_NBITS NTL_LEGACY_SP_MULMOD NTL_THREADS NTL_TLS_HACK NTL_EXCEPTIONS NTL_STD_CXX11 NTL_STD_CXX14 NTL_DISABLE_MOVE_ASSIGN NTL_DISABLE_MOVE NTL_THREAD_BOOST NTL_GMP_LIP NTL_GF2X_LIB NTL_X86_FIX NTL_NO_X86_FIX NTL_NO_INIT_TRANS NTL_CLEAN_INT NTL_CLEAN_PTR NTL_SAFE_VECTORS NTL_RANGE_CHECK NTL_ENABLE_AVX_FFT NTL_AVOID_AVX512 NTL_SPMM_ULL NTL_AVOID_BRANCHING NTL_FFT_BIGTAB NTL_FFT_LAZYMUL NTL_TBL_REM NTL_CRT_ALTCODE NTL_CRT_ALTCODE_SMALL NTL_GF2X_NOINLINE NTL_GF2X_ALTCODE NTL_GF2X_ALTCODE1)
    if (${${opt}})
        set(${opt} "1")
    else()
        set(${opt} "0")
    endif()
endforeach()

if (NTL_GMP_LIP)
    find_package(GMP REQUIRED)
endif()
if (NTL_GF2X_LIB)
    find_package(GF2X REQUIRED)
endif()

set(min_std 0)

# special processing for NTL_THREADS

if (NTL_THREADS)
    set(min_std 11)
    option(CMAKE_THREAD_PREFER_PTHREAD "Prefer pthreads" ON)
    option(THREADS_PREFER_PTHREAD_FLAG "Prefer -pthread flag" ON)
    find_package(Threads REQUIRED)
    set(THREADS_LIBRARIES Threads::Threads)
endif()

if (NTL_EXCEPTIONS)
    set(min_std 11)
endif()

if (NTL_SAFE_VECTORS)
    set(min_std 11)
endif()

if (NTL_STD_CXX14)
    set(min_std 14)
elseif (NTL_STD_CXX11)
    set(min_std 11)
elseif (min_std)
    set(NTL_STD_CXX11 1)
endif()

try_run(GENCONFIGINFO_RUN_RESULT GENCONFIGINFO_COMPILE_RESULT
    ${CMAKE_CURRENT_BINARY_DIR}
    SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/cmake/GetCXXStandard.cpp"
    COMPILE_OUTPUT_VARIABLE VAR1
    RUN_OUTPUT_VARIABLE GENCONFIGINFO_RUN_OUTPUT
    LINK_LIBRARIES ${NTL_LINK_LIBRARIES}
)

if (NOT ("${GENCONFIGINFO_RUN_OUTPUT}" STREQUAL "98" OR "${GENCONFIGINFO_RUN_OUTPUT}" STREQUAL "0"))
    # If the compiler support a newer standard, don't set it on our own.
    if ("${min_std}" LESS "${GENCONFIGINFO_RUN_OUTPUT}")
        set(min_std 0)
        message(STATUS "Using default C++ standard ${GENCONFIGINFO_RUN_OUTPUT}")
    endif()
endif()

if (NOT "${min_std}" STREQUAL "0")
    message(STATUS "Using C++ standard ${min_std}")
    set(CMAKE_CXX_STANDARD ${min_std})
    set(CMAKE_CXX_STANDARD_REQUIRED ON)
endif()

# logic to disable floating-point contractions (FMA) in quad_float.cpp.
# This is an issue on machines with FMA instructions.
# By default, gcc and icc allow contractions, while clang does not.

try_run(CHECK_CONTRACT_RUN_RESULT CHECK_CONTRACT_COMPILE_RESULT
    ${CMAKE_CURRENT_BINARY_DIR}
    SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/src/CheckContract.cpp" "${CMAKE_CURRENT_SOURCE_DIR}/src/CheckContractAux.cpp"
    LINK_LIBRARIES ${NTL_LINK_LIBRARIES}
)

include(CheckCXXCompilerFlag)

if ("${CHECK_CONTRACT_RUN_RESULT}" STREQUAL "0")
    if (NOCONTRACT)
        message(WARNING "cannot disable floating point contraction")
    else()
        if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
            check_cxx_compiler_flag("-ffp-contract=off" FFP_CONTRACT_OFF_FLAG)
            if (NOT FFP_CONTRACT_OFF_FLAG)
                set (NTL_NOCONTRACT_FLAG "-mno-fused-madd")
            else ()
                set (NTL_NOCONTRACT_FLAG "-ffp-contract=off")
            endif()
        elseif ("${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang")
            set (NTL_NOCONTRACT_FLAG "-ffp-contract=off")
        elseif ("${CMAKE_CXX_COMPILER_ID}" MATCHES "Intel")
            set (NTL_NOCONTRACT_FLAG "-DNTL_FP_CONTRACT_OFF")
        endif()
        try_run(CHECK_CONTRACT2_RUN_RESULT CHECK_CONTRACT2_COMPILE_RESULT
                ${CMAKE_CURRENT_BINARY_DIR}
                SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/src/CheckContract.cpp" "${CMAKE_CURRENT_SOURCE_DIR}/src/CheckContractAux.cpp"
                CMAKE_FLAGS "${NTL_NOCONTRACT_FLAG} -DNTL_CONTRACTION_FIXED"
                LINK_LIBRARIES ${NTL_LINK_LIBRARIES}
        )
        if ("${CHECK_CONTRACT2_RUN_RESULT}" STREQUAL "0")
            set(NTL_NOCONTRACT_FLAGS "${NTL_NOCONTRACT_FLAG} -DNTL_CONTRACTION_FIXED")
            message(STATUS "Using flags ${NTL_NOCONTRACT_FLAGS}")
        else()
            message(WARNING "cannot disable floating point contraction")
        endif()
    endif()
endif()


# disable floating-point optimizations that are not value safe
# for most compilers, the default at optimzation  '-O2' is to
# disable such optimizations. icc is the big exception,
# so we compile all of NTL with the "-fp-model precise" flag.
# On older IA-32 machines, this also has the effect of preventing
# calculations in "extended double" precision.
if ("${CMAKE_CXX_COMPILER_ID}" MATCHES "Intel")
    check_cxx_compiler_flag("-fp-model precise" FP_MODEL_PRECISE_FLAG)
    if (FP_MODEL_PRECISE_FLAG)
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fp-model precise")
    endif()
endif()

if (NATIVE AND "${CMAKE_CXX_COMPILER_ID}" MATCHES "Intel|GNU|Clang")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -march=native")
endif()

set(SOURCES)

set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

try_compile(GETPID_COMPILE_RESULT
    ${CMAKE_CURRENT_BINARY_DIR}
    SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/src/GetPID1.cpp"
    OUTPUT_VARIABLE VAR1
)

if ("${GETPID_COMPILE_RESULT}" STREQUAL "FALSE")
    message(STATUS "Trying compiling GetPID1 - failed")
    set(SOURCES ${SOURCES} GetPID2.cpp)
else()
    message(STATUS "Trying compiling GetPID1 - pass")
    set(SOURCES ${SOURCES} GetPID1.cpp)
endif()

foreach(TIME_SOURCE GetTime1 GetTime2 GetTime3 GetTime4 GetTime5)
    try_run(${TIME_SOURCE}_RUN_RESULT ${TIME_SOURCE}_COMPILE_RESULT
        ${CMAKE_CURRENT_BINARY_DIR}
        SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/src/${TIME_SOURCE}.cpp" "${CMAKE_CURRENT_SOURCE_DIR}/src/TestGetTime.cpp"
        ARGS 1 1048576 1048575
    )
    if ("${${TIME_SOURCE}_RUN_RESULT}" STREQUAL "0")
        set(SOURCES ${SOURCES} ${TIME_SOURCE}.cpp)
        message(STATUS "Trying to use ${TIME_SOURCE} - pass")
        break()
    elseif ("${${TIME_SOURCE}}" STREQUAL "GetTime5")
        message(WARNING "${TIME_SOURCE} always returns 0")
    else()
        message(STATUS "Trying to use ${TIME_SOURCE} - failed")
    endif()
endforeach()

if ("${CMAKE_HOST_SYSTEM_PROCESSOR}" MATCHES "AMD64|amd64|x86_64|x86" AND "${TUNE}" STREQUAL "generic")
    set(TUNE x86)
endif()

if ("${TUNE}" STREQUAL "auto")
    message(FATAL_ERROR "Not supported in cmake yet")
elseif ("${TUNE}" STREQUAL "generic")
	 # the default values are set to ensure reasonably good performance
	 # across a wide range of architectures, but it's better to run the
	 # Wizard. Here, I don't want to assume a cmov-like instruction,
         # so we set AVOID_BRANCHING to be on the safe side.

	 set(NTL_SPMM_ULL 1)
	 set(NTL_AVOID_BRANCHING 1)
	 set(NTL_FFT_BIGTAB 1)
	 set(NTL_FFT_LAZYMUL 1)
	 set(NTL_TBL_REM 1)
	 set(NTL_CRT_ALTCODE 1)
	 set(NTL_CRT_ALTCODE_SMALL 0)
	 set(NTL_GF2X_NOINLINE 0)
	 set(NTL_GF2X_ALTCODE 0)
	 set(NTL_GF2X_ALTCODE1 1)
     message(STATUS "Tuning for a generic processor")
elseif ("${TUNE}" STREQUAL "x86")
     # these settings should work pretty well across x86's
     # the most important assumption is that we have the cmov
     # instruction
	 set(NTL_SPMM_ULL 1)
	 set(NTL_AVOID_BRANCHING 0)
	 set(NTL_FFT_BIGTAB 1)
	 set(NTL_FFT_LAZYMUL 1)
	 set(NTL_TBL_REM 1)
	 set(NTL_CRT_ALTCODE 1)
	 set(NTL_CRT_ALTCODE_SMALL 0)
	 set(NTL_GF2X_NOINLINE 0)
	 set(NTL_GF2X_ALTCODE 0)
	 set(NTL_GF2X_ALTCODE1 1)
     message(STATUS "Tuning for a x86/x86_64 processor")
endif()

configure_file(src/config.h.in "${CMAKE_CURRENT_BINARY_DIR}/include/NTL/config.h")

macro(ntl_check_threads)
    try_run(CHECK_NTL_THREADS_RUN_RESULT CHECK_NTL_THREADS_COMPILE_RESULT
        ${CMAKE_CURRENT_BINARY_DIR}
        SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/src/CheckThreads.cpp"
        LINK_LIBRARIES ${NTL_LINK_LIBRARIES} Threads::Threads
        OUTPUT_VARIABLE VAR1
        CMAKE_FLAGS "-DINCLUDE_DIRECTORIES=${CMAKE_CURRENT_BINARY_DIR}/include;${CMAKE_CURRENT_SOURCE_DIR}/include"
    )
endmacro()

if (NTL_THREADS)
    ntl_check_threads()
    if ("${CHECK_NTL_THREADS_COMPILE_RESULT}" STREQUAL "TRUE" AND "${CHECK_NTL_THREADS_RUN_RESULT}" STREQUAL "0")
        message(STATUS "threads are OK")
    else()
        if (NOT NTL_TLS_HACK)
            message(FATAL_ERROR "threads are broken")
        endif()
        set(NTL_TLS_HACK 0)
        configure_file(src/config.h.in "${CMAKE_CURRENT_BINARY_DIR}/include/NTL/config.h")
        ntl_check_threads()
        if ("${CHECK_NTL_THREADS_COMPILE_RESULT}" STREQUAL "TRUE" AND "${CHECK_NTL_THREADS_RUN_RESULT}" STREQUAL "1")
            message(FATAL_ERROR "threads are broken")
        else()
            message(STATUS "threads are OK with NTL_TLS_HACK=off")
        endif()
    endif()
endif()


set(GENERATED_HEADERS)

add_executable(mach_desc src/MakeDescAux.cpp src/MakeDesc.cpp)
target_include_directories(mach_desc
    PUBLIC
    ${CMAKE_CURRENT_BINARY_DIR}/include
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)
add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/include/NTL/mach_desc.h
    COMMAND mach_desc
    COMMAND ${CMAKE_COMMAND} -E copy_if_different ${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/mach_desc.h ${CMAKE_CURRENT_BINARY_DIR}/include/NTL/mach_desc.h
    DEPENDS mach_desc
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/
)
set(GENERATED_HEADERS ${GENERATED_HEADERS} ${CMAKE_CURRENT_BINARY_DIR}/include/NTL/mach_desc.h)

add_executable(gen_gmp_aux src/gen_gmp_aux.cpp ${CMAKE_CURRENT_BINARY_DIR}/include/NTL/mach_desc.h)
target_link_libraries(gen_gmp_aux
    PUBLIC
    ${GMP_LIBRARIES}
    ${NTL_LINK_LIBRARIES}
)
target_include_directories(gen_gmp_aux
    PUBLIC
    ${CMAKE_CURRENT_BINARY_DIR}/include
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)

add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/include/NTL/gmp_aux.h
    COMMAND gen_gmp_aux > ${CMAKE_CURRENT_BINARY_DIR}/include/NTL/gmp_aux.h.in
    COMMAND ${CMAKE_COMMAND} -E copy_if_different ${CMAKE_CURRENT_BINARY_DIR}/include/NTL/gmp_aux.h.in ${CMAKE_CURRENT_BINARY_DIR}/include/NTL/gmp_aux.h
    DEPENDS gen_gmp_aux
)

set (GENERATED_HEADERS ${GENERATED_HEADERS} ${CMAKE_CURRENT_BINARY_DIR}/include/NTL/gmp_aux.h)

foreach(FEATURE ALIGNED_ARRAY BUILTIN_CLZL LL_TYPE SSSE3 AVX PCLMUL AVX2 FMA AVX512F COPY_TRAITS1 COPY_TRAITS2 CHRONO_TIME MACOS_TIME POSIX_TIME)
    add_executable(Check${FEATURE} src/Check${FEATURE}.cpp ${GENERATED_HEADERS})
    set_target_properties(Check${FEATURE} PROPERTIES
                          EXCLUDE_FROM_ALL TRUE
                          EXCLUDE_FROM_DEFAULT_BUILD TRUE)
    target_include_directories(Check${FEATURE}
        PUBLIC
        ${CMAKE_CURRENT_BINARY_DIR}/include
        ${CMAKE_CURRENT_SOURCE_DIR}/include
    )
    # These are serial because some checks depend on other checks
    # and since we are running cmake as a subprocess, it needs to be serial (otherwise textfile busy issues)
    add_custom_command(
        OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/include/NTL/HAVE_${FEATURE}.h
        COMMAND ${CMAKE_COMMAND} "-DFEATURE=${FEATURE}" -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/gen_feature_header.cmake"
        DEPENDS ${GENERATED_HEADERS}
    )
    set (GENERATED_HEADERS ${GENERATED_HEADERS} ${CMAKE_CURRENT_BINARY_DIR}/include/NTL/HAVE_${FEATURE}.h)
endforeach()

set (SOURCES ${SOURCES} FFT.cpp FacVec.cpp GF2.cpp GF2E.cpp GF2EX.cpp GF2EXFactoring.cpp GF2X.cpp
	GF2X1.cpp GF2XFactoring.cpp GF2XVec.cpp HNF.cpp ctools.cpp LLL.cpp LLL_FP.cpp
	LLL_QP.cpp LLL_RR.cpp LLL_XD.cpp RR.cpp WordVector.cpp ZZ.cpp ZZVec.cpp ZZX.cpp
	ZZX1.cpp ZZXCharPoly.cpp ZZXFactoring.cpp ZZ_p.cpp ZZ_pE.cpp ZZ_pEX.cpp
	ZZ_pEXFactoring.cpp ZZ_pX.cpp ZZ_pX1.cpp ZZ_pXCharPoly.cpp ZZ_pXFactoring.cpp
	fileio.cpp lip.cpp lzz_p.cpp lzz_pE.cpp lzz_pEX.cpp lzz_pEXFactoring.cpp
	lzz_pX.cpp lzz_pX1.cpp lzz_pXCharPoly.cpp lzz_pXFactoring.cpp mat_GF2.cpp
	mat_GF2E.cpp mat_RR.cpp mat_ZZ.cpp mat_ZZ_p.cpp mat_ZZ_pE.cpp mat_lzz_p.cpp
	mat_lzz_pE.cpp mat_poly_ZZ.cpp mat_poly_ZZ_p.cpp mat_poly_lzz_p.cpp
	quad_float.cpp quad_float1.cpp tools.cpp vec_GF2.cpp vec_GF2E.cpp vec_RR.cpp vec_ZZ.cpp
	vec_ZZ_p.cpp vec_ZZ_pE.cpp vec_lzz_p.cpp vec_lzz_pE.cpp xdouble.cpp
	G_LLL_FP.cpp G_LLL_QP.cpp G_LLL_XD.cpp G_LLL_RR.cpp thread.cpp
	BasicThreadPool.cpp MatPrime.cpp pd_FFT.cpp
)

set(SOURCES_WITH_DIR )
foreach(SOURCE ${SOURCES})
    set(SOURCES_WITH_DIR ${SOURCES_WITH_DIR} src/${SOURCE})
endforeach()

if (NOT "${NTL_NOCONTRACT_FLAGS}" STREQUAL "")
    set_source_files_properties(src/quad_float.cpp src/pd_FFT.cpp PROPERTIES COMPILE_FLAGS ${NTL_NOCONTRACT_FLAGS})
endif()
if (NOT "${GMP_INCLUDE_DIRS}" STREQUAL "")
    set_source_files_properties(src/lip.cpp PROPERTIES INCLUDE_DIRECTORIES ${GMP_INCLUDE_DIRS})
    set_source_files_properties(src/gen_gmp_aux.cpp PROPERTIES INCLUDE_DIRECTORIES ${GMP_INCLUDE_DIRS})
endif()
if (NOT "${GF2X_INCLUDE_DIRS}" STREQUAL "")
    set_source_files_properties(src/GF2X.cpp PROPERTIES INCLUDE_DIRECTORIES ${GF2X_INCLUDE_DIRS})
endif()

add_library(ntl ${SOURCES_WITH_DIR} ${GENERATED_HEADERS})

target_include_directories(ntl
    PUBLIC
    ${CMAKE_CURRENT_BINARY_DIR}/include
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)
target_link_libraries(ntl
    PUBLIC
    ${GMP_LIBRARIES}
    ${GF2X_LIBRARIES}
    ${NTL_LINK_LIBRARIES}
    ${THREADS_LIBRARIES}
)

set_target_properties(
    ntl
    PROPERTIES
    VERSION 39.0.1
    SOVERSION 39
)

include(GNUInstallDirs)

install(TARGETS ntl
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

file(GLOB
    HEADERS_ALL
        "${CMAKE_CURRENT_SOURCE_DIR}/include/NTL/*.h"
)

set(HEADERS )
foreach(HEADER ${HEADERS_ALL})
    get_filename_component(HEADER_NAME ${HEADER} NAME)
    if (NOT "${HEADER_NAME}" MATCHES "^HAVE_")
        set(HEADERS ${HEADERS} ${HEADER})
    endif()
endforeach()

install(
    FILES ${HEADERS} ${GENERATED_HEADERS}
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/NTL
)

file(GLOB NTL_DOCS "${CMAKE_CURRENT_SOURCE_DIR}/doc/*")

install(
    FILES ${NTL_DOCS}
    DESTINATION ${CMAKE_INSTALL_DOCDIR}
)

option(BUILD_TESTING "Build tests" off)

if (BUILD_TESTING)
    enable_testing()
    foreach (TEST_SOURCE CharPolyTest GF2EXGCDTest GF2EXTest GF2XTest LLLTest lzz_pEXGCDTest
                         lzz_pEXTest lzz_pXTest mat_lzz_pTest MatrixTest MoreFacTest QuadTest
                         RRTest SSMulTest subset ThreadTest ZZ_pEXGCDTest ZZ_pEXTest ZZ_pXTest
                         ZZTest ZZXFacTest QuickTest BerlekampTest CanZassTest BitMatTest
            )
        add_executable(${TEST_SOURCE} src/${TEST_SOURCE}.cpp)
        target_link_libraries(${TEST_SOURCE} ntl)
    endforeach()

    foreach(TEST_EXECUTABLE LLLTest QuadTest RRTest CharPolyTest MatrixTest ZZXFacTest BerlekampTest CanZassTest)
        add_test(NAME ${TEST_EXECUTABLE}
                 COMMAND ${CMAKE_COMMAND} "-DTEST_EXECUTABLE=$<TARGET_FILE:${TEST_EXECUTABLE}>"
                         "-DTEST_INPUT_FILE=${CMAKE_CURRENT_SOURCE_DIR}/src/${TEST_EXECUTABLE}In"
                         "-DTEST_OUTPUT_FILE=${CMAKE_CURRENT_SOURCE_DIR}/src/${TEST_EXECUTABLE}Out"
                         -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/ntl_run_test_diff.cmake")
    endforeach()
    file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/MoreFacTest.out" "")

    add_test(NAME MoreFacTest
             COMMAND ${CMAKE_COMMAND} "-DTEST_EXECUTABLE=$<TARGET_FILE:MoreFacTest>"
                     "-DTEST_INPUT_FILE=${CMAKE_CURRENT_SOURCE_DIR}/src/MoreFacTestIn"
                     "-DTEST_OUTPUT_FILE=${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/MoreFacTest.out"
                     -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/ntl_run_test_diff.cmake")

    file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/subset1.in" "  40 40 20 10 999999 f")
    file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/subset2.in" "  40 40 20 10 999999 q")
    file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/subset.out" "")

    foreach(SUBSET_CASE subset1 subset2)
        add_test(NAME ${SUBSET_CASE}
                 COMMAND ${CMAKE_COMMAND} "-DTEST_EXECUTABLE=$<TARGET_FILE:subset>"
                         "-DTEST_INPUT_FILE=${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/${SUBSET_CASE}.in"
                         "-DTEST_OUTPUT_FILE=${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/subset.out"
                         -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/ntl_run_test_diff.cmake")
    endforeach()

    foreach(TEST_EXECUTABLE QuickTest ZZTest SSMulTest ZZ_pXTest lzz_pXTest GF2XTest GF2EXTest
                            GF2EXGCDTest mat_lzz_pTest BitMatTest ZZ_pEXTest ZZ_pEXGCDTest
                            lzz_pEXTest lzz_pEXGCDTest ThreadTest)
        add_test(${TEST_EXECUTABLE} ${TEST_EXECUTABLE})
    endforeach()
endif()
