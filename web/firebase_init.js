firebase.initializeApp({
  apiKey: "AIzaSyAILvI4UH7mpAYhXbZb-2UdRwf-qO4TsAw",
  authDomain: "asocijacije-hr.firebaseapp.com",
  projectId: "asocijacije-hr"
});

var _fbAuth = firebase.auth();
var _fbDb   = firebase.firestore();
_fbAuth.setPersistence(firebase.auth.Auth.Persistence.LOCAL);

function _fbEnsureAuth(cb) {
  if (_fbAuth.currentUser) { cb(_fbAuth.currentUser); return; }
  _fbAuth.signInAnonymously()
    .then(function(r) { cb(r.user); })
    .catch(function(e) { console.error("Firebase auth error:", e); cb(null); });
}

// callback signature: callback(ok_int, result_string)
// ok=1 success, ok=0 failure

window._fb_submit = function(name, score, time, mode, date_str, seed, callback) {
  _fbEnsureAuth(function(user) {
    if (!user) { callback(0, "auth_failed"); return; }
    _fbDb.collection("leaderboard").add({
      name: name, score: score, time: time,
      mode: mode, date: date_str, uid: user.uid, seed: seed
    }).then(function() {
      callback(1, user.uid);
    }).catch(function(e) {
      console.error("_fb_submit error:", e);
      callback(0, String(e));
    });
  });
};

window._fb_fetch_leaderboard = function(mode, date_str, limit, callback) {
  _fbDb.collection("leaderboard")
    .where("mode", "==", mode)
    .where("date", "==", date_str)
    .orderBy("score", "desc")
    .orderBy("time", "asc")
    .limit(limit)
    .get()
    .then(function(snap) {
      var arr = [];
      snap.forEach(function(d) { arr.push(d.data()); });
      callback(1, JSON.stringify(arr));
    }).catch(function(e) {
      console.error("_fb_fetch_leaderboard error:", e);
      callback(0, "[]");
    });
};

window._fb_fetch_rank = function(mode, date_str, score, callback) {
  _fbDb.collection("leaderboard")
    .where("mode", "==", mode)
    .where("date", "==", date_str)
    .where("score", ">", score)
    .get()
    .then(function(snap) {
      callback(1, String(snap.size + 1));
    }).catch(function(e) {
      console.error("_fb_fetch_rank error:", e);
      callback(0, "-1");
    });
};

window._fb_get_uid = function() {
  return _fbAuth.currentUser ? _fbAuth.currentUser.uid : "";
};
