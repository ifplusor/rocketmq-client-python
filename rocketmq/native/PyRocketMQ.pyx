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
from libcpp.cast cimport dynamic_cast
from libcpp.memory cimport shared_ptr
from libcpp.string cimport string
from libcpp.vector cimport vector

# import dereference and increment operators
from cython.operator cimport dereference as deref, address as addrs, preincrement as inc

# import native SDK API
from rocketmq cimport Message, MessageExt, MQMessage, MQMessageExt, MQMessageQueue, MessageUtil
from rocketmq cimport SendStatus, SendResult
from rocketmq cimport ConsumeStatus, MessageListenerWrapper, MessageListenerConcurrentlyWrapper, MessageListenerOrderlyWrapper
from rocketmq cimport RPCHook, SessionCredentials, ClientRPCHook
from rocketmq cimport MQClientConfig, DefaultMQProducer, DefaultMQPushConsumer, DefaultLitePullConsumer

import sys

is_py2 = bool(sys.version_info[0] == 2)


if is_py2:
    def str2bytes(s):
        if type(s) is unicode:
            return s.encode("utf-8")
        return s

    def bytes2str(b):
        return b

else:
    def str2bytes(s):
        if type(s) is str:
            return s.encode("utf-8")
        return s

    def bytes2str(b):
        return b.decode("utf-8")


ctypedef MessageExt* MessageExtPtr


cdef class PyMessage:
    """Wrapper of MQMessage"""

    cdef shared_ptr[Message] message_impl_

    def __cinit__(self):
        if type(self) is PyMessage:
            self.message_impl_ = MQMessage().getMessageImpl()

    cdef MQMessage get_message(self):
        return MQMessage(self.message_impl_)

    cdef void set_message_impl(self, shared_ptr[Message] message_impl):
        self.message_impl_ = message_impl

    def __init__(self, topic=None, body=None, tags=None, keys=None):
        if topic is not None:
            self.topic = topic
        if body is not None:
            self.body = body
        if tags is not None:
            self.tags = tags
        if keys is not None:
            self.keys = keys

    @property
    def topic(self):
        return bytes2str(deref(self.message_impl_).topic())

    @topic.setter
    def topic(self, topic):
        deref(self.message_impl_).set_topic(str2bytes(topic))

    @property
    def tags(self):
        return bytes2str(deref(self.message_impl_).tags())

    @tags.setter
    def tags(self, tags):
        deref(self.message_impl_).set_tags(str2bytes(tags))

    @property
    def keys(self):
        return bytes2str(deref(self.message_impl_).keys())

    @keys.setter
    def keys(self, keys):
        if isinstance(keys, str):
            deref(self.message_impl_).set_keys(<string> str2bytes(keys))
        elif isinstance(keys, list) or isinstance(keys, tuple) or isinstance(keys, set):
            new_keys = map(lambda key: str2bytes(key), keys)
            deref(self.message_impl_).set_keys(<vector[string]> new_keys)

    @property
    def delay_time_level(self):
        return deref(self.message_impl_).delay_time_level()

    @delay_time_level.setter
    def delay_time_level(self, delay_time_level):
        deref(self.message_impl_).set_delay_time_level(delay_time_level)

    @property
    def wait_store_msg_ok(self):
        return deref(self.message_impl_).wait_store_msg_ok()

    @wait_store_msg_ok.setter
    def wait_store_msg_ok(self, wait_store_msg_ok):
        deref(self.message_impl_).set_wait_store_msg_ok(wait_store_msg_ok)

    @property
    def flag(self):
        return deref(self.message_impl_).flag()

    @flag.setter
    def flag(self, flag):
        deref(self.message_impl_).set_flag(flag)

    @property
    def body(self):
        return deref(self.message_impl_).body()

    @body.setter
    def body(self, body):
        deref(self.message_impl_).set_body(str2bytes(body))

    @property
    def transaction_id(self):
        return deref(self.message_impl_).transaction_id()

    @transaction_id.setter
    def transaction_id(self, transaction_id):
        deref(self.message_impl_).set_transaction_id(str2bytes(transaction_id))

    def get_property(self, name):
        return bytes2str(deref(self.message_impl_).getProperty(str2bytes(name)))

    def put_property(self, name, value):
        deref(self.message_impl_).putProperty(str2bytes(name), str2bytes(value))

    def clear_property(self, name):
        deref(self.message_impl_).clearProperty(str2bytes(name))

    def __str__(self):
        return bytes2str(deref(self.message_impl_).toString())


