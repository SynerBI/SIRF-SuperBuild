#========================================================================
# Author: Benjamin A Thomas
# Author: Kris Thielemans
# Author: Edoardo Pasca
# Copyright 2017, 2018 University College London
# Copyright 2017, 2018 STFC
#
# This file is part of the CCP PETMR Synergistic Image Reconstruction Framework (SIRF) SuperBuild.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0.txt
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#=========================================================================

#This needs to be unique globally
set(proj ACE)

# Set dependency list
set(${proj}_DEPENDENCIES "")

# Include dependent projects if any
ExternalProject_Include_Dependencies(${proj} DEPENDS_VAR ${proj}_DEPENDENCIES)

# Set external name (same as internal for now)
set(externalProjName ${proj})

SetCanonicalDirectoryNames(${proj})

if(NOT ( DEFINED "USE_SYSTEM_${externalProjName}" AND "${USE_SYSTEM_${externalProjName}}" ) )
  message(STATUS "${__indent}Adding project ${proj}")

  ### --- Project specific additions here

  set(CMAKE_LIBRARY_PATH ${CMAKE_LIBRARY_PATH} ${SUPERBUILD_INSTALL_DIR})
  set(CMAKE_INCLUDE_PATH ${CMAKE_INCLUDE_PATH} ${SUPERBUILD_INSTALL_DIR})



  ExternalProject_Add(${proj}
    ${${proj}_EP_ARGS}
    GIT_REPOSITORY ${${proj}_URL}
    GIT_TAG ${${proj}_TAG}
    ${${proj}_EP_ARGS_DIRS}
    CMAKE_ARGS
      -DCMAKE_INSTALL_PREFIX=${${proj}_INSTALL_DIR}
      -DLIBRARY_DIR=${${proj}_INSTALL_DIR}/lib
      -DINCLUDE_DIR=${${proj}_INSTALL_DIR}/include
    # TODO this relies on using "make", but we could be build with something else
    INSTALL_COMMAND make ACE
    DEPENDS
        ${${proj}_DEPENDENCIES}
  )

   # not used
   # set(${proj}_ROOT        ${${proj}_SOURCE_DIR})
   # set(${proj}_INCLUDE_DIR ${${proj}_SOURCE_DIR})

   else()
      if(${USE_SYSTEM_${externalProjName}})
        find_package(${proj} ${${externalProjName}_REQUIRED_VERSION} REQUIRED)
        message(STATUS "USING the system ${externalProjName}, found ACE_LIBRARIES=${ACE_LIBRARIES}")
    endif()
  ExternalProject_Add_Empty(${proj} DEPENDS "${${proj}_DEPENDENCIES}"
    ${${proj}_EP_ARGS_DIRS}
  )
  endif()

# Currently, setting ACE_ROOT has no effect, see https://github.com/CCPPETMR/SIRF-SuperBuild/issues/147
#  mark_as_superbuild(
#    VARS
#      ${externalProjName}_ROOT:PATH
#    LABELS
#      "FIND_PACKAGE"
#  )
