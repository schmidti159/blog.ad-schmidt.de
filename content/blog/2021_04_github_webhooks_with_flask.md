+++
title = "Consuming GitHub WebHooks with Python / Flask"
date = "2021-04-07T12:42:47+02:00"

description = "How to consume webhooks from GitHub with the python micro web framework flask"

tags = ["git", "2021", "flask", "python"]
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

To provide a POST endpoint for the GitHub webhook to call is as easy as putting a decorator on a method:
```python
@app.route("/github-webhook", methods=['POST'])
def githubWebhook():
    pass
```

## Configuring GitHub

## Writing the Flask App

## Securing the endpoint with a secret

## Debugging

## Further reading
* GitHub Documentation on Webhooks: https://docs.github.com/en/developers/webhooks-and-events/about-webhooks
* Payload Documentation for all events issued by Webhooks (e.g. the push event): https://docs.github.com/en/developers/webhooks-and-events/webhook-events-and-payloads#push
* Deploying a flask app to [uberspace](https://uberspace.de): https://lab.uberspace.de/guide_flask.html