cdef class PyMessageGuard(PyMessage):

    @staticmethod
    cdef PyMessage from_message(MQMessage& message):
        ret = PyMessageGuard()
        ret.set_message_impl(message.getMessageImpl())
        return ret


cdef class PyMessageExt(PyMessage):
    """Wrapper of MQMessageExt"""

    @staticmethod
    cdef PyMessageExt from_message_ext(MQMessageExt& message):
        ret = PyMessageExt()
        ret.set_message_impl(message.getMessageImpl())
        return ret

    @property
    def store_size(self):
        return dynamic_cast[MessageExtPtr](self.message_impl_.get()).store_size()

    @property
    def body_crc(self):
        return dynamic_cast[MessageExtPtr](self.message_impl_.get()).body_crc()

    @property
    def queue_id(self):
        return dynamic_cast[MessageExtPtr](self.message_impl_.get()).queue_id()

    @property
    def queue_offset(self):
        return dynamic_cast[MessageExtPtr](self.message_impl_.get()).queue_offset()

    @property
    def commit_log_offset(self):
        return dynamic_cast[MessageExtPtr](self.message_impl_.get()).commit_log_offset()

    @property
    def sys_flag(self):
        return dynamic_cast[MessageExtPtr](self.message_impl_.get()).sys_flag()

    @property
    def born_timestamp(self):
        return dynamic_cast[MessageExtPtr](self.message_impl_.get()).born_timestamp()

    @property
    def born_host(self):
        return bytes2str(dynamic_cast[MessageExtPtr](self.message_impl_.get()).born_host_string())

    @property
    def store_timestamp(self):
        return dynamic_cast[MessageExtPtr](self.message_impl_.get()).store_timestamp()

    @property
    def store_host(self):
        return bytes2str(dynamic_cast[MessageExtPtr](self.message_impl_.get()).store_host_string())

    @property
    def reconsume_times(self):
        return dynamic_cast[MessageExtPtr](self.message_impl_.get()).reconsume_times()

    @property
    def prepared_transaction_offset(self):
        return dynamic_cast[MessageExtPtr](self.message_impl_.get()).prepared_transaction_offset()

    @property
    def msg_id(self):
        return bytes2str(dynamic_cast[MessageExtPtr](self.message_impl_.get()).msg_id())


cdef class PyMessageQueue:
    """Wrapper of MQMessageQueue"""

    cdef MQMessageQueue* message_queue_impl_

    def __cinit__(self):
        self.message_queue_impl_ = NULL

    def __dealloc__(self):
        del self.message_queue_impl_

    def __init__(self, topic=None, broker_name=None, queue_id=None):
        if topic is None or broker_name is None or queue_id is None:
            self.message_queue_impl_ = new MQMessageQueue()
        else:
            self.message_queue_impl_ = new MQMessageQueue(str2bytes(topic), str2bytes(broker_name), queue_id)

    @staticmethod
    cdef PyMessageQueue from_message_queue(const MQMessageQueue* mq):
        ret = PyMessageQueue()
        ret.message_queue_impl_[0] = deref(mq)
        return ret

    @property
    def topic(self):
        return bytes2str(self.message_queue_impl_.topic())

    @topic.setter
    def topic(self, topic):
        self.message_queue_impl_.set_topic(str2bytes(topic))

    @property
    def broker_name(self):
        return bytes2str(self.message_queue_impl_.broker_name())

    @broker_name.setter
    def broker_name(self, broker_name):
        self.message_queue_impl_.set_broker_name(str2bytes(broker_name))

    @property
    def queue_id(self):
        return self.message_queue_impl_.queue_id()

    @queue_id.setter
    def queue_id(self, queue_id):
        self.message_queue_impl_.set_queue_id(queue_id)

    def __str__(self):
        return bytes2str(self.message_queue_impl_.toString())


