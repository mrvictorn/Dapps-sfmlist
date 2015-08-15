Meteor.startup ->
  sAlert.config
    effect: 'genie',
    position: 'top-left',
    timeout: 2000,
    html: false,
    onRouteClose: true,
    stack: true,
    offset: 0