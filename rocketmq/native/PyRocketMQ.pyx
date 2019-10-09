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
from libcpp.memory cimport shared_ptr
from libcpp.string cimport string
from libcpp.vector cimport vector

# import dereference and increment operators
from cython.operator cimport dereference as deref, preincrement as inc

# import native SDK API
from rocketmq cimport MQMessage, MQMessageExt
from rocketmq cimport SendStatus, SendResult
from rocketmq cimport ConsumeStatus, MessageListenerWrapper, MessageListenerConcurrentlyWrapper, MessageListenerOrderlyWrapper
from rocketmq cimport RPCHook, SessionCredentials, ClientRPCHook
from rocketmq cimport MQClient, DefaultMQProducer, DefaultMQPushConsumer

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

    cdef MQMessage*_MQMessage_impl_obj

    def __cinit__(self):
        if type(self) is PyMessage:
            self._MQMessage_impl_obj = new MQMessage()
        else:
            self._MQMessage_impl_obj = NULL

    def __dealloc__(self):
        if type(self) is PyMessage:
            del self._MQMessage_impl_obj

    cdef void set_MQMessage_impl_obj(self, MQMessage *obj):
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
    def wait_store_msg_ok(self, bint wait_store_msg_ok):
        # self._impl_obj.setWaitStoreMsgOk(wait_store_msg_ok)
        pass

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

cdef class PyMessageExt(PyMessage):
    """Wrapper of MQMessageExt"""

    cdef MQMessageExt*_MQMessageExt_impl_obj

    def __cinit__(self):
        self._MQMessageExt_impl_obj = NULL

    def __dealloc__(self):
        if type(self) is PyMessageExt:
            # del self._MQMessageExt_impl_obj
            pass

    cdef void set_MQMessageExt_impl_obj(self, MQMessageExt *obj):
        self._MQMessageExt_impl_obj = obj
        PyMessage.set_MQMessage_impl_obj(self, obj)

    @staticmethod
    cdef PyMessageExt from_message_ext(MQMessageExt*message):
        ret = PyMessageExt()
        ret.set_MQMessageExt_impl_obj(message)
        return ret

    @property
    def store_size(self):
        return self._MQMessageExt_impl_obj.getStoreSize()

    @property
    def body_crc(self):
        return self._MQMessageExt_impl_obj.getBodyCRC()

    @property
    def queue_id(self):
        return self._MQMessageExt_impl_obj.getQueueId()

    @property
    def queue_offset(self):
        return self._MQMessageExt_impl_obj.getQueueOffset()

    @property
    def commit_log_offset(self):
        return self._MQMessageExt_impl_obj.getCommitLogOffset()

    @property
    def sys_flag(self):
        return self._MQMessageExt_impl_obj.getSysFlag()

    @property
    def born_timestamp(self):
        return self._MQMessageExt_impl_obj.getBornTimestamp()

    @property
    def born_host(self):
        return bytes2str(self._MQMessageExt_impl_obj.getBornHostString())

    @property
    def store_timestamp(self):
        return self._MQMessageExt_impl_obj.getStoreTimestamp()

    @property
    def store_host(self):
        return bytes2str(self._MQMessageExt_impl_obj.getStoreHostString())

    @property
    def reconsume_times(self):
        return self._MQMessageExt_impl_obj.getReconsumeTimes()

    @property
    def prepared_transaction_offset(self):
        return self._MQMessageExt_impl_obj.getPreparedTransactionOffset()

    @property
    def msg_id(self):
        return bytes2str(self._MQMessageExt_impl_obj.getMsgId())

cpdef enum PySendStatus:
    SEND_OK = SendStatus.SEND_OK
    SEND_FLUSH_DISK_TIMEOUT = SendStatus.SEND_FLUSH_DISK_TIMEOUT
    SEND_FLUSH_SLAVE_TIMEOUT = SendStatus.SEND_FLUSH_SLAVE_TIMEOUT
    SEND_SLAVE_NOT_AVAILABLE = SendStatus.SEND_SLAVE_NOT_AVAILABLE

cdef class PySendResult:
    """Wrapper of SendResult"""

    cdef SendResult *_SendResult_impl_obj

    def __cinit__(self):
        self._SendResult_impl_obj = NULL

    def __dealloc__(self):
        del self._SendResult_impl_obj

    @staticmethod
    cdef PySendResult from_result(SendResult*result):
        ret = PySendResult()
        ret._SendResult_impl_obj = new SendResult(result[0])
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

    # MQMessageQueue getMessageQueue() const

    @property
    def queue_offset(self):
        return self._SendResult_impl_obj.getQueueOffset()

    @property
    def transaction_id(self):
        return bytes2str(self._SendResult_impl_obj.getTransactionId())

    def __str__(self):
        return bytes2str(self._SendResult_impl_obj.toString())