def create_reply_message(PyMessage request, body):
    cdef MQMessage reply = MessageUtil.createReplyMessage(request.get_message(), str2bytes(body))
    return PyMessageGuard.from_message(reply)


cpdef enum PySendStatus:
    SEND_OK = SendStatus.SEND_OK
    SEND_FLUSH_DISK_TIMEOUT = SendStatus.SEND_FLUSH_DISK_TIMEOUT
    SEND_FLUSH_SLAVE_TIMEOUT = SendStatus.SEND_FLUSH_SLAVE_TIMEOUT
    SEND_SLAVE_NOT_AVAILABLE = SendStatus.SEND_SLAVE_NOT_AVAILABLE


cdef class PySendResult:
    """Wrapper of SendResult"""

    cdef SendResult* send_result_impl_

    def __cinit__(self):
        self.send_result_impl_ = NULL

    def __dealloc__(self):
        del self.send_result_impl_

    @staticmethod
    cdef PySendResult from_result(SendResult* result):
        ret = PySendResult()
        ret.send_result_impl_ = new SendResult(deref(result))
        return ret

    @property
    def send_status(self):
        return PySendStatus(self.send_result_impl_.send_status())

    @property
    def msg_id(self):
        return bytes2str(self.send_result_impl_.msg_id())

    @property
    def offset_msg_id(self):
        return bytes2str(self.send_result_impl_.offset_msg_id())

    @property
    def message_queue(self):
        return PyMessageQueue.from_message_queue(addrs(self.send_result_impl_.message_queue()))

    @property
    def queue_offset(self):
        return self.send_result_impl_.queue_offset()

    @property
    def transaction_id(self):
        return bytes2str(self.send_result_impl_.transaction_id())

    def __str__(self):
        return bytes2str(self.send_result_impl_.toString())


cdef class PySendCallback:
    """Wrapper of SendCallback"""
    pass


cpdef enum PyConsumeStatus:
    CONSUME_SUCCESS = ConsumeStatus.CONSUME_SUCCESS
    RECONSUME_LATER = ConsumeStatus.RECONSUME_LATER


cdef class PyMessageListener:
    """Wrapper of MQMessageListener"""

    cdef MessageListenerWrapper* message_listener_impl_

    def __cinit__(self):
        self.message_listener_impl_ = NULL

    def __dealloc(self):
        del self.message_listener_impl_

    def consume_message(self, msgs):
        """Callback for consume message in python, return PyConsumeStatus or None."""
        return PyConsumeStatus.RECONSUME_LATER

    @staticmethod
    cdef ConsumeStatus ConsumeMessage(object obj, vector[MQMessageExt]& msgs) with gil:
        # callback by native SDK in another thread need declare GIL.

        py_message_ext_list = list()
        cdef vector[MQMessageExt].iterator it = msgs.begin()
        while it != msgs.end():
            message_ext = PyMessageExt.from_message_ext(deref(it))
            py_message_ext_list.append(message_ext)
            inc(it)

        cdef PyMessageListener listener = <PyMessageListener> obj
        status = listener.consume_message(py_message_ext_list)
        if status is None:
            return ConsumeStatus.CONSUME_SUCCESS
        return status


cdef class PyMessageListenerConcurrently(PyMessageListener):
    """Wrapper of MessageListenerConcurrently"""

    def __cinit__(self):
        self.message_listener_impl_ = new MessageListenerConcurrentlyWrapper(self, PyMessageListener.ConsumeMessage)


cdef class PyMessageListenerOrderly(PyMessageListener):
    """Wrapper of MessageListenerOrderly"""

    def __cinit__(self):
        self.message_listener_impl_ = new MessageListenerOrderlyWrapper(self, PyMessageListener.ConsumeMessage)


