# distutils: language = c++
# cython: embedsignature=True
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
from libcpp.memory cimport shared_ptr
from libcpp.string cimport string
from libcpp.vector cimport vector

# import dereference and increment operators
from cython.operator cimport dereference as deref, address as addrs, preincrement as inc

# import native SDK API
from rocketmq cimport MQMessage, MQMessageExt, MQMessageQueue, MessageUtil
from rocketmq cimport SendStatus, SendResult
from rocketmq cimport ConsumeStatus, MessageListenerWrapper, MessageListenerConcurrentlyWrapper, MessageListenerOrderlyWrapper
from rocketmq cimport RPCHook, SessionCredentials, ClientRPCHook
from rocketmq cimport MQClientConfig, DefaultMQProducer, DefaultMQPushConsumer

import sys

is_py3 = bool(sys.version_info[0] >= 3)


def str2bytes(s):
    if is_py3:
        if type(s) is str:
            return s.encode("utf-8")
        else:
            return s
    else:
        if type(s) is unicode:
            return s.encode("utf-8")
        else:
            return s


def bytes2str(b):
    if is_py3:
        return b.decode("utf-8")
    else:
        return b


cdef class PyMessage:
    """Wrapper of MQMessage"""

    cdef MQMessage* _MQMessage_impl_obj

    def __cinit__(self):
        if type(self) is PyMessage:
            self._MQMessage_impl_obj = new MQMessage()
        else:
            self._MQMessage_impl_obj = NULL

    def __dealloc__(self):
        if type(self) is PyMessage:
            del self._MQMessage_impl_obj

    cdef void set_MQMessage_impl_obj(self, MQMessage* obj):
        self._MQMessage_impl_obj = obj

    def __init__(self, topic=None, body=None, tags=None, keys=None):
        if topic is not None:
            self.topic = topic
        if body is not None:
            self.body = body
        if tags is not None:
            self.tags = tags
        if keys is not None:
            self.keys = keys

    def get_property(self, name):
        return bytes2str(self._MQMessage_impl_obj.getProperty(str2bytes(name)))

    def put_property(self, name, value):
        self._MQMessage_impl_obj.putProperty(str2bytes(name), str2bytes(value))

    def clear_property(self, name):
        self._MQMessage_impl_obj.clearProperty(str2bytes(name))

    @property
    def topic(self):
        return bytes2str(self._MQMessage_impl_obj.getTopic())

    @topic.setter
    def topic(self, topic):
        self._MQMessage_impl_obj.setTopic(str2bytes(topic))

    @property
    def tags(self):
        return bytes2str(self._MQMessage_impl_obj.getTags())

    @tags.setter
    def tags(self, tags):
        self._MQMessage_impl_obj.setTags(str2bytes(tags))

    @property
    def keys(self):
        return bytes2str(self._MQMessage_impl_obj.getKeys())

    @keys.setter
    def keys(self, keys):
        if isinstance(keys, str):
            self._MQMessage_impl_obj.setKeys(<string> str2bytes(keys))
        elif isinstance(keys, list) or isinstance(keys, tuple) or isinstance(keys, set):
            new_keys = map(lambda key: str2bytes(key), keys)
            self._MQMessage_impl_obj.setKeys(<vector[string]> new_keys)

    @property
    def delay_time_level(self):
        return self._MQMessage_impl_obj.getDelayTimeLevel()

    @delay_time_level.setter
    def delay_time_level(self, level):
        self._MQMessage_impl_obj.setDelayTimeLevel(level)

    @property
    def wait_store_msg_ok(self):
        return self._MQMessage_impl_obj.isWaitStoreMsgOK()

    @wait_store_msg_ok.setter
    def wait_store_msg_ok(self, wait_store_msg_ok):
        self._MQMessage_impl_obj.setWaitStoreMsgOK(wait_store_msg_ok)

    @property
    def flag(self):
        return self._MQMessage_impl_obj.getFlag()

    @flag.setter
    def flag(self, flag):
        self._MQMessage_impl_obj.setFlag(flag)

    @property
    def body(self):
        return self._MQMessage_impl_obj.getBody()

    @body.setter
    def body(self, body):
        self._MQMessage_impl_obj.setBody(str2bytes(body))

    def __str__(self):
        return bytes2str(self._MQMessage_impl_obj.toString())


cdef class PyMessageGuard(PyMessage):

    def __cinit__(self):
        pass

    def __dealloc__(self):
        if type(self) is PyMessageGuard:
            del self._MQMessage_impl_obj

    cdef void set_MQMessage_impl_obj(self, MQMessage* obj):
        PyMessage.set_MQMessage_impl_obj(self, obj)

    @staticmethod
    cdef PyMessage from_message(MQMessage* obj):
        ret = PyMessageGuard()
        ret.set_MQMessage_impl_obj(obj)
        return ret


