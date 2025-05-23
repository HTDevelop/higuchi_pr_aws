from typing import List
from django.views.generic import TemplateView
from django.http import JsonResponse
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.renderers import JSONRenderer
from top.utils.simple_mq_api import SimpleMqAPI
from top.serializers import MessageSerializer


class Top(TemplateView):
    template_name = "top.html"

    def get_context_data(self, **kwargs):
        ctx = super().get_context_data(**kwargs)
        return ctx


class MessageAPIView(APIView):
    renderer_classes = [JSONRenderer]

    def get(self, _):
        api: SimpleMqAPI = SimpleMqAPI()
        messages: List[str] = api.bulk_get(10)  # ひとまず10件固定

        return Response({"messages": messages}, status=status.HTTP_201_CREATED)

    def post(self, request):
        res_status = status.HTTP_201_CREATED
        res_msg = "メッセージありがとうございました！"

        serializer = MessageSerializer(data=request.data)

        if serializer.is_valid() is False:
            res_msg = "メッセージが不正です"

            if serializer.errors["msg"][-1].code == "blank":
                res_msg = "メッセージを入力してください"
                res_status = status.HTTP_400_BAD_REQUEST

            return Response({"message": res_msg}, status=res_status)

        msg = serializer.validated_data["msg"]
        api: SimpleMqAPI = SimpleMqAPI()
        response = api.post(msg)

        if response.status_code != 200:
            res_status = "送信失敗しました"
            res_status = status.HTTP_400_BAD_REQUEST

        return Response({"message": res_msg}, status=res_status)


def health_check(_):
    data = {"status": "200 OK"}
    return JsonResponse(data)
