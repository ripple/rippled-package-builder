var SlackBot = require('slackbots');

const channel = 'decent-skynet'
const token   = process.env.SLACK_TOKEN
const name    = 'rpm-bot'
const icon    = ':rpm:'

export function postToSlack(message) {

  var bot = new SlackBot({
      token: token,
      name: name
  });

  var params = {
      icon_emoji: icon
  };

  bot.on('start', function() {
      bot.postMessageToChannel(channel, message, params);

      bot.ws.close()
  });
}