cpdef enum PyConsumeStatus:
    CONSUME_SUCCESS = ConsumeStatus.CONSUME_SUCCESS
    RECONSUME_LATER = ConsumeStatus.RECONSUME_LATER

cdef class PyMessageListener:
    """Wrapper of MQMessageListener"""

    cdef MessageListenerWrapper*_impl_obj

    def __cinit__(self):
        self._impl_obj = NULL

    def __dealloc(self):
        del self._impl_obj

    def consume_message(self, msgs):
        """Callback for consume message in python, return PyConsumeStatus or None."""
        return PyConsumeStatus.CONSUME_SUCCESS

    @staticmethod
    cdef ConsumeStatus ConsumeMessage(object obj, const vector[MQMessageExt*]& msgs) with gil:
        # callback by native SDK in another thread need declare GIL.

        msgs2 = list()
        cdef vector[MQMessageExt*].iterator it = (<vector[MQMessageExt*]> msgs).begin()
        while it != (<vector[MQMessageExt*]> msgs).end():
            msg = PyMessageExt.from_message_ext(deref(it))
            msgs2.append(msg)
            inc(it)

        cdef PyMessageListenerConcurrently listener = <PyMessageListenerConcurrently> obj
        status = listener.consume_message(msgs2)
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

    cdef SessionCredentials*_impl_obj

    def __cinit__(self):
        self._impl_obj = NULL

    def __dealloc__(self):
        del self._impl_obj

    def __init__(self, accessKey, secretKey, authChannel):
        self._impl_obj = new SessionCredentials(str2bytes(accessKey), str2bytes(secretKey), str2bytes(authChannel))

cdef class PyClientRPCHook(PyRPCHook):
    """Wrapper of ClientRPCHook"""

    def __init__(self, PySessionCredentials sessionCredentials):
        self._impl_obj.reset(new ClientRPCHook(sessionCredentials._impl_obj[0]))

cdef class PyMQClient:
    """Wrapper of MQClient"""

    cdef MQClient*_MQClient_impl_obj

    def __cinit__(self):
        self._MQClient_impl_obj = NULL

    cdef void set_MQClient_impl_obj(self, MQClient *obj):
        self._MQClient_impl_obj = obj

    @property
    def group_name(self):
        return bytes2str(self._MQClient_impl_obj.getGroupName())

    @group_name.setter
    def group_name(self, groupname):
        self._MQClient_impl_obj.setGroupName(str2bytes(groupname))

    @property
    def namesrv_addr(self):
        return bytes2str(self._MQClient_impl_obj.getNamesrvAddr())

    @namesrv_addr.setter
    def namesrv_addr(self, addr):
        self._MQClient_impl_obj.setNamesrvAddr(str2bytes(addr))

    @property
    def instance_name(self):
        return bytes2str(self._MQClient_impl_obj.getInstanceName())

    @instance_name.setter
    def instance_name(self, name):
        self._MQClient_impl_obj.setInstanceName(str2bytes(name))

    def start(self):
        self._MQClient_impl_obj.start()

    def shutdown(self):
        self._MQClient_impl_obj.shutdown()

cdef class PyDefaultMQProducer(PyMQClient):
    """Wrapper of DefaultMQProducer"""

    cdef DefaultMQProducer*_impl_obj

    def __cinit__(self):
        self._impl_obj = NULL

    def __dealloc__(self):
        del self._impl_obj

    def __init__(self, groupname, PyRPCHook rpcHook=None):
        if rpcHook is None:
            self._impl_obj = new DefaultMQProducer(str2bytes(groupname))
        else:
            self._impl_obj = new DefaultMQProducer(str2bytes(groupname), rpcHook._impl_obj)
        PyMQClient.set_MQClient_impl_obj(self, self._impl_obj)

    #
    # MQProducer

    def send(self, PyMessage msg):
        cdef SendResult ret = self._impl_obj.send(msg._MQMessage_impl_obj)
        return PySendResult.from_result(&ret)

cdef class PyDefaultMQPushConsumer(PyMQClient):
    """Wrapper of DefaultMQPushConsumer"""

    cdef DefaultMQPushConsumer*_impl_obj
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
        PyMQClient.set_MQClient_impl_obj(self, self._impl_obj)

        self.listener = None

    @property
    def consume_thread_num(self):
        return self._impl_obj.getConsumeThreadNum()

    @consume_thread_num.setter
    def consume_thread_num(self, num):
        self._impl_obj.setConsumeThreadNum(num)

    #
    # MQPushConsumer

    cpdef registerMessageListener(self, PyMessageListener messageListener):
        self._impl_obj.registerMessageListener(messageListener._impl_obj)
        self.listener = messageListener

    def subscribe(self, topic, sub_expression):
        self._impl_obj.subscribe(str2bytes(topic), str2bytes(sub_expression))
