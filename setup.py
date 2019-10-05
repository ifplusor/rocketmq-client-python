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

native_kernel = Extension(
    name="rocketmq.native.PyRocketMQ",
    sources=[
        "rocketmq/native/rocketmq.pxd",
        "rocketmq/native/PyRocketMQ.pyx",
    ],
    language="c++",
    extra_compile_args=["-std=c++11"],
    include_dirs=[ROCKETMQ_INCLUDE_DIR],
    library_dirs=[ROCKETMQ_LIBRARY_DIR],
    libraries=["rocketmq"]
)

setup(
    name="rocketmq-client-python",
    version='2.0.0',
    url="https://github.com/apache/rocketmq-client-python",
    description="RocketMQ Python client",
    long_description="RocketMQ Python client is developed on top of rocketmq-client-cpp, which has been proven "
                     "robust and widely adopted within Alibaba Group by many business units for more than three "
                     "years.",
    license="Apache License, Version 2.0",
    packages=find_packages(exclude=["test"]),
    ext_modules=cythonize(native_kernel),
)
