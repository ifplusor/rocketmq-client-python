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
from rocketmq import DefaultMQProducer, Message, SendStatus

if __name__ == "__main__":
    producer = DefaultMQProducer("pg_test_group")
    producer.namesrv_addr = "127.0.0.1:9876"
    print(producer.namesrv_addr)

    producer.start()

    try:
        for i in range(10):
            msg = Message(topic="test_topic")
            msg.body = "body for test"
            result = producer.send(msg)
            print(result.send_status)
            if result.send_status == SendStatus.SEND_OK:
                print(result)
    except Exception as e:
        print(type(e))
        print(e)

    producer.shutdown()
