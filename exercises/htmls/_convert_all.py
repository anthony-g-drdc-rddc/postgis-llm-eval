import os

for i in os.listdir("./"):
    if i.endswith(".html"):
        os.system("uv run html_to_md.py -i \"" + i + "\"")