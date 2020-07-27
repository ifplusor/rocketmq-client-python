/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
#ifndef ROCKETMQ_NATIVE_MESSAGELISTENERWRAPPER_HPP_
#define ROCKETMQ_NATIVE_MESSAGELISTENERWRAPPER_HPP_

#include <Python.h>

#include "MQMessageListener.h"

namespace rocketmq {

typedef ConsumeStatus (*ConsumeMessage)(PyObject*, std::vector<MQMessageExt>&);

class MessageListenerWrapper : virtual public MQMessageListener {
 public:
  MessageListenerWrapper(PyObject* py_obj, ConsumeMessage py_callback) : py_obj_(py_obj), py_callback_(py_callback) {
    // ensure GIL is initialized.
    PyEval_InitThreads();
  }

  ConsumeStatus consumeMessage(std::vector<MQMessageExt>& msgs) override {
    return py_callback_(py_obj_, msgs);
  }

 private:
  PyObject* py_obj_;
  ConsumeMessage py_callback_;
};

class MessageListenerConcurrentlyWrapper : public MessageListenerWrapper, public MessageListenerConcurrently {
 public:
  MessageListenerConcurrentlyWrapper(PyObject* py_obj, ConsumeMessage py_callback)
      : MessageListenerWrapper(py_obj, py_callback) {}
};

class MessageListenerOrderlyWrapper : public MessageListenerWrapper, public MessageListenerOrderly {
 public:
  MessageListenerOrderlyWrapper(PyObject* py_obj, ConsumeMessage py_callback)
      : MessageListenerWrapper(py_obj, py_callback) {}
};

}  // namespace rocketmq

#endif  // ROCKETMQ_NATIVE_MESSAGELISTENERWRAPPER_HPP_
