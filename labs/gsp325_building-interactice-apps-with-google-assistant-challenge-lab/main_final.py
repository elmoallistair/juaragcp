# script for last task

import random
import logging
import google.cloud.logging
from google.cloud import translate_v2 as translate
from flask import Flask, request, make_response, jsonify

def magic_eight_ball(request):

    client = google.cloud.logging.Client()
    client.get_default_handler()
    client.setup_logging()

    choices = [
        "It is certain.", "It is decidedly so.", "Without a doubt.",
        "Yes - definitely.", "You may rely on it.", "As I see it, yes.",
        "Most likely.", "Outlook good.", "Yes.","Signs point to yes.",
        "Reply hazy, try again.", "Ask again later.",
        "Better not tell you now.", "Cannot predict now.",
        "Concentrate and ask again.", "Don't count on it.",
        "My reply is no.", "My sources say no.", "Outlook not so good.",
        "Very doubtful."
    ]

    magic_eight_ball_response = random.choice(choices)

    request_json = request.get_json()

    if request_json and 'queryResult' in request_json:
        question = request_json.get('queryResult').get('queryText')

    # try to identify the language
    language = 'en'
    translate_client = translate.Client()
    detected_language = translate_client.detect_language(question)
    if detected_language['language'] == 'und':
        language = 'en'
    elif detected_language['language'] != 'en':
        language = detected_language['language']

    # translate if not english
    if language != 'en':
        logging.info('translating from en to %s' % language)
        translated_text = translate_client.translate(
             magic_eight_ball_response, target_language=language)
        magic_eight_ball_response = translated_text['translatedText']

    logging.info(magic_eight_ball_response)

    return make_response(jsonify({'fulfillmentText': magic_eight_ball_response }))