import base64
import json
import os
import unittest


class TestExtractHar(unittest.TestCase):
    def setUp(self):
        self.har_file = "src.har"
        self.img_folder = "imgs"
        self.har_data = {
            "log": {
                "entries": [
                    {
                        "request": {
                            "url": "https://example.com/image1.jpg"
                        },
                        "response": {
                            "content": {
                                "mimeType": "image/jpeg",
                                "text": "iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAADUExURQAAAP///wAAAB4bHvIAAAACdFJOUwBA5thmAAAAJklEQVQY02NgGAWjYBSMglEwAAVQAAwqYh+gAAAABJRU5ErkJggg=="
                            }
                        }
                    },
                    {
                        "request": {
                            "url": "https://example.com/image2.png"
                        },
                        "response": {
                            "content": {
                                "mimeType": "image/png",
                                "text": "iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAADUExURQAAAP///wAAAB4bHvIAAAACdFJOUwBA5thmAAAAJklEQVQY02NgGAWjYBSMglEwAAVQAAwqYh+gAAAABJRU5ErkJggg=="
                            }
                        }
                    },
                    {
                        "request": {
                            "url": "https://example.com/image3.webp"
                        },
                        "response": {
                            "content": {
                                "mimeType": "image/webp",
                                "text": "iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAADUExURQAAAP///wAAAB4bHvIAAAACdFJOUwBA5thmAAAAJklEQVQY02NgGAWjYBSMglEwAAVQAAwqYh+gAAAABJRU5ErkJggg=="
                            }
                        }
                    }
                ]
            }
        }

        with open(self.har_file, "w") as f:
            f.write(json.dumps(self.har_data))

    def tearDown(self):
        os.remove(self.har_file)
        for file in os.listdir(self.img_folder):
            os.remove(os.path.join(self.img_folder, file))
        os.rmdir(self.img_folder)

    def test_extract_images(self):
        os.mkdir(self.img_folder)
        with open("extract_har.py", "r") as f:
            exec(f.read())
        self.assertTrue(os.path.exists(os.path.join(self.img_folder, "image1.jpg")))
        self.assertTrue(os.path.exists(os.path.join(self.img_folder, "image2.png")))
        self.assertTrue(os.path.exists(os.path.join(self.img_folder, "image3.webp")))
        with open(os.path.join(self.img_folder, "image1.jpg"), "rb") as f:
            self.assertEqual(f.read(), base64.b64decode(self.har_data["log"]["entries"][0]["response"]["content"]["text"]))
        with open(os.path.join(self.img_folder, "image2.png"), "rb") as f:
            self.assertEqual(f.read(), base64.b64decode(self.har_data["log"]["entries"][1]["response"]["content"]["text"]))
        with open(os.path.join(self.img_folder, "image3.webp"), "rb") as f:
            self.assertEqual(f.read(), base64.b64decode(self.har_data["log"]["entries"][2]["response"]["content"]["text"]))

if __name__ == "__main__":
    unittest.main()