cdef class PyMessageExt(PyMessage):
    """Wrapper of MQMessageExt"""

    cdef shared_ptr[MQMessageExt] _MQMessageExt_impl_obj

    def __cinit__(self):
        pass

    def __dealloc__(self):
        pass

    cdef void set_MQMessageExt_impl_obj(self, shared_ptr[MQMessageExt] obj):
        self._MQMessageExt_impl_obj = obj
        PyMessage.set_MQMessage_impl_obj(self, obj.get())

    @staticmethod
    cdef PyMessageExt from_message_ext(shared_ptr[MQMessageExt] message):
        ret = PyMessageExt()
        ret.set_MQMessageExt_impl_obj(message)
        return ret

    @property
    def store_size(self):
        return deref(self._MQMessageExt_impl_obj).getStoreSize()

    @property
    def body_crc(self):
        return deref(self._MQMessageExt_impl_obj).getBodyCRC()

    @property
    def queue_id(self):
        return deref(self._MQMessageExt_impl_obj).getQueueId()

    @property
    def queue_offset(self):
        return deref(self._MQMessageExt_impl_obj).getQueueOffset()

    @property
    def commit_log_offset(self):
        return deref(self._MQMessageExt_impl_obj).getCommitLogOffset()

    @property
    def sys_flag(self):
        return deref(self._MQMessageExt_impl_obj).getSysFlag()

    @property
    def born_timestamp(self):
        return deref(self._MQMessageExt_impl_obj).getBornTimestamp()

    @property
    def born_host(self):
        return bytes2str(deref(self._MQMessageExt_impl_obj).getBornHostString())

    @property
    def store_timestamp(self):
        return deref(self._MQMessageExt_impl_obj).getStoreTimestamp()

    @property
    def store_host(self):
        return bytes2str(deref(self._MQMessageExt_impl_obj).getStoreHostString())

    @property
    def reconsume_times(self):
        return deref(self._MQMessageExt_impl_obj).getReconsumeTimes()

    @property
    def prepared_transaction_offset(self):
        return deref(self._MQMessageExt_impl_obj).getPreparedTransactionOffset()

    @property
    def msg_id(self):
        return bytes2str(deref(self._MQMessageExt_impl_obj).getMsgId())


cdef class PyMessageQueue:
    """Wrapper of MQMessageQueue"""

    cdef MQMessageQueue* _MQMessageQueue_impl_obj

    def __cinit__(self):
        self._MQMessageQueue_impl_obj = NULL

    def __dealloc__(self):
        del self._MQMessageQueue_impl_obj

    def __init__(self, topic=None, brokerName=None, queueId=None):
        if topic is None or brokerName is None or queueId is None:
            self._MQMessageQueue_impl_obj = new MQMessageQueue()
        else:
            self._MQMessageQueue_impl_obj = new MQMessageQueue(str2bytes(topic), str2bytes(brokerName),
                                                               str2bytes(queueId))

    @staticmethod
    cdef PyMessageQueue from_message_queue(const MQMessageQueue* mq):
        ret = PyMessageQueue()
        ret._MQMessageQueue_impl_obj[0] = deref(mq)
        return ret

    @property
    def topic(self):
        return bytes2str(self._MQMessageQueue_impl_obj.getTopic())

    @topic.setter
    def topic(self, topic):
        self._MQMessageQueue_impl_obj.setTopic(str2bytes(topic))

    @property
    def broker_name(self):
        return bytes2str(self._MQMessageQueue_impl_obj.getBrokerName())

    @broker_name.setter
    def broker_name(self, broker_name):
        self._MQMessageQueue_impl_obj.setBrokerName(str2bytes(broker_name))

    @property
    def queue_id(self):
        return self._MQMessageQueue_impl_obj.getQueueId()

    @queue_id.setter
    def queue_id(self, queue_id):
        self._MQMessageQueue_impl_obj.setQueueId(queue_id)

    def __str__(self):
        return bytes2str(self._MQMessageQueue_impl_obj.toString())


def create_reply_message(PyMessage request, body):
    cdef MQMessage* reply
    reply = MessageUtil.createReplyMessage(request._MQMessage_impl_obj, str2bytes(body))
    return PyMessageGuard.from_message(reply)


cpdef enum PySendStatus:
    SEND_OK = SendStatus.SEND_OK
    SEND_FLUSH_DISK_TIMEOUT = SendStatus.SEND_FLUSH_DISK_TIMEOUT
    SEND_FLUSH_SLAVE_TIMEOUT = SendStatus.SEND_FLUSH_SLAVE_TIMEOUT
    SEND_SLAVE_NOT_AVAILABLE = SendStatus.SEND_SLAVE_NOT_AVAILABLE


