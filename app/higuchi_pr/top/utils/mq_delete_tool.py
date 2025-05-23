import json
import os
from typing import List
import requests


queue_name = "higuchi-pr-support-msg"  # ここにキュー名を入れてください
url = f"https://simplemq.tk1b.api.sacloud.jp/v1/queues/{queue_name}/messages"
api_key = os.getenv("SUPPORT_MSG_Q_API_KEY")

headers = {
    "Authorization": f"Bearer {api_key}",
    "Content-Type": "application/json",
}  # 送信したいデータ（例）


del_ids: List[str] = []

for i in range(30):
    response = requests.get(url, headers=headers)
    res_dic = json.loads(response.text)
    if len(res_dic["messages"]) == 0:
        break

    id = res_dic["messages"][0]["id"]
    del_ids.append(id)

for id in del_ids:
    url = f"https://simplemq.tk1b.api.sacloud.jp/v1/queues/{queue_name}/messages/{id}"
    response = requests.delete(url, headers=headers)

    print("Status Code:", response.status_code)
    print("Response Body:", response.text)
