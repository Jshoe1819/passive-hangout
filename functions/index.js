const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);

// Create and Deploy Your First Cloud Functions
// https://firebase.google.com/docs/functions/write-firebase-functions

// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });

// exports.sendMsgNotification = functions.database.ref('/conversations/{conversationId}/messages')
//     .onCreate((snapshot, context) => {
//         const message = snapshot.val();
//         const senderUid = message.senderuid;
//         const receiverUid = message.receiverUid;
//         //const promises = [];

//         if (senderUid === receiverUid) {
//             //if sender is receiver, don't send notification
//             //promises.push(event.data.current.ref.remove());
//             //return Promise.all(promises);
//             return console.log('same');
//         }

//         const getInstanceIdPromise = admin.database().ref(`/users/${receiverUid}/instanceId`).once('value');
//         const getReceiverUidPromise = admin.auth().getUser(receiverUid);

//         return Promise.all([getInstanceIdPromise, getReceiverUidPromise]).then(results => {
//             const instanceId = results[0];//.val();
//             const receiver = results[1];
//             //console.log('notifying ' + receiverUid + ' about ' + message.content + ' from ' + senderUid);

//             if (!instanceId.hasChildren()) {
//       			return console.log('There are no notification tokens to send to.');
//     		}

//     		console.log('There are', instanceId.numChildren(), 'tokens to send notifications to.');
//     		console.log('Fetched receiver profile', receiver);

//             const payload = {
//                 notification: {
//                     title: 'You have a new message!',
//         			body: `${receiver.name} sent a new message.`
//         			//icon: follower.photoURL,
//                 },
//             };
//             const tokens = Object.keys(instanceId.val());

//             return admin.messaging().sendToDevice(tokens, payload);
// 		  }).then(response => {
// 		    // For each message check if there was an error.
// 		    const tokensToRemove = [];
// 		    response.results.forEach((result, index) => {
// 		      const error = result.error;
// 		      if (error) {
// 		        console.error('Failure sending notification to', tokens[index], error);
// 		        // Cleanup the tokens who are not registered anymore.
// 		        if (error.code === 'messaging/invalid-registration-token' || error.code === 'messaging/registration-token-not-registered') {
// 		          tokensToRemove.push(tokensSnapshot.ref.child(tokens[index]).remove());
// 		        }
// 		      }
// 		    });
// 		    return Promise.all(tokensToRemove);

//             // admin.messaging().sendToDevice(instanceId, payload)
//             //     .then(function (response) {
//             //         console.log("Successfully sent message:", response);
//             //     })
//             //     .catch(function (error) {
//             //         console.log("Error sending message:", error);
//             //     });
//         });
//     });

exports.makeUppercase = functions.database.ref('/conversations/{pushId}/messages').onCreate(event => {
    const original = event.data.val()
    console.log('Uppercasing', event.params.pushId, original)
    const uppercase = original.toUpperCase()
    console.log('test', uppercase)
    console.log('test2', event)
    return event.data.ref.parent.child('uppercase').set(uppercase)
})

