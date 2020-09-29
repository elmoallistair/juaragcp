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

    logging.info(magic_eight_ball_response)

    return make_response(jsonify({'fulfillmentText': magic_eight_ball_response }))