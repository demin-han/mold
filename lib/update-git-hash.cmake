# Get a git hash value. We do not want to use git command here
# because we don't want to make git a build-time dependency.
if(EXISTS "${SOURCE_DIR}/.git/HEAD")
  file(READ "${SOURCE_DIR}/.git/HEAD" HASH)
  string(STRIP "${HASH}" HASH)

  if(HASH MATCHES "^ref: (.*)")
    set(HEAD "${CMAKE_MATCH_1}")
    if(EXISTS "${SOURCE_DIR}/.git/${HEAD}")
      file(READ "${SOURCE_DIR}/.git/${HEAD}" HASH)
      string(STRIP "${HASH}" HASH)
    else()
      file(READ "${SOURCE_DIR}/.git/packed-refs" PACKED_REFS)
      string(REGEX REPLACE ".*\n([0-9a-f]+) ${HEAD}\n.*" "\\1" HASH "\n${PACKED_REFS}")
    endif()
  endif()
endif()

# Create new file contents and update a given file if necessary.
if("${HASH}" STREQUAL "")
  set(NEW_CONTENTS "")
else()
  set(NEW_CONTENTS "#define MOLD_GIT_HASH \"${HASH}\"\n")
endif()

if(EXISTS "${OUTPUT_FILE}")
  file(READ "${OUTPUT_FILE}" OLD_CONTENTS)
  if(NOT "${NEW_CONTENTS}" STREQUAL "${OLD_CONTENTS}")
    file(WRITE "${OUTPUT_FILE}" "${NEW_CONTENTS}")
  endif()
else()
  file(WRITE "${OUTPUT_FILE}" "${NEW_CONTENTS}")
endif()
