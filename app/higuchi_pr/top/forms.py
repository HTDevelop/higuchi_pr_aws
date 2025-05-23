from django import forms


class SupportMsgForm(forms.Form):
    msg = forms.CharField(label="メッセージ", max_length=300, widget=forms.Textarea)
