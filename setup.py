# encoding=utf-8
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
from os import getenv

from Cython.Build import cythonize
from setuptools import setup, find_packages, Extension

ROCKETMQ_INCLUDE_DIR = getenv("ROCKETMQ_INCLUDE_DIR", "/usr/local/include/rocketmq")
ROCKETMQ_LIBRARY_DIR = getenv("ROCKETMQ_LIBRARY_DIR", "/usr/local/lib")

EXT_INCLUDE_DIRS = getenv("EXT_INCLUDE_DIRS", "")
EXT_LIBRARY_DIRS = getenv("EXT_LIBRARY_DIRS", "")
EXT_LIBRARIES = getenv("EXT_LIBRARIES", "")

ext_include_dirs = [ROCKETMQ_INCLUDE_DIR]
if EXT_INCLUDE_DIRS:
    ext_include_dirs.extend(EXT_INCLUDE_DIRS.split(","))

ext_library_dirs = [ROCKETMQ_LIBRARY_DIR]
if EXT_LIBRARY_DIRS:
    ext_library_dirs.extend(EXT_LIBRARY_DIRS.split(","))

link_libraries = ["rocketmq"]
if EXT_LIBRARIES:
    link_libraries.extend(EXT_LIBRARIES.split(","))

native_kernel = Extension(
    name="rocketmq.native.PyRocketMQ",
    sources=[
        "rocketmq/native/PyRocketMQ.pyx",
    ],
    language="c++",
    extra_compile_args=["-std=c++11", "-fPIC"],
    include_dirs=ext_include_dirs,
    library_dirs=ext_library_dirs,
    libraries=link_libraries
)

setup(
    name="rocketmq-client-python",
    version='3.0.0',
    url="https://github.com/apache/rocketmq-client-python",
    description="RocketMQ Python client",
    long_description="RocketMQ Python client is developed on top of rocketmq-client-cpp, which has been proven "
                     "robust and widely adopted within Alibaba Group by many business units for more than three "
                     "years.",
    license="Apache License, Version 2.0",
    packages=find_packages(exclude=["test"]),
    ext_modules=cythonize(native_kernel),
)
