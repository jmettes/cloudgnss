from pyrtcm import pyrtcm 
import base64

def handler(event, context):
    data = base64.b64decode(event['data'])
    rtcm = pyrtcm.rtcm_t()
    pyrtcm.init_rtcm(rtcm)
    pyrtcm.load_data(data, rtcm)
    print(rtcm.msgtype)
    return rtcm.msgtype
