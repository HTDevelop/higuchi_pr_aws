import base64
import json
import os
import requests
from typing import Dict, List


class SimpleMqAPI:
    def __init__(self) -> None:
        self.__api_key: str = os.getenv("SUPPORT_MSG_Q_API_KEY")
        self.__queue_name: str = "higuchi-pr-support-msg"
        self.__url: str = (
            f"https://simplemq.tk1b.api.sacloud.jp/v1/queues/{self.__queue_name}/messages"
        )
        self.__headers: Dict = {
            "Authorization": f"Bearer {self.__api_key}",
            "Content-Type": "application/json",
        }

    def post(self, msg: str) -> str:
        encoded_bytes = base64.b32encode(msg.encode("utf-8"))
        encoded_str = encoded_bytes.decode("ascii")
        data = {"content": encoded_str}

        return requests.post(self.__url, json=data, headers=self.__headers)

    def bulk_get(self, qty_max: int) -> List[str]:
        messages: List[str] = []

        for i in range(qty_max):
            response = requests.get(self.__url, headers=self.__headers)
            res_dic = json.loads(response.text)
            if len(res_dic["messages"]) == 0:
                break

            msg = res_dic["messages"][0]["content"]
            try:
                decoded_bytes = base64.b32decode(msg)
                msg = decoded_bytes.decode("utf-8")
            except Exception as e:
                pass  # デコード失敗はデコード不要文字列として扱う

            messages.append(msg)

        return messages