cdef class PyRPCHook:
    """Wrapper of RPCHook"""

    cdef shared_ptr[RPCHook] rpc_hook_impl_


cdef class PySessionCredentials:
    """Wrapper of SessionCredentials"""

    cdef SessionCredentials* session_credentials_

    def __cinit__(self):
        self.session_credentials_ = NULL

    def __dealloc__(self):
        del self.session_credentials_

    def __init__(self, access_key, secret_key, auth_channel):
        self.session_credentials_ = new SessionCredentials(str2bytes(access_key), str2bytes(secret_key), str2bytes(auth_channel))


cdef class PyClientRPCHook(PyRPCHook):
    """Wrapper of ClientRPCHook"""

    def __init__(self, PySessionCredentials sessionCredentials):
        self.rpc_hook_impl_.reset(new ClientRPCHook(deref(sessionCredentials.session_credentials_)))


cdef class PyMQClientConfig:
    """Wrapper of MQClientConfig"""

    cdef MQClientConfig* client_config_impl_

    def __cinit__(self):
        self.client_config_impl_ = NULL

    cdef void set_client_config_impl(self, MQClientConfig* client_config_impl):
        self.client_config_impl_ = client_config_impl

    @property
    def group_name(self):
        return bytes2str(self.client_config_impl_.group_name())

    @group_name.setter
    def group_name(self, group_name):
        self.client_config_impl_.set_group_name(str2bytes(group_name))

    @property
    def namesrv_addr(self):
        return bytes2str(self.client_config_impl_.namesrv_addr())

    @namesrv_addr.setter
    def namesrv_addr(self, namesrv_addr):
        self.client_config_impl_.set_namesrv_addr(str2bytes(namesrv_addr))

    @property
    def instance_name(self):
        return bytes2str(self.client_config_impl_.instance_name())

    @instance_name.setter
    def instance_name(self, instance_name):
        self.client_config_impl_.set_instance_name(str2bytes(instance_name))


