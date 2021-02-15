# This overrides the default CMake Debug and Release compiler options.
# The user can still specify different options by setting the
# CMAKE_CXX_FLAGS_[RELEASE,DEBUG] variables (on the command line or in the
# CMakeList.txt). This files serves as better CMake defaults and should only be
# modified if the default values are to be changed. Project specific compiler
# flags should be set in the CMakeList.txt by setting the CMAKE_CXX_FLAGS_*
# variables.

# Remove -O3 by default in Release flags

if (CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang|Intel")
    set(CMAKE_CXX_FLAGS_RELEASE_INIT "-O2 -DNDEBUG")
endif ()
