const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp()

exports.sendNotification = functions
  .firestore.document('groupChats/{groupId}/chats/{chatId}')
  .onCreate((snap, context) => {

    const doc = snap.data()

    const message = doc.message
    const senderId = doc.userId
    const group = doc.group
    const sender = doc.sendBy

    const hashTag = group.substring(group.indexOf('_')+1)

    admin.firestore()
      .collection('groupChat_users')
      .doc(group)
      .collection('users')
      .get()
      .then(querySnapshot => {
        querySnapshot.forEach(userTo => {

          if(userTo.id !== senderId+'_'+sender){

            const payload = {
              notification :{
                title: hashTag,
                body: sender+": "+message,
                badge: '1',
                sound: 'default'
              }
            }

            admin
              .messaging()
              .sendToDevice(userTo.data().token, payload)
              .then(response => {
                console.log('Successfully sent message:', response)
                return;
              }).catch(error => {
                console.log('Error sending message:', error)
              })
            return;

          } else{
            console.log('Can not find user token or user is in chat')
          }
        })
        return;
      }).catch(error => {
        console.log('groupChat_users Error:', error)
      })
    return null
  })

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