cdef class PyDefaultMQProducer(PyMQClientConfig):
    """Wrapper of DefaultMQProducer"""

    cdef DefaultMQProducer* producer_impl_

    def __cinit__(self):
        self.producer_impl_ = NULL

    def __dealloc__(self):
        del self.producer_impl_

    def __init__(self, group_name, PyRPCHook rpc_hook=None):
        if rpc_hook is None:
            self.producer_impl_ = new DefaultMQProducer(str2bytes(group_name))
        else:
            self.producer_impl_ = new DefaultMQProducer(str2bytes(group_name), rpc_hook.rpc_hook_impl_)
        PyMQClientConfig.set_client_config_impl(self, self.producer_impl_)

    @property
    def max_message_size(self):
        return deref(self.producer_impl_).max_message_size()

    @max_message_size.setter
    def max_message_size(self, max_message_size):
        deref(self.producer_impl_).set_max_message_size(max_message_size);

    @property
    def compress_msg_body_over_howmuch(self):
        return deref(self.producer_impl_).compress_msg_body_over_howmuch()

    @compress_msg_body_over_howmuch.setter
    def compress_msg_body_over_howmuch(self, compress_msg_body_over_howmuch):
        deref(self.producer_impl_).set_compress_msg_body_over_howmuch(compress_msg_body_over_howmuch)

    @property
    def compress_level(self):
        return deref(self.producer_impl_).compress_level()

    @compress_level.setter
    def compress_level(self, compress_level):
        deref(self.producer_impl_).set_compress_level(compress_level)

    @property
    def send_msg_timeout(self):
        return deref(self.producer_impl_).send_msg_timeout()

    @send_msg_timeout.setter
    def send_msg_timeout(self, send_msg_timeout):
        deref(self.producer_impl_).set_send_msg_timeout(send_msg_timeout)

    @property
    def retry_times(self):
        return deref(self.producer_impl_).retry_times()

    @retry_times.setter
    def retry_times(self, retry_times):
        deref(self.producer_impl_).set_retry_times(retry_times)

    @property
    def retry_times_for_async(self):
        return deref(self.producer_impl_).retry_times_for_async()

    @retry_times_for_async.setter
    def retry_times_for_async(self, retry_times_for_async):
        deref(self.producer_impl_).set_retry_times_for_async(retry_times_for_async)

    @property
    def retry_another_broker_when_not_store_ok(self):
        return deref(self.producer_impl_).retry_another_broker_when_not_store_ok()

    @retry_another_broker_when_not_store_ok.setter
    def retry_another_broker_when_not_store_ok(self, retry_another_broker_when_not_store_ok):
        deref(self.producer_impl_).set_retry_another_broker_when_not_store_ok(retry_another_broker_when_not_store_ok)

    @property
    def send_latency_fault_enable(self):
        return deref(self.producer_impl_).send_latency_fault_enable()

    @send_latency_fault_enable.setter
    def send_latency_fault_enable(self, send_latency_fault_enable):
        deref(self.producer_impl_).set_send_latency_fault_enable(send_latency_fault_enable)

    #
    # MQProducer

    def start(self):
        deref(self.producer_impl_).start()

    def shutdown(self):
        with nogil:
            deref(self.producer_impl_).shutdown()

    def send(self, PyMessage msg, PyMessageQueue mq=None, long timeout=-1):
        cdef SendResult ret
        cdef MQMessage message = msg.get_message()
        if mq is None:
            if timeout > 0:
                ret = deref(self.producer_impl_).sync_send_with_timeout(message, timeout)
            else:
                ret = deref(self.producer_impl_).sync_send(message)
        else:
            if timeout > 0:
                ret = deref(self.producer_impl_).sync_send_to_mq_with_timeout(message, deref(mq.message_queue_impl_), timeout)
            else:
                ret = deref(self.producer_impl_).sync_send_to_mq(message, deref(mq.message_queue_impl_))
        return PySendResult.from_result(&ret)

    def send_oneway(self, PyMessage msg, PyMessageQueue mq=None):
        cdef MQMessage message = msg.get_message()
        if mq is None:
            deref(self.producer_impl_).oneway_send(message)
        else:
            deref(self.producer_impl_).oneway_send_to_mq(message, deref(mq.message_queue_impl_))

    def request(self, PyMessage msg, long timeout):
        cdef MQMessage message = msg.get_message()
        cdef MQMessage reply = deref(self.producer_impl_).request(message,  timeout)
        return PyMessageGuard.from_message(reply)


