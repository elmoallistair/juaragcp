# Task 1. Create an API key
export API_KEY=AIzaSyDjt9FLVPJbECuOxuU2Be4OYsQ0EC8RH8I # your_generated_api_key

# Task 2. Set up Google Docs and call the Natural Language API
# Follow instruction written on lab


# Task 3. Analyze syntax and parts of speech with the Natural Language API

# Create a JSON file called analyze-request.json
cat > analyze-request.json <<EOF_END
{
  "document":{
    "type":"PLAIN_TEXT",
    "content": "Google, headquartered in Mountain View, unveiled the new Android phone at the Consumer Electronic Show.  Sundar Pichai said in his keynote that users love their new Android phones."
  },
  "encodingType": "UTF8"
}
EOF_END

# Pass the request and save it into file
curl -s -H "Content-Type: application/json" \
-H "Authorization: Bearer $(gcloud auth print-access-token)" \
"https://language.googleapis.com/v1/documents:analyzeSyntax" \
-d @analyze-request.json > analyze-response.txt


# Task 4. Perform multilingual natural language processing
# Create a JSON file called multi-nl-request.json 
cat > multi-nl-request.json <<EOF_END
{
  "document":{
    "type":"PLAIN_TEXT",
    "content":"Le bureau japonais de Google est situé à Roppongi Hills, Tokyo."
  }
}
EOF_END

# Pass the request and save it into file
curl -s -H "Content-Type: application/json" \
-H "Authorization: Bearer $(gcloud auth print-access-token)" \
"https://language.googleapis.com/v1/documents:analyzeEntities" \
-d @multi-nl-request.json > multi-response.txt