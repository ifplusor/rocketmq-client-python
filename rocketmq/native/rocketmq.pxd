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


cdef extern from "Message.h" namespace "rocketmq" nogil:
    cdef cppclass Message:
        const string& topic() const
        void set_topic(const string& topic)

        const string& tags() const
        void set_tags(const string& tags)

        const string& keys() const
        void set_keys(const string& keys)
        void set_keys(const vector[string]& keys)

        int32_t delay_time_level() const
        void set_delay_time_level(int32_t level)

        bint wait_store_msg_ok() const
        void set_wait_store_msg_ok(bint waitStoreMsgOK)

        int32_t flag() const
        void set_flag(int32_t flag)

        const string& body() const
        void set_body(const string& body)

        const string& transaction_id() const
        void set_transaction_id(const string& transactionId)

        const string& getProperty(const string& name) const
        void putProperty(const string& name, const string& value)
        void clearProperty(const string& name)

        string toString() const


cdef extern from "MQMessage.h" namespace "rocketmq" nogil:
    cdef cppclass MQMessage(Message):
        MQMessage() except +
        MQMessage(shared_ptr[Message] impl) except +

        shared_ptr[Message] getMessageImpl()


cdef extern from "MessageExt.h" namespace "rocketmq" nogil:
    cdef cppclass MessageExt(Message):
        int32_t store_size() const
        int32_t body_crc() const
        int32_t queue_id() const
        int64_t queue_offset() const
        int64_t commit_log_offset() const
        int32_t sys_flag() const
        int64_t born_timestamp() const
        string born_host_string() const
        int64_t store_timestamp() const
        string store_host_string() const
        int32_t reconsume_times() const
        int64_t prepared_transaction_offset() const
        const string& msg_id() const


cdef extern from "MQMessageExt.h" namespace "rocketmq" nogil:
    cdef cppclass MQMessageExt(MQMessage, MessageExt):
        pass


cdef extern from "MQMessageQueue.h" namespace "rocketmq" nogil:
    cdef cppclass MQMessageQueue:
        MQMessageQueue();
        MQMessageQueue(const string& topic, const string& brokerName, int queueId)

        MQMessageQueue& operator=(const MQMessageQueue& other);

        const string& topic() const
        void set_topic(const string& topic)

        const string& broker_name() const
        void set_broker_name(const string& brokerName)

        int queue_id() const
        void set_queue_id(int queueId)

        string toString() const


cdef extern from "MessageUtil.h" namespace "rocketmq" nogil:
    cdef cppclass MessageUtil:
        @staticmethod
        MQMessage createReplyMessage(const MQMessage requestMessage, const string& body) except +


cdef extern from "SendResult.h" namespace "rocketmq" nogil:
    cdef enum SendStatus:
        SEND_OK, SEND_FLUSH_DISK_TIMEOUT, SEND_FLUSH_SLAVE_TIMEOUT, SEND_SLAVE_NOT_AVAILABLE

    cdef cppclass SendResult:
        SendResult() except +
        SendResult(const SendResult& other) except +

        SendStatus send_status() const
        const string& msg_id() const
        const string& offset_msg_id() const
        const MQMessageQueue& message_queue() const
        int64_t queue_offset() const
        const string& transaction_id() const

        string toString() const


cdef extern from "MQProducer.h" namespace "rocketmq" nogil:
    cdef cppclass MQProducer:
        void start() except +
        void shutdown() except +

        # Trick Cython for overloads, see: https://stackoverflow.com/a/42627030/6298032

        SendResult send(...) except +
        SendResult sync_send "send"(MQMessage msg) except +
        SendResult sync_send_with_timeout "send"(MQMessage msg, long timeout) except +
        SendResult sync_send_to_mq "send"(MQMessage msg, const MQMessageQueue& mq, long timeout) except +
        SendResult sync_send_to_mq_with_timeout "send"(MQMessage msg, const MQMessageQueue& mq, long timeout) except +

        void sendOneway(...) except +
        void oneway_send "sendOneway"(MQMessage msg) except +
        void oneway_send_to_mq "sendOneway"(MQMessage msg, const MQMessageQueue& mq) except +

        MQMessage request(MQMessage msg, long timeout) except +


cdef extern from "MQMessageListener.h" namespace "rocketmq" nogil:
    cdef enum ConsumeStatus:
        CONSUME_SUCCESS, RECONSUME_LATER

    cdef cppclass MQMessageListener:
        ConsumeStatus consumeMessage(const vector[MQMessageExt]& msgs)

    cdef cppclass MessageListenerConcurrently(MQMessageListener):
        pass

    cdef cppclass MessageListenerOrderly(MQMessageListener):
        pass


