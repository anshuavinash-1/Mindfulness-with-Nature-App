# Cloud Functions

This folder contains Firebase backend functions for role management and moderation.

## Functions

- setModeratorByEmail: Assign/remove `admin` and `owner` custom claims by target email.
- deleteCommunityPost: Admin/owner moderation delete for any community post.

## Deploy

1. Install dependencies:

```bash
cd functions
npm install
```

2. Deploy functions:

```bash
firebase deploy --only functions
```

## Notes

- `admin` and `owner` are Firebase Auth custom claims.
- Only callers who already have `admin` or `owner` can set admin.
- Only callers with `owner` can set/remove owner.
