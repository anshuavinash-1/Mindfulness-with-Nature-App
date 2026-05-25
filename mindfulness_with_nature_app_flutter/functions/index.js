const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

function hasModeratorClaims(claims) {
  return claims?.admin === true || claims?.owner === true;
}

exports.setModeratorByEmail = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "You must be signed in to manage moderator roles.",
    );
  }

  const caller = await admin.auth().getUser(context.auth.uid);
  if (!hasModeratorClaims(caller.customClaims || {})) {
    throw new functions.https.HttpsError(
      "permission-denied",
      "Only admins/owners can update moderator roles.",
    );
  }

  const email = String(data?.email || "").trim().toLowerCase();
  if (!email) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "A target email is required.",
    );
  }

  const setAdmin = data?.admin === true;
  const setOwner = data?.owner === true;
  const clearOwner = data?.owner === false;

  if ((setOwner || clearOwner) && caller.customClaims?.owner !== true) {
    throw new functions.https.HttpsError(
      "permission-denied",
      "Only owners can assign or remove owner role.",
    );
  }

  const targetUser = await admin.auth().getUserByEmail(email);
  const existing = targetUser.customClaims || {};
  const updated = {...existing};

  if (setAdmin) {
    updated.admin = true;
  } else if (data?.admin === false) {
    delete updated.admin;
  }

  if (setOwner) {
    updated.owner = true;
  } else if (clearOwner) {
    delete updated.owner;
  }

  await admin.auth().setCustomUserClaims(targetUser.uid, updated);

  return {
    uid: targetUser.uid,
    email: targetUser.email,
    claims: updated,
  };
});

exports.deleteCommunityPost = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "You must be signed in to delete posts.",
    );
  }

  const caller = await admin.auth().getUser(context.auth.uid);
  if (!hasModeratorClaims(caller.customClaims || {})) {
    throw new functions.https.HttpsError(
      "permission-denied",
      "Only admins/owners can delete arbitrary posts.",
    );
  }

  const postId = String(data?.postId || "").trim();
  if (!postId) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "postId is required.",
    );
  }

  const postRef = admin.firestore().collection("community_posts").doc(postId);
  const postDoc = await postRef.get();
  if (!postDoc.exists) {
    throw new functions.https.HttpsError(
      "not-found",
      "Post not found.",
    );
  }

  const imageUrl = postDoc.data()?.imageUrl;
  await postRef.delete();

  if (typeof imageUrl === "string" && imageUrl.length > 0) {
    try {
      const bucket = admin.storage().bucket();
      const bucketName = bucket.name;
      const marker = `/${bucketName}/o/`;
      const markerIndex = imageUrl.indexOf(marker);

      if (markerIndex !== -1) {
        const encodedPath = imageUrl.substring(markerIndex + marker.length).split("?")[0];
        const filePath = decodeURIComponent(encodedPath);
        await bucket.file(filePath).delete({ignoreNotFound: true});
      }
    } catch (error) {
      console.error("Image cleanup failed after post delete", error);
    }
  }

  return {deleted: true, postId};
});
