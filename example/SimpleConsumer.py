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
try:
    from typing import List
except:
    pass

import time

from rocketmq import DefaultMQPushConsumer, MessageExt, ConsumeStatus, MessageListenerConcurrently


class MyListener(MessageListenerConcurrently):
    def __init__(self):
        pass

    def consume_message(self, msgs):  # type: (List[MessageExt]) -> ConsumeStatus
        for msg in msgs:
            print(msg.msg_id)
            print(msg)
        # return ConsumeStatus.RECONSUME_LATER


if __name__ == "__main__":
    consumer = DefaultMQPushConsumer("g_test_group")
    consumer.namesrv_addr = "127.0.0.1:9876"
    print(consumer.namesrv_addr)

    consumer.consume_thread_num = 1
    consumer.registerMessageListener(MyListener())
    consumer.subscribe("test_topic", "*")

    consumer.start()

    time.sleep(30)

    consumer.shutdown()
