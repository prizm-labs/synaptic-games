if (Meteor.isClient) {
  // counter starts at 0
  Session.setDefault("counter", 0);

  Template.hello.helpers({
    counter: function () {
      return Session.get("counter");
    }
  });

  Template.hello.events({
    'click button': function () {
      // increment the counter when button is clicked
      Session.set("counter", Session.get("counter") + 1);
    }
  });
}

if (Meteor.isServer) {

  Cards = new Mongo.Collection('cards');

  if(Cards.find().count() === 0) {
    // create 52 cards

    var documents = JSON.parse(Assets.getText('card-manifest_full.json'))['cards'];

    _.each( documents, function( doc ){
        Cards.insert(createNewCard(doc));
    });
  }

  Meteor.startup(function () {
    // code to run on server at startup

    Meteor.publish('cards', function() {
      return Cards.find();
    });

    Cards.allow({
      insert: function(userId, doc) {
        //return (userId && doc.owner === userId);
        return false;
      },

      remove: function(userId, doc) {
        //var allow = (userId && doc.owner === userId);
        //deleteRelatedThings(allow, doc);
        //return allow;
        return false;
      },

      update: function(userId, doc) {
        //return (userId && doc.owner === userId);
        return true;
      }
    });

  }); //end Meteor.startup
}

function createNewCard(doc) {

  return {
    class: doc[1],
    images: doc,
    revealed: true,
    owner: null,
    position: {
      x: 0,
      y: 0,
      z: 0
    }
  }
}
