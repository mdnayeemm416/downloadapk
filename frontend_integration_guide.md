# API Endpoints Guide

**Base URL**: `/api`
**Authorization**: `Bearer <token>` (Required for all routes except `/auth/register` and `/auth/login`)

All responses use this generic wrapper format:
```json
{
  "status": true, // false on error (400, 403, 404, etc.)
  "message": "String context",
  "data": { ... } // Payload (omitted on error)
}
```

---

## Auth

### Register
`POST /auth/register`
**Body:**
```json
{ "username": "x", "email": "x@x.com", "password": "...", "bio": "Optional" }
```
**Response (201):**
```json
{ "status": true, "message": "...", "data": { "id": "...", "is_approved": 0 } }
```

### Login
`POST /auth/login`
**Body:**
```json
{ "email": "x@x.com", "password": "..." }
```
**Response (200):**
```json
{ "status": true, "message": "...", "data": { "user": { ... }, "token": "jwt..." } }
```

---

## Users

### Get My Active Score
`GET /users/me/score`
**Response (200):**
```json
{ "status": true, "message": "...", "data": { "effective_score": 14.5 } }
```

### Get User Profile
`GET /users/:id`
**Response (200):**
```json
{ "status": true, "message": "...", "data": { "user": { ... }, "links": [ ... ] } }
```

### Explore Users
`GET /users/explore`
**Response (200):**
```json
{ "status": true, "message": "...", "data": [ { ... } ] }
```

### Toggle Follow
`POST /users/:id/follow`
**Response (200):**
```json
{ "status": true, "message": "...", "data": { "followed": true } }
```

### Get Followers
`GET /users/:id/followers`
**Response (200):**
```json
{ "status": true, "message": "...", "data": [ { ... } ] }
```

### Get Following
`GET /users/:id/following`
**Response (200):**
```json
{ "status": true, "message": "...", "data": [ { ... } ] }
```

---

## Links

### Create Link
`POST /links`
**Body:**
```json
{ "title": "...", "url": "https://...", "description": "...", "tags": "#test" }
```
**Response (201):**
```json
{ "status": true, "message": "...", "data": { "id": "...", ... } }
```
*(Yields 403 status dynamically if user hits their max upload limits)*

### Get Global Feed
`GET /links?page=1&limit=10`
**Response (200):**
```json
{ "status": true, "message": "...", "data": [ { "id": "...", "title": "...", "like_count": 0, "comment_count": 0, ... } ] }
```

### Get Specific Link
`GET /links/:id`
*(Side-effect: Increments view counter)*
**Response (200):**
```json
{ "status": true, "message": "...", "data": { ... } }
```

### Toggle Like
`POST /links/:id/like`
**Response (200):**
```json
{ "status": true, "message": "...", "data": { "liked": true } }
```

### Add Comment
`POST /links/:id/comment`
**Body:**
```json
{ "text": "My comment" }
```
**Response (201):**
```json
{ "status": true, "message": "...", "data": { "id": "...", "text": "...", ... } }
```

### Get Link Comments
`GET /links/:id/comments`
**Response (200):**
```json
{ "status": true, "message": "...", "data": [ { ... } ] }
```

---

## Admin (Strictly `role === 'admin'`)

### Get All Users
`GET /admin/users`
**Response (200):** Array of all User objects inside `data`.

### Get Pending Approvals
`GET /admin/users/pending`
**Response (200):** Array of unapproved User objects inside `data`.

### User Manipulations (All PATCH)
- `PATCH /admin/users/:id/approve`
- `PATCH /admin/users/:id/reject`
- `PATCH /admin/users/:id/block`
- `PATCH /admin/users/:id/unblock`
- `PATCH /admin/users/:id/make-admin`
- `PATCH /admin/users/:id/remove-admin`
**Response (200):** 
```json
{ "status": true, "message": "...", "data": { "user": { ... } } }
```
