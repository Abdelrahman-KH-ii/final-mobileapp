import requests, re, json
url='https://b1r-14n15-fertilizing.hf.space/'
r=requests.get(url, timeout=20)
print('status', r.status_code)
text=r.text
for pat in ['gradio_api','api/predict','/predict','config','app']:
    print(pat, pat in text)
print(text[:8000])
