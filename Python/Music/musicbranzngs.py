# Import the module
import json

import musicbrainzngs as mbz

# If you plan to submit data, authenticate
mbz.auth("jimbrig", "M1$$ysusy1993mb")

# Tell musicbrainz what your app is, and how to contact you
# (this step is required, as per the webservice access rules
# at http://wiki.musicbrainz.org/XML_Web_Service/Rate_Limiting )
mbz.set_useragent('TheRecordIndustry.io', '0.1')

# # If you are connecting to a different server
# musicbrainzngs.set_hostname("beta.musicbrainz.org")

artist_list = mbz.search_artists(query='2pac')['artist-list']
lst = artist_list[0]
print(json.dumps(lst, indent=4, sort_keys=True))