cdef class PyDefaultMQPushConsumer(PyMQClientConfig):
    """Wrapper of DefaultMQPushConsumer"""

    cdef DefaultMQPushConsumer* consumer_impl_
    cdef PyMessageListener listener

    def __cinit__(self):
        self.consumer_impl_ = NULL

    def __dealloc__(self):
        del self.consumer_impl_

    def __init__(self, group_name, PyRPCHook rpc_hook=None):
        if rpc_hook is None:
            self.consumer_impl_ = new DefaultMQPushConsumer(str2bytes(group_name))
        else:
            self.consumer_impl_ = new DefaultMQPushConsumer(str2bytes(group_name), rpc_hook.rpc_hook_impl_)
        PyMQClientConfig.set_client_config_impl(self, self.consumer_impl_)

        self.listener = None

    @property
    def consume_thread_nums(self):
        return deref(self.consumer_impl_).consume_thread_nums()

    @consume_thread_nums.setter
    def consume_thread_nums(self, consume_thread_nums):
        deref(self.consumer_impl_).set_consume_thread_nums(consume_thread_nums)

    @property
    def pull_threshold_for_queue(self):
        return deref(self.consumer_impl_).pull_threshold_for_queue()

    @pull_threshold_for_queue.setter
    def pull_threshold_for_queue(self, pull_threshold_for_queue):
        deref(self.consumer_impl_).set_pull_threshold_for_queue(pull_threshold_for_queue)

    @property
    def consume_message_batch_max_size(self):
        return deref(self.consumer_impl_).consume_message_batch_max_size()

    @consume_message_batch_max_size.setter
    def consume_message_batch_max_size(self, consume_message_batch_max_size):
        deref(self.consumer_impl_).set_consume_message_batch_max_size(consume_message_batch_max_size)

    @property
    def pull_batch_size(self):
        return deref(self.consumer_impl_).pull_batch_size()

    @pull_batch_size.setter
    def pull_batch_size(self, pull_batch_size):
        deref(self.consumer_impl_).set_pull_batch_size(pull_batch_size)

    @property
    def max_reconsume_times(self):
        return deref(self.consumer_impl_).max_reconsume_times()

    @max_reconsume_times.setter
    def max_reconsume_times(self, max_reconsume_times):
        deref(self.consumer_impl_).set_max_reconsume_times(max_reconsume_times)

    @property
    def pull_time_delay_millis_when_exception(self):
        return deref(self.consumer_impl_).pull_time_delay_millis_when_exception()

    @pull_time_delay_millis_when_exception.setter
    def pull_time_delay_millis_when_exception(self, pull_time_delay_millis_when_exception):
        deref(self.consumer_impl_).set_pull_time_delay_millis_when_exception(pull_time_delay_millis_when_exception)

    #
    # MQPushConsumer

    def start(self):
        deref(self.consumer_impl_).start()

    def shutdown(self):
        with nogil:
            deref(self.consumer_impl_).shutdown()

    cpdef register_message_listener(self, PyMessageListener message_listener):
        if isinstance(message_listener, PyMessageListenerConcurrently):
            deref(self.consumer_impl_).register_message_listener_concurrently(<MessageListenerConcurrentlyWrapper*> message_listener.message_listener_impl_)
        elif isinstance(message_listener, PyMessageListenerOrderly):
            deref(self.consumer_impl_).register_message_listener_orderly(<MessageListenerOrderlyWrapper*> message_listener.message_listener_impl_)
        else:
            raise Exception("Unknown listener type.")
        self.listener = message_listener

    def subscribe(self, topic, sub_expression):
        deref(self.consumer_impl_).subscribe(str2bytes(topic), str2bytes(sub_expression))