ctypedef ConsumeStatus (*ConsumeMessage)(object, vector[MQMessageExt] &)


cdef extern from "MessageListenerWrapper.hpp" namespace "rocketmq" nogil:
    cdef cppclass MessageListenerWrapper(MQMessageListener):
        pass

    cdef cppclass MessageListenerConcurrentlyWrapper(MessageListenerWrapper, MessageListenerConcurrently):
        MessageListenerConcurrentlyWrapper(object, ConsumeMessage) except +

    cdef cppclass MessageListenerOrderlyWrapper(MessageListenerWrapper, MessageListenerOrderly):
        MessageListenerOrderlyWrapper(object, ConsumeMessage) except +


cdef extern from "MQConsumer.h" namespace "rocketmq" nogil:
    cdef cppclass MQPushConsumer:
        void start() except +
        void shutdown() except +

        void registerMessageListener(MQMessageListener* messageListener)
        void subscribe(const string& topic, const string& subExpression)


cdef extern from "RPCHook.h" namespace "rocketmq" nogil:
    cdef cppclass RPCHook:
        pass


cdef extern from "SessionCredentials.h" namespace "rocketmq" nogil:
    cdef cppclass SessionCredentials:
        SessionCredentials() except +
        SessionCredentials(const string& accessKey, const string& secretKey, const string& authChannel) except +

        const string& access_key()
        void set_access_key(const string& accessKey)

        const string& secret_key() const
        void set_secret_key(const string& secretKey)

        const string& signature() const
        void set_signature(const string& signature)

        const string& signature_method() const
        void set_signature_method(const string& signatureMethod)

        const string& auth_channel() const
        void set_auth_channel(const string& channel)

        bint isValid() const


cdef extern from "ClientRPCHook.h" namespace "rocketmq" nogil:
    cdef cppclass ClientRPCHook(RPCHook):
        ClientRPCHook(const SessionCredentials& sessionCredentials) except +


cdef extern from "MQClientConfig.h" namespace "rocketmq" nogil:
    cdef cppclass MQClientConfig:
        const string& group_name() const
        void set_group_name(const string& groupname)

        const string& namesrv_addr() const
        void set_namesrv_addr(const string& namesrvAddr)

        const string& instance_name() const
        void set_instance_name(const string& instanceName)


cdef extern from "DefaultMQProducer.h" namespace "rocketmq" nogil:
    cdef cppclass DefaultMQProducerConfig(MQClientConfig):
        int max_message_size() const
        void set_max_message_size(int maxMessageSize)

        int compress_msg_body_over_howmuch() const
        void set_compress_msg_body_over_howmuch(int compressMsgBodyOverHowmuch)

        int compress_level() const
        void set_compress_level(int compressLevel)

        int send_msg_timeout() const
        void set_send_msg_timeout(int sendMsgTimeout)

        int retry_times() const
        void set_retry_times(int times)

        int retry_times_for_async() const
        void set_retry_times_for_async(int times)

        bint retry_another_broker_when_not_store_ok() const
        void set_retry_another_broker_when_not_store_ok(bint retryAnotherBrokerWhenNotStoreOK)

        bint send_latency_fault_enable() const
        void set_send_latency_fault_enable(bint sendLatencyFaultEnable)

    cdef cppclass DefaultMQProducer(MQProducer, DefaultMQProducerConfig):
        DefaultMQProducer(const string& groupname) except +
        DefaultMQProducer(const string& groupname, shared_ptr[RPCHook] rpcHook) except +


cdef extern from "DefaultMQPushConsumer.h" namespace "rocketmq" nogil:
    cdef cppclass DefaultMQPushConsumerConfig(MQClientConfig):
        int consume_thread_nums() const
        void set_consume_thread_nums(int threadNum)

        int consume_message_batch_max_size() const
        void set_consume_message_batch_max_size(int consumeMessageBatchMaxSize)

        int max_cache_msg_size_per_queue() const 
        void set_max_cache_msg_size_per_queue(int maxCacheSize)

        int max_reconsume_times() const
        void set_max_reconsume_times(int maxReconsumeTimes)

        long pull_time_delay_mills_when_exception() const
        void set_pull_time_delay_mills_when_exception(long pullTimeDelayMillsWhenException)

    cdef cppclass DefaultMQPushConsumer(MQPushConsumer, DefaultMQPushConsumerConfig):
        DefaultMQPushConsumer(const string& groupname) except +
        DefaultMQPushConsumer(const string& groupname, shared_ptr[RPCHook] rpcHook) except +
