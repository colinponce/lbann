set(PROTOBUF_MIN_VERSION "3.0.0")

# On cross-compilation machines, we want to use the module because we
# will use the host protoc and the target libprotobuf. In this case,
# users should set Protobuf_PROTOC_EXECUTABLE=/path/to/host/bin/protoc
# and set PROTOBUF_DIR=/path/to/target/protobuf/prefix.
option(${PROJECT_NAME}_USE_PROTOBUF_MODULE
  "Use the FindProtobuf module instead of Protobuf's config file." OFF)

if (${PROJECT_NAME}_USE_PROTOBUF_MODULE)
  if (PROTOBUF_DIR)
    set(__remove_protobuf_from_paths TRUE)
    list(APPEND CMAKE_LIBRARY_PATH ${PROTOBUF_DIR}/lib)
    list(APPEND CMAKE_INCLUDE_PATH ${PROTOBUF_DIR}/include)
    list(APPEND CMAKE_PREFIX_PATH ${PROTOBUF_DIR})
  endif ()

  # At this point, throw an error if Protobuf is not found.
  find_package(Protobuf "${PROTOBUF_MIN_VERSION}" MODULE)
  if(NOT Protobuf_FOUND)
    find_package(Protobuf "${PROTOBUF_MIN_VERSION}" MODULE REQUIRED)
  endif ()

  if (__remove_protobuf_from_paths)
    list(REMOVE_ITEM CMAKE_LIBRARY_PATH ${PROTOBUF_DIR}/lib)
    list(REMOVE_ITEM CMAKE_INCLUDE_PATH ${PROTOBUF_DIR}/include)
    list(REMOVE_ITEM CMAKE_PREFIX_PATH ${PROTOBUF_DIR})
    set(__remove_protobuf_from_paths)
  endif ()

else ()
  set(protobuf_MODULE_COMPATIBLE ON)
  set(protobuf_BUILD_SHARED_LIBS ON)

  find_package(Protobuf "${PROTOBUF_MIN_VERSION}" CONFIG
    HINTS
    "${Protobuf_DIR}"
    "${PROTOBUF_DIR}"
    "${Protobuf_DIR}/lib64/cmake/protobuf"
    "${PROTOBUF_DIR}/lib64/cmake/protobuf"
    "${Protobuf_DIR}/lib/cmake/protobuf"
    "${PROTOBUF_DIR}/lib/cmake/protobuf"
    "$ENV{Protobuf_DIR}"
    "$ENV{PROTOBUF_DIR}"
    "$ENV{Protobuf_DIR}/lib64/cmake/protobuf"
    "$ENV{PROTOBUF_DIR}/lib64/cmake/protobuf"
    "$ENV{Protobuf_DIR}/lib/cmake/protobuf"
    "$ENV{PROTOBUF_DIR}/lib/cmake/protobuf"
    NO_DEFAULT_PATH)
  if(NOT Protobuf_FOUND)
    find_package(Protobuf "${PROTOBUF_MIN_VERSION}" CONFIG REQUIRED)
  endif ()
endif ()

if (NOT Protobuf_FOUND)
  message(FATAL_ERROR
    "Protobuf still not found. This should never throw.")
endif ()

# Setup the imported target for old versions of CMake
if (NOT TARGET protobuf::libprotobuf)
  add_library(protobuf::libprotobuf INTERFACE IMPORTED)
  set_property(TARGET protobuf::libprotobuf PROPERTY
    INTERFACE_LINK_LIBRARIES "${PROTOBUF_LIBRARIES}")

  set_property(TARGET protobuf::libprotobuf PROPERTY
    INTERFACE_INCLUDE_DIRECTORIES "${PROTOBUF_INCLUDE_DIRS}")
endif ()

# This can just be "TRUE" since protobuf is REQUIRED above.
set(LBANN_HAS_PROTOBUF TRUE)
