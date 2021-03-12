# Build Interactive Apps with Google Assistant: Challenge Lab 
# https://www.qwiklabs.com/focuses/11881?parent=catalog


# Task 1: Create the Cloud Function for the Magic Eight Ball app for Google Assistant
    # TODO 1.1: Create a python Cloud Function
    - Go to Cloud Function (Navigation > Cloud Function)  
    - Create Function
        - *in create function section (Configuration)*
            - Function name: magic_eight_ball
            - Authentical: Allow unauthenticated invocations > SAVE
            - NEXT
        - *in create function section (Code)*
            - Runtime: Python 3.7
            - Entry point: magic_eight_ball
            - main.py and requirements.txt: paste given code
    - Deploy

    # TODO 1.2: Grant Cloud Functions Invoker to allUsers.
    - Click function name (magic_eight_ball)
    - Go to Permission tab
    - Check box row that contains allUser with Member: allUser and Role: Cloud Function Invoker

# Task 2: Create the Lab Magic 8 Ball app for Google Assistant
    # TODO 2.1: Create a fulfillment that enables a webhook to your cloud function created in task 1.
        - Go to Actions control (link in lab) or https://console.actions.google.com/
        - Click New Project and Choose your GCP Project ID
        - After login, click the Action Console logo (on uppper left) and select your project
        - *in action control*
            - *in Action Console Overview section*
                - Go to Quick Setup > Decide how your Action is invoked 
                    - *in Invocation section*
                        - Display name: your initial + magic 8 ball(ignore error)
                - Back to action control
                - Go to Build your action > Add Action(s) > Get started > Custom Intent > Build > Login Dialogflow
                    - *in Diagflow* # if login take too much time, try refresh
                        - Create Agent
                            - Agent name: magic_eight_ball
                            - Google Project: select your project ID
                            - CREATE
                        - Go to Fullfilment (left pane) tab 
                            - Enable webhook
                            - Insert URL with your Cloud Function Trigger URL (Go to your cloud function > Trigger tab > Copy the url) > SAVE
    # TODO 2.2: Create Default Welcome Intent Text Response to Welcome to the lab magic 8 ball, ask me a yes or no question and I will predict the future!
        - *in Diagflow*
            - Click Intents (left pane)
            - Click Default Welcome Intent
                - Scroll to Responses section
                - Click ADD RESPONSE > Text response
                    - Paste this: Welcome to the lab magic 8 ball, ask me a yes or no question and I will predict the future!
                - SAVE

    # TODO 2.3: Create Default Fallback Intent to enable Set this intent as end of conversation and enable Enable webhook call for this intent
        - *in Diagflow*
            - Click Intents (left pane)
            - Click Default Fallback Intent
                - Enable "Set this intent as end of conversation" in response section
                - Enable "Enable webhook call for this intent" in fulfillment section
                - SAVE

    # TODO 2.4: Testing 
        - *in Diagflow*
            - Click Integrations tab (left pane)
            - Click INTEGRATION SETTINGS > TEST
                - Enable Web & App Activity pop up will showed up > Visit Activity controls > Enable "Web & Activity" > Back to Test tab
            - *in Action Control Test tab
                - Click "Talk to <your_initial_name> magic 8 ball"
                - Type this: Will I complete this challenge lab?

# Task 3: Add multilingual support to your magic_eight_ball Cloud Function
    # TODO: Add multilingual support
        - *in your cloud function*
        - Edit
            - Add code to main.py (check main_final.py file)
            - DEPLOY
        - *in Action Control Test tab
            - Test this sentences:
                - 我会完成这个挑战实验室吗
                - ¿Completaré este laboratorio de desafío?
                - இந்த சவால் ஆய்வகத்தை நான் முடிக்கலாமா?
