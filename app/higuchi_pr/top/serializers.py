from rest_framework import serializers


class MessageSerializer(serializers.Serializer):
    msg = serializers.CharField(max_length=300)