cdef class PyDefaultLitePullConsumer(PyMQClientConfig):
    """Wrapper of DefaultLitePullConsumer"""

    cdef DefaultLitePullConsumer* consumer_impl_

    def __cinit__(self):
        self.consumer_impl_ = NULL

    def __dealloc__(self):
        del self.consumer_impl_

    def __init__(self, group_name, PyRPCHook rpc_hook=None):
        if rpc_hook is None:
            self.consumer_impl_ = new DefaultLitePullConsumer(str2bytes(group_name))
        else:
            self.consumer_impl_ = new DefaultLitePullConsumer(str2bytes(group_name), rpc_hook.rpc_hook_impl_)
        PyMQClientConfig.set_client_config_impl(self, self.consumer_impl_)

    @property
    def auto_commit(self):
        return deref(self.consumer_impl_).isAutoCommit()

    @auto_commit.setter
    def auto_commit(self, auto_commit):
        deref(self.consumer_impl_).setAutoCommit(auto_commit)

    @property
    def auto_commit_interval_millis(self):
        return deref(self.consumer_impl_).auto_commit_interval_millis()

    @auto_commit_interval_millis.setter
    def auto_commit_interval_millis(self, auto_commit_interval_millis):
        deref(self.consumer_impl_).set_auto_commit_interval_millis(auto_commit_interval_millis)

    @property
    def pull_batch_size(self):
        return deref(self.consumer_impl_).pull_batch_size()

    @pull_batch_size.setter
    def pull_batch_size(self, pull_batch_size):
        deref(self.consumer_impl_).set_pull_batch_size(pull_batch_size)

    @property
    def pull_thread_nums(self):
        return deref(self.consumer_impl_).pull_thread_nums()

    @pull_thread_nums.setter
    def pull_thread_nums(self, pull_thread_nums):
        deref(self.consumer_impl_).set_pull_thread_nums(pull_thread_nums)

    @property
    def long_polling_enable(self):
        return deref(self.consumer_impl_).long_polling_enable()

    @long_polling_enable.setter
    def long_polling_enable(self, long_polling_enable):
        deref(self.consumer_impl_).set_long_polling_enable(long_polling_enable)

    @property
    def consumer_pull_timeout_millis(self):
        return deref(self.consumer_impl_).consumer_pull_timeout_millis()

    @consumer_pull_timeout_millis.setter
    def consumer_pull_timeout_millis(self, consumer_pull_timeout_millis):
        deref(self.consumer_impl_).set_consumer_pull_timeout_millis(consumer_pull_timeout_millis)

    @property
    def consumer_timeout_millis_when_suspend(self):
        return deref(self.consumer_impl_).consumer_timeout_millis_when_suspend()

    @consumer_timeout_millis_when_suspend.setter
    def consumer_timeout_millis_when_suspend(self, consumer_timeout_millis_when_suspend):
        deref(self.consumer_impl_).set_consumer_timeout_millis_when_suspend(consumer_timeout_millis_when_suspend)

    @property
    def broker_suspend_max_time_millis(self):
        return deref(self.consumer_impl_).broker_suspend_max_time_millis()

    @broker_suspend_max_time_millis.setter
    def broker_suspend_max_time_millis(self, broker_suspend_max_time_millis):
        deref(self.consumer_impl_).set_broker_suspend_max_time_millis(broker_suspend_max_time_millis)

    @property
    def pull_threshold_for_all(self):
        return deref(self.consumer_impl_).pull_threshold_for_all()

    @pull_threshold_for_all.setter
    def pull_threshold_for_all(self, pull_threshold_for_all):
        deref(self.consumer_impl_).set_pull_threshold_for_all(pull_threshold_for_all)

    @property
    def pull_threshold_for_queue(self):
        return deref(self.consumer_impl_).pull_threshold_for_queue()

    @pull_threshold_for_queue.setter
    def pull_threshold_for_queue(self, pull_threshold_for_queue):
        deref(self.consumer_impl_).set_pull_threshold_for_queue(pull_threshold_for_queue)

    @property
    def pull_time_delay_millis_when_exception(self):
        return deref(self.consumer_impl_).pull_time_delay_millis_when_exception()

    @pull_time_delay_millis_when_exception.setter
    def pull_time_delay_millis_when_exception(self, pull_time_delay_millis_when_exception):
        deref(self.consumer_impl_).set_pull_time_delay_millis_when_exception(pull_time_delay_millis_when_exception)

    @property
    def poll_timeout_millis(self):
        return deref(self.consumer_impl_).poll_timeout_millis()

    @poll_timeout_millis.setter
    def poll_timeout_millis(self, poll_timeout_millis):
        deref(self.consumer_impl_).set_poll_timeout_millis(poll_timeout_millis)

    @property
    def topic_metadata_check_interval_millis(self):
        return deref(self.consumer_impl_).topic_metadata_check_interval_millis()

    @topic_metadata_check_interval_millis.setter
    def topic_metadata_check_interval_millis(self, topic_metadata_check_interval_millis):
        deref(self.consumer_impl_).set_topic_metadata_check_interval_millis(topic_metadata_check_interval_millis)

    #
    # LitePullConsumer

    def start(self):
        deref(self.consumer_impl_).start()

    def shutdown(self):
        with nogil:
            deref(self.consumer_impl_).shutdown()

    def subscribe(self, topic, sub_expression):
        deref(self.consumer_impl_).subscribe(str2bytes(topic), str2bytes(sub_expression))

    def poll(self, timeout=None):
        cdef vector[MQMessageExt] msgs
        if timeout is None:
            msgs = deref(self.consumer_impl_).poll_default()
        else:
            msgs = deref(self.consumer_impl_).poll_with_timeout(timeout)

        py_message_ext_list = list()
        cdef vector[MQMessageExt].iterator it = msgs.begin()
        while it != msgs.end():
            message_ext = PyMessageExt.from_message_ext(deref(it))
            py_message_ext_list.append(message_ext)
            inc(it)

        return py_message_ext_list