cdef class PySendResult:
    """Wrapper of SendResult"""

    cdef SendResult* _SendResult_impl_obj

    def __cinit__(self):
        self._SendResult_impl_obj = NULL

    def __dealloc__(self):
        del self._SendResult_impl_obj

    @staticmethod
    cdef PySendResult from_result(SendResult* result):
        ret = PySendResult()
        ret._SendResult_impl_obj = new SendResult(deref(result))
        return ret

    @property
    def send_status(self):
        return PySendStatus(self._SendResult_impl_obj.getSendStatus())

    @property
    def msg_id(self):
        return bytes2str(self._SendResult_impl_obj.getMsgId())

    @property
    def offset_msg_id(self):
        return bytes2str(self._SendResult_impl_obj.getOffsetMsgId())

    @property
    def message_queue(self):
        return PyMessageQueue.from_message_queue(addrs(self._SendResult_impl_obj.getMessageQueue()))

    @property
    def queue_offset(self):
        return self._SendResult_impl_obj.getQueueOffset()

    @property
    def transaction_id(self):
        return bytes2str(self._SendResult_impl_obj.getTransactionId())

    def __str__(self):
        return bytes2str(self._SendResult_impl_obj.toString())


cdef class PySendCallback:
    """Wrapper of SendCallback"""
    pass


cpdef enum PyConsumeStatus:
    CONSUME_SUCCESS = ConsumeStatus.CONSUME_SUCCESS
    RECONSUME_LATER = ConsumeStatus.RECONSUME_LATER


cdef class PyMessageListener:
    """Wrapper of MQMessageListener"""

    cdef MessageListenerWrapper* _impl_obj

    def __cinit__(self):
        self._impl_obj = NULL

    def __dealloc(self):
        del self._impl_obj

    def consume_message(self, msgs):
        """Callback for consume message in python, return PyConsumeStatus or None."""
        return PyConsumeStatus.RECONSUME_LATER

    @staticmethod
    cdef ConsumeStatus ConsumeMessage(object obj, const vector[shared_ptr[MQMessageExt]]& msgs) with gil:
        # callback by native SDK in another thread need declare GIL.

        py_msgs = list()
        cdef vector[shared_ptr[MQMessageExt]].const_iterator it = msgs.const_begin()
        while it != msgs.const_end():
            msg = PyMessageExt.from_message_ext(deref(it))
            py_msgs.append(msg)
            inc(it)

        cdef PyMessageListener listener = <PyMessageListener> obj
        status = listener.consume_message(py_msgs)
        if status is None:
            return ConsumeStatus.CONSUME_SUCCESS
        return status


cdef class PyMessageListenerConcurrently(PyMessageListener):
    """Wrapper of MessageListenerConcurrently"""

    def __cinit__(self):
        self._impl_obj = new MessageListenerConcurrentlyWrapper(self, PyMessageListener.ConsumeMessage)


cdef class PyMessageListenerOrderly(PyMessageListener):
    """Wrapper of MessageListenerOrderly"""

    def __cinit__(self):
        self._impl_obj = new MessageListenerOrderlyWrapper(self, PyMessageListener.ConsumeMessage)


cdef class PyRPCHook:
    """Wrapper of RPCHook"""

    cdef shared_ptr[RPCHook] _impl_obj


cdef class PySessionCredentials:
    """Wrapper of SessionCredentials"""

    cdef SessionCredentials* _impl_obj

    def __cinit__(self):
        self._impl_obj = NULL

    def __dealloc__(self):
        del self._impl_obj

    def __init__(self, accessKey, secretKey, authChannel):
        self._impl_obj = new SessionCredentials(str2bytes(accessKey), str2bytes(secretKey), str2bytes(authChannel))


cdef class PyClientRPCHook(PyRPCHook):
    """Wrapper of ClientRPCHook"""

    def __init__(self, PySessionCredentials sessionCredentials):
        self._impl_obj.reset(new ClientRPCHook(deref(sessionCredentials._impl_obj)))


cdef class PyMQClientConfig:
    """Wrapper of MQClientConfig"""

    cdef MQClientConfig* _MQClientConfig_impl_obj

    def __cinit__(self):
        self._MQClientConfig_impl_obj = NULL

    cdef void set_MQClientConfig_impl_obj(self, MQClientConfig* obj):
        self._MQClientConfig_impl_obj = obj

    @property
    def group_name(self):
        return bytes2str(self._MQClientConfig_impl_obj.getGroupName())

    @group_name.setter
    def group_name(self, groupname):
        self._MQClientConfig_impl_obj.setGroupName(str2bytes(groupname))

    @property
    def namesrv_addr(self):
        return bytes2str(self._MQClientConfig_impl_obj.getNamesrvAddr())

    @namesrv_addr.setter
    def namesrv_addr(self, addr):
        self._MQClientConfig_impl_obj.setNamesrvAddr(str2bytes(addr))

    @property
    def instance_name(self):
        return bytes2str(self._MQClientConfig_impl_obj.getInstanceName())

    @instance_name.setter
    def instance_name(self, name):
        self._MQClientConfig_impl_obj.setInstanceName(str2bytes(name))


