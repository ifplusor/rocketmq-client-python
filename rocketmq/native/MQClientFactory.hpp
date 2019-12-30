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
#ifndef __PY_MQ_CLIENT_FACTORY_HPP__
#define __PY_MQ_CLIENT_FACTORY_HPP__

#include <DefaultMQProducer.h>
#include <DefaultMQPushConsumer.h>

namespace rocketmq {

inline std::shared_ptr<DefaultMQProducer>
CreateDefaultMQProducer(const std::string& groupname = "", RPCHookPtr rpcHook = nullptr) {
  // return DefaultMQProducer::create(groupname, rpcHook);
  return std::make_shared<DefaultMQProducer>(groupname, rpcHook);
}

inline std::shared_ptr<DefaultMQPushConsumer>
CreateDefaultMQPushConsumer(const std::string& groupname = "", RPCHookPtr rpcHook = nullptr) {
  // return DefaultMQPushConsumer::create(groupname, rpcHook);
  return std::make_shared<DefaultMQPushConsumer>(groupname, rpcHook);
}

}  // namespace rocketmq

#endif  // __PY_MQ_CLIENT_FACTORY_HPP__
