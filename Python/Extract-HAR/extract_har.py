"""
Extracts images from a HAR file and saves them to a specified directory.

The script reads a HAR file named "src.har" and extracts all images with the MIME types "image/webp", "image/jpeg", and "image/png". The images are saved to a directory named "imgs" in the current working directory. The filenames of the images are based on the last segment of the URL used to request the image, and the file extension is based on the MIME type of the image.

Example usage:
    $ python extract_har.py
"""

import base64
import json
import os

# current directory
folder = os.path.dirname(os.path.realpath(__file__))

# imgs folder
img_folder = os.path.join(folder, "imgs")

# make sure the output directory exists before running!
if not os.path.exists(img_folder):
    os.makedirs(img_folder)

# read the HAR file
with open(os.path.join(folder, "src.har")) as f:
    har = json.loads(f.read())

# extract the images from the HAR file
for log in har["log"]["entries"]:
    mimetype = log["response"]["content"]["mimeType"]
    filename = log["request"]["url"].split("/")[-1]
    image64 = log["response"]["content"]["text"]

    if any([
        mimetype == "image/webp",
        mimetype == "image/jpeg",
        mimetype == "image/png"
    ]):
        ext = {
            "image/webp": "webp",
            "image/jpeg": "jpg",
            "image/png": "png",
        }.get(mimetype)
        file = os.path.join(img_folder, f"{filename}.{ext}")
        print(file)
        with open(file, "wb") as f:
            f.write(base64.b64decode(image64))
