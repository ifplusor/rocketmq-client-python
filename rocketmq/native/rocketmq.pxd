# distutils: language = c++
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
from libc.stdint cimport *
from libcpp.string cimport string
from libcpp.vector cimport vector
from libcpp.memory cimport shared_ptr


cdef extern from "MQMessage.h" namespace "rocketmq" nogil:
    cdef cppclass MQMessage:
        MQMessage() except +

        const string& getProperty(const string& name) const
        void putProperty(const string& name, const string& value)
        void clearProperty(const string& name)

        const string& getTopic() const
        void setTopic(const string& topic)

        const string& getTags() const
        void setTags(const string& tags)

        const string& getKeys() const
        void setKeys(const string& keys)
        void setKeys(const vector[string]& keys)

        int32_t getDelayTimeLevel() const
        void setDelayTimeLevel(int32_t level)

        bint isWaitStoreMsgOK() const
        void setWaitStoreMsgOK(bint waitStoreMsgOK)

        int32_t getFlag() const
        void setFlag(int32_t flag)

        const string& getBody() const
        void setBody(const string& body)

        const string& getTransactionId() const
        void setTransactionId(const string& transactionId)

        string toString() const


cdef extern from "MQMessageExt.h" namespace "rocketmq" nogil:
    cdef cppclass MQMessageExt(MQMessage):
        int32_t getStoreSize() const
        int32_t getBodyCRC() const
        int32_t getQueueId() const
        int64_t getQueueOffset() const
        int64_t getCommitLogOffset() const
        int32_t getSysFlag() const
        int64_t getBornTimestamp() const
        string getBornHostString() const
        int64_t getStoreTimestamp() const
        string getStoreHostString() const
        int32_t getReconsumeTimes() const
        int64_t getPreparedTransactionOffset() const
        const string& getMsgId() const

        string toString() const


cdef extern from "MQMessageQueue.h" namespace "rocketmq" nogil:
    cdef cppclass MQMessageQueue:
        MQMessageQueue();
        MQMessageQueue(const string& topic, const string& brokerName, int queueId)

        MQMessageQueue& operator=(const MQMessageQueue& other);

        const string& getTopic() const
        void setTopic(const string& topic)

        const string& getBrokerName() const
        void setBrokerName(const string& brokerName)

        int getQueueId() const
        void setQueueId(int queueId)

        string toString() const


cdef extern from "SendResult.h" namespace "rocketmq" nogil:
    cdef enum SendStatus:
        SEND_OK, SEND_FLUSH_DISK_TIMEOUT, SEND_FLUSH_SLAVE_TIMEOUT, SEND_SLAVE_NOT_AVAILABLE

    cdef cppclass SendResult:
        SendResult() except +
        SendResult(const SendResult& other) except +

        SendStatus getSendStatus() const
        const string& getMsgId() const
        const string& getOffsetMsgId() const
        const MQMessageQueue& getMessageQueue() const
        int64_t getQueueOffset() const
        const string& getTransactionId() const

        string toString() const


cdef extern from "MQProducer.h" namespace "rocketmq" nogil:
    cdef cppclass MQProducer:
        # Trick Cython for overloads, see: https://stackoverflow.com/a/42627030/6298032

        SendResult send(...) except +
        SendResult sync_send "send"(MQMessage*msg) except +
        SendResult sync_send_with_timeout "send"(MQMessage*msg) except +
        SendResult sync_send_to_mq "send"(MQMessage*msg, const MQMessageQueue& mq, long timeout) except +
        SendResult sync_send_to_mq_with_timeout "send"(MQMessage*msg, const MQMessageQueue& mq, long timeout) except +

        void sendOneway(...) except +
        void oneway_send "sendOneway"(MQMessage*msg) except +
        void oneway_send_to_mq "sendOneway"(MQMessage*msg, const MQMessageQueue& mq) except +


cdef extern from "MQMessageListener.h" namespace "rocketmq" nogil:
    cdef enum ConsumeStatus:
        CONSUME_SUCCESS, RECONSUME_LATER

    cdef cppclass MQMessageListener:
        ConsumeStatus consumeMessage(const vector[shared_ptr[MQMessageExt]]& msgs)
        ConsumeStatus consumeMessage(const vector[MQMessageExt*]& msgs)

    cdef cppclass MessageListenerConcurrently(MQMessageListener):
        pass

    cdef cppclass MessageListenerOrderly(MQMessageListener):
        pass


ctypedef ConsumeStatus (*ConsumeMessage)(object, const vector[MQMessageExt*] &)


cdef extern from "MessageListenerWrapper.hpp" namespace "rocketmq" nogil:
    cdef cppclass MessageListenerWrapper(MQMessageListener):
        pass

    cdef cppclass MessageListenerConcurrentlyWrapper(MessageListenerWrapper, MessageListenerConcurrently):
        MessageListenerConcurrentlyWrapper(object, ConsumeMessage) except +

    cdef cppclass MessageListenerOrderlyWrapper(MessageListenerWrapper, MessageListenerOrderly):
        MessageListenerOrderlyWrapper(object, ConsumeMessage) except +


cdef extern from "MQConsumer.h" namespace "rocketmq" nogil:
    cdef cppclass MQPushConsumer:
        void registerMessageListener(MQMessageListener*messageListener)
        void subscribe(const string& topic, const string& subExpression)


cdef extern from "RPCHook.h" namespace "rocketmq" nogil:
    cdef cppclass RPCHook:
        pass


cdef extern from "SessionCredentials.h" namespace "rocketmq" nogil:
    cdef cppclass SessionCredentials:
        SessionCredentials() except +
        SessionCredentials(const string& accessKey, const string& secretKey, const string& authChannel) except +

        const string& getAccessKey()
        void setAccessKey(const string& accessKey)

        const string& getSecretKey() const
        void setSecretKey(const string& secretKey)

        const string& getSignature() const
        void setSignature(const string& signature)

        const string& getSignatureMethod() const
        void setSignatureMethod(const string& signatureMethod)

        const string& getAuthChannel() const
        void setAuthChannel(const string& channel)

        bint isValid() const


cdef extern from "ClientRPCHook.h" namespace "rocketmq" nogil:
    cdef cppclass ClientRPCHook(RPCHook):
        ClientRPCHook(const SessionCredentials& sessionCredentials) except +


cdef extern from "MQClientConfig.h" namespace "rocketmq" nogil:
    cdef cppclass MQClientConfig:
        const string& getGroupName() const
        void setGroupName(const string& groupname)

        const string& getNamesrvAddr() const
        void setNamesrvAddr(const string& namesrvAddr)

        const string& getInstanceName() const
        void setInstanceName(const string& instanceName)


cdef extern from "MQClient.h" namespace "rocketmq" nogil:
    cdef cppclass MQClient(MQClientConfig):
        void start() except +
        void shutdown() except +


cdef extern from "DefaultMQProducer.h" namespace "rocketmq" nogil:
    cdef cppclass DefaultMQProducer(MQProducer, MQClient):
        bint isSendLatencyFaultEnable() const
        void setSendLatencyFaultEnable(bint sendLatencyFaultEnable)


cdef extern from "DefaultMQPushConsumer.h" namespace "rocketmq" nogil:
    cdef cppclass DefaultMQPushConsumer(MQPushConsumer, MQClient):
        int getConsumeThreadNum() const
        void setConsumeThreadNum(int threadNum)

        int getConsumeMessageBatchMaxSize() const
        void setConsumeMessageBatchMaxSize(int consumeMessageBatchMaxSize)


cdef extern from "MQClientFactory.hpp" namespace "rocketmq" nogil:
    shared_ptr[DefaultMQProducer] CreateDefaultMQProducer(const string& groupname,
                                                          shared_ptr[RPCHook] rpcHook) except +

    shared_ptr[DefaultMQPushConsumer] CreateDefaultMQPushConsumer(const string& groupname,
                                                                  shared_ptr[RPCHook] rpcHook) except +
