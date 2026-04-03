cmake_minimum_required(VERSION 3.18)
project(Jacobi3D_Project LANGUAGES CXX CUDA)

# --- 1. Build type and default L ---

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Build type (Debug/Release)" FORCE)
endif()

set(L 128 CACHE STRING "Size of the arrays")

# --- 2. CUDA architectures (MUST be non-empty) ---

# Set this BEFORE defining CUDA targets.
# Example: compile for common modern architectures (60, 70, 80).
# You can adjust this list to your needs.
set(CMAKE_CUDA_ARCHITECTURES "60;70;80" CACHE STRING "CUDA architectures" FORCE)

# --- 3. Executables ---

# CPU version (OpenMP)
add_executable(jac3d_cpu jac3d_cpu.cpp)
find_package(OpenMP REQUIRED)
target_link_libraries(jac3d_cpu PRIVATE OpenMP::OpenMP_CXX)
set_target_properties(jac3d_cpu PROPERTIES
    CXX_STANDARD 14
    CXX_STANDARD_REQUIRED ON
)

# GPU version (CUDA)
add_executable(jac3d_gpu jac3d_gpu.cu)
set_target_properties(jac3d_gpu PROPERTIES
    CUDA_STANDARD 14
    CUDA_STANDARD_REQUIRED ON
    # No need to set CUDA_ARCHITECTURES here; it is initialized from CMAKE_CUDA_ARCHITECTURES.
)

# --- 4. Compilation flags (Debug vs Release) ---

function(set_build_flags target)
    # Release flags
    target_compile_options(${target} PRIVATE
        $<$<CONFIG:Release>:-O3>
    )

    # Debug flags
    target_compile_options(${target} PRIVATE
        $<$<CONFIG:Debug>:-g -O0>
    )

    # CUDA-specific debug flag (-G for device debug info)
    if(${target} STREQUAL "jac3d_gpu")
        target_compile_options(${target} PRIVATE
            $<$<CONFIG:Debug>:-G>
        )
    endif()
endfunction()

set_build_flags(jac3d_cpu)
set_build_flags(jac3d_gpu)

# --- 5. Custom targets: run_cpu, run_gpu, run_compare ---

add_custom_target(run_cpu
    COMMAND jac3d_cpu ${L}
    DEPENDS jac3d_cpu
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    COMMENT "Running CPU version with L=${L}"
    VERBATIM
)

add_custom_target(run_gpu
    COMMAND jac3d_gpu ${L}
    DEPENDS jac3d_gpu
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    COMMENT "Running GPU version with L=${L}"
    VERBATIM
)

# "Third program": compare results using a generated CMake script
set(COMPARE_SCRIPT "${CMAKE_BINARY_DIR}/compare_results.cmake")
file(WRITE ${COMPARE_SCRIPT}
"message(STATUS \"Running Comparison (L=${L})...\")
execute_process(COMMAND ${CMAKE_BINARY_DIR}/jac3d_cpu ${L} OUTPUT_FILE cpu_out.txt)
execute_process(COMMAND ${CMAKE_BINARY_DIR}/jac3d_gpu ${L} OUTPUT_FILE gpu_out.txt)
execute_process(COMMAND ${CMAKE_COMMAND} -E compare_files cpu_out.txt gpu_out.txt RESULT_VARIABLE DIFF_RESULT)
if(DIFF_RESULT EQUAL 0)
    message(STATUS \"SUCCESS: Results are identical.\")
else()
    message(FATAL_ERROR \"FAILURE: Results differ.\")
endif()
")

add_custom_target(run_compare
    COMMAND ${CMAKE_COMMAND} -P ${COMPARE_SCRIPT}
    DEPENDS jac3d_cpu jac3d_gpu
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    COMMENT "Running both versions and comparing results"
    VERBATIM
)