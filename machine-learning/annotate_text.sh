curl -X POST \
-H "Authorization: Bearer "$(gcloud auth application-default print-access-token) \
-H "Content-Type: application/json; charset=utf-8" \
-d @annotate_text.body \
https://videointelligence.googleapis.com/v1/videos:annotate