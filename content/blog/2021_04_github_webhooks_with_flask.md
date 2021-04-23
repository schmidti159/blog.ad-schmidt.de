+++
title = "Consuming GitHub WebHooks with Python / Flask"
date = "2021-04-07T12:42:47+02:00"

description = "How to consume webhooks from GitHub with the python micro web framework flask"

tags = ["git", "2021", "flask", "python"]

math = true
+++
To update this blog automatically when a change was pushed to GitHub I wrote a small script to react to webhooks.

## tl;dr
1. Check [app.py](https://github.com/schmidti159/api.ad-schmidt.de/blob/main/app.py#L23) for the final code that can be used to consume GitHub Webhooks.
2. Deploy your code derived from this sample somewhere
3. Configure a webhook for your repository via “Setting“ > “Webhooks“ > “Add Webhook“
4. Test, debug, adjust and repeat.

## The components
### GitHub Webhooks
With webhooks GitHub will send a POST request to a custom URL endpoint for everything that happens in a repository. 
For this use case we will only look into the webhooks for pushes. So for every push that is made to the repository an event will be sent to the webhook.

However it is possible to send events for almost anything that happens to your repository (creating/status change of issues, comments on pull requests, discussions, releases, etc.)

### Flask
[Flask](https://flask.palletsprojects.com/) is a micro web framework that can be used to write simple rest endpoints in python. 

To provide a POST endpoint for the GitHub webhook to call is as easy as putting a decorator with the endpoint and method on a function:
```python
@app.route("/github-webhook", methods=['POST'])
def githubWebhook():
    pass
```

## Configuring GitHub
On GitHub open the repository and navigate to “Settings” > “Webhooks” and add a new webhook.

Enter the URL where your flask app will be deployed and select Content type 'application/json'.

For my use case it was enough to send just `push` events.

When you confirm this new webhook GitHub will send a ping to it, which will probably fail at this time.

## Writing the Flask App
To handle the events from the webhook, a function must be implemented in the flask app.py.

The payload of the event can be read as json from `request.json`. Depending on its values the application logic can perform actions:
```python

from flask import request

@app.route("/github-webhook", methods=['POST'])
def githubWebhook():
    content = request.json
    branch = content['ref'].partition('refs/heads/')[2]
    repository = content['repository']['full_name']
    if not checkBranchAndRepo(content, branch, repository):
        return 'skipped'
    checkoutAndDeploy(branch)
    return "ok"
```

The return value of the method will be returned to GitHub. It does not matter, what you send here, but it can be used for debugging purposes.

The structure of the json payload is described [here](https://docs.github.com/en/developers/webhooks-and-events/webhook-events-and-payloads#push)

## Securing the endpoint with a secret
If you looked closely when configuring the Webhook on GitHub, you might have seen, there is also a `secret`, that can be configured for the web hook.
This can be used to make sure that no one except GitHub is able to trigger any actions.

For the secret generate a long random passphrase (you don't need to remember it, just save it in a file).

For every http-call GitHub will use the the secret and calculate a [hmac](https://de.wikipedia.org/wiki/Keyed-Hash_Message_Authentication_Code) from the complete payload of the message. The hmac will then be sent as the header `X-Hub-Signature-256`.

So to verify the signature we have to calculate the same hmac and compare it with the header sent:
```python
from flask import request
import hmac
import hashlib
from secrets import API_SECRET

@app.route("/github-webhook", methods=['POST'])
def githubWebhook():
    if not verifySignature():
        return 'signature verification failed'

def verifySignature():
    signature = "sha256="+hmac.new(bytes(API_SECRET , 'utf-8'), msg = request.data, digestmod = hashlib.sha256).hexdigest().lower()
    return hmac.compare_digest(signature, request.headers['X-Hub-Signature-256'])
```

### `hmac.compare_digest`
Why use such a weird function to compare strings? A normal string compare seeks to be efficient. This means, that strings that differ in the first characters will result in faster (negative) comparison result.

In a security sensitive area, like comparing signatures this is bad as these timing differences can be used to send an message with the correct signature without knowing the secret. The attacker can send a random signature and measure how long the server takes to respond. He then changes the first character. When the server takes longer to respond, the character is probably correct and the attacker can try changing the second character until he has the correct signature.

For a signature with a length of $n$ with $m$ possible characters this attack only needs $n \cdot m$ tries instead of needing to brute force all possible $n^m$ combinations.

### `from secrets import API_SECRET`
**Never commit your secrets!**
In this case the secret is stored in [secrets.py](https://github.com/schmidti159/api.ad-schmidt.de/blob/main/secrets.py.template). This file is also added in the [.gitignore](https://github.com/schmidti159/api.ad-schmidt.de/blob/main/.gitignore#L5), so I also never accidentally add it.

Secrets are better kept in keystore like [KeePassXC](https://keepassxc.org/).

## Debugging
This is probably the most important part, if you plan to write this kind of app yourself.

On the page you used to add a new webhook to your repository GitHub will show all the requests it sent to your webhook including all headers, the payload and the response headers and body. You can even redeliver already delivered messages after you changed your app, to test the new behaviour.

So it is enough to do one push to your repository and then retrigger this one event as often as you need to fix your code.

For me there are currently more redeliveries than original events 😉

## Further reading
* GitHub Documentation on Webhooks: https://docs.github.com/en/developers/webhooks-and-events/about-webhooks
* Payload Documentation for all events issued by Webhooks (e.g. the push event): https://docs.github.com/en/developers/webhooks-and-events/webhook-events-and-payloads#push
* Deploying a flask app to [uberspace](https://uberspace.de): https://lab.uberspace.de/guide_flask.html