cdef class PyDefaultMQProducer(PyMQClientConfig):
    """Wrapper of DefaultMQProducer"""

    cdef DefaultMQProducer* _impl_obj

    def __cinit__(self):
        self._impl_obj = NULL

    def __dealloc__(self):
        del self._impl_obj

    def __init__(self, groupname, PyRPCHook rpcHook=None):
        if rpcHook is None:
            self._impl_obj = new DefaultMQProducer(str2bytes(groupname))
        else:
            self._impl_obj = new DefaultMQProducer(str2bytes(groupname), rpcHook._impl_obj)
        PyMQClientConfig.set_MQClientConfig_impl_obj(self, self._impl_obj)

    @property
    def send_latency_fault_enable(self):
        return deref(self._impl_obj).isSendLatencyFaultEnable()

    @send_latency_fault_enable.setter
    def send_latency_fault_enable(self, enable):
        deref(self._impl_obj).setSendLatencyFaultEnable(enable)

    #
    # MQProducer

    def start(self):
        deref(self._impl_obj).start()

    def shutdown(self):
        with nogil:
            deref(self._impl_obj).shutdown()

    def send(self, PyMessage msg, PyMessageQueue mq=None, long timeout=-1):
        cdef SendResult ret
        if mq is None:
            if timeout > 0:
                ret = deref(self._impl_obj).send(msg._MQMessage_impl_obj, timeout)
            else:
                ret = deref(self._impl_obj).send(msg._MQMessage_impl_obj)
        else:
            if timeout > 0:
                ret = deref(self._impl_obj).send(msg._MQMessage_impl_obj, deref(mq._MQMessageQueue_impl_obj), timeout)
            else:
                ret = deref(self._impl_obj).send(msg._MQMessage_impl_obj, deref(mq._MQMessageQueue_impl_obj))
        return PySendResult.from_result(&ret)

    def sendOneway(self, PyMessage msg, PyMessageQueue mq=None):
        if mq is None:
            deref(self._impl_obj).sendOneway(msg._MQMessage_impl_obj)
        else:
            deref(self._impl_obj).sendOneway(msg._MQMessage_impl_obj, deref(mq._MQMessageQueue_impl_obj))

    def request(self, PyMessage msg, long timeout):
        cdef MQMessage* reply
        reply = deref(self._impl_obj).request(msg._MQMessage_impl_obj,  timeout)
        return PyMessageGuard.from_message(reply)


cdef class PyDefaultMQPushConsumer(PyMQClientConfig):
    """Wrapper of DefaultMQPushConsumer"""

    cdef DefaultMQPushConsumer* _impl_obj
    cdef PyMessageListener listener

    def __cinit__(self):
        self._impl_obj = NULL

    def __dealloc__(self):
        del self._impl_obj

    def __init__(self, groupname, PyRPCHook rpcHook=None):
        if rpcHook is None:
            self._impl_obj = new DefaultMQPushConsumer(str2bytes(groupname))
        else:
            self._impl_obj = new DefaultMQPushConsumer(str2bytes(groupname), rpcHook._impl_obj)
        PyMQClientConfig.set_MQClientConfig_impl_obj(self, self._impl_obj)

        self.listener = None

    @property
    def consume_thread_num(self):
        return deref(self._impl_obj).getConsumeThreadNum()

    @consume_thread_num.setter
    def consume_thread_num(self, num):
        deref(self._impl_obj).setConsumeThreadNum(num)

    @property
    def consume_message_batch_max_size(self):
        return deref(self._impl_obj).getConsumeMessageBatchMaxSize()

    @consume_message_batch_max_size.setter
    def consume_message_batch_max_size(self, size):
        deref(self._impl_obj).setConsumeMessageBatchMaxSize(size)

    @property
    def max_cache_msg_size_pre_queue(self):
        return deref(self._impl_obj).getMaxCacheMsgSizePerQueue()

    @max_cache_msg_size_pre_queue.setter
    def max_cache_msg_size_pre_queue(self, size):
        deref(self._impl_obj).setMaxCacheMsgSizePerQueue(size)

    #
    # MQPushConsumer

    def start(self):
        deref(self._impl_obj).start()

    def shutdown(self):
        with nogil:
            deref(self._impl_obj).shutdown()

    cpdef registerMessageListener(self, PyMessageListener messageListener):
        deref(self._impl_obj).registerMessageListener(messageListener._impl_obj)
        self.listener = messageListener

    def subscribe(self, topic, sub_expression):
        deref(self._impl_obj).subscribe(str2bytes(topic), str2bytes(sub_expression))
