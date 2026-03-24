# API Endpoints Reference

This document describes all REST API endpoints used by the AlakhService platform.

> **Base URL**: `https://api.alakhservice.com/v1`
> **Auth**: Bearer JWT token in `Authorization` header

---

## Authentication

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/auth/send-otp` | Send OTP to phone number |
| `POST` | `/auth/verify-otp` | Verify OTP and get tokens |
| `POST` | `/auth/refresh` | Refresh access token |
| `POST` | `/auth/logout` | Revoke refresh token |

### POST `/auth/send-otp`

**Request:**
```json
{
  "phone": "+919876543210"
}
```

**Response:**
```json
{
  "message": "OTP sent",
  "expires_in": 300
}
```

---

## Users

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/users/me` | Get current user profile |
| `PUT` | `/users/me` | Update profile |
| `POST` | `/users/me/photo` | Upload profile photo |
| `DELETE` | `/users/me` | Delete account |
| `GET` | `/users/me/bookings` | Get user bookings |
| `GET` | `/users/me/notifications` | Get notifications |
| `PUT` | `/users/me/notifications/:id/read` | Mark notification read |

---

## Discovery

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/shops` | Search shops by location/filters |
| `GET` | `/shops/:id` | Get shop details |
| `GET` | `/shops/:id/services` | Get shop services |
| `GET` | `/shops/:id/reviews` | Get shop reviews |
| `GET` | `/shops/:id/slots` | Get available booking slots |
| `GET` | `/categories` | Get service categories |

### GET `/shops` Query Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `lat` | float | User latitude |
| `lng` | float | User longitude |
| `radius` | int | Search radius in meters (default: 5000) |
| `category` | string | Filter by category slug |
| `q` | string | Search query |
| `page` | int | Page number |
| `per_page` | int | Results per page (max: 50) |

---

## Bookings

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/bookings` | Create a booking |
| `GET` | `/bookings/:id` | Get booking details |
| `PUT` | `/bookings/:id/cancel` | Cancel booking |
| `GET` | `/bookings/:id/queue-position` | Get queue position |

### POST `/bookings` Request

```json
{
  "shop_id": "shop_abc123",
  "service_id": "svc_xyz789",
  "slot_id": "slot_20260324_1030",
  "notes": "Please arrive 5 min early"
}
```

---

## Payments

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/payments/initiate` | Initiate payment for a booking |
| `POST` | `/payments/verify` | Verify payment after gateway callback |
| `GET` | `/payments/:id` | Get payment details |
| `POST` | `/payments/:id/refund` | Request refund |
| `GET` | `/wallet` | Get wallet balance |
| `GET` | `/wallet/transactions` | Get wallet transactions |

---

## Disputes

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/disputes` | Raise a dispute |
| `GET` | `/disputes/:id` | Get dispute details |
| `POST` | `/disputes/:id/evidence` | Upload dispute evidence |

---

## Reviews

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/reviews` | Submit a review |
| `GET` | `/reviews/:id` | Get review |
| `PUT` | `/reviews/:id` | Edit review |
| `DELETE` | `/reviews/:id` | Delete review |

---

## Chat

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/chats` | Get all conversations |
| `GET` | `/chats/:shop_id` | Get conversation with shop |
| `POST` | `/chats/:shop_id/messages` | Send message |
| `GET` | `/chats/:shop_id/messages` | Get messages |

---

## Shop — Dashboard & Operations

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/shop/me` | Get shop profile |
| `PUT` | `/shop/me` | Update shop profile |
| `GET` | `/shop/me/dashboard` | Get dashboard KPIs |
| `GET` | `/shop/me/bookings` | Get shop bookings |
| `PUT` | `/shop/me/bookings/:id/status` | Update booking status |
| `GET` | `/shop/me/queue` | Get current queue |
| `POST` | `/shop/me/queue/next` | Call next customer |
| `POST` | `/shop/me/queue/:id/hold` | Hold a queue entry |
| `GET` | `/shop/me/staff` | Get staff members |
| `POST` | `/shop/me/staff` | Add staff member |
| `PUT` | `/shop/me/staff/:id` | Update staff member |
| `DELETE` | `/shop/me/staff/:id` | Remove staff member |
| `GET` | `/shop/me/earnings` | Get earnings summary |
| `GET` | `/shop/me/analytics` | Get shop analytics |
| `GET` | `/shop/me/settlements` | Get settlement history |
| `GET` | `/shop/me/compliance` | Get compliance status |

---

## Admin — Platform Management

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/admin/dashboard` | Get platform dashboard |
| `GET` | `/admin/cities` | List cities |
| `POST` | `/admin/cities` | Create city |
| `PUT` | `/admin/cities/:id` | Update city |
| `DELETE` | `/admin/cities/:id` | Delete city |
| `GET` | `/admin/shop-applications` | List pending shop applications |
| `POST` | `/admin/shop-applications/:id/approve` | Approve shop |
| `POST` | `/admin/shop-applications/:id/reject` | Reject shop |
| `GET` | `/admin/disputes` | List all disputes |
| `PUT` | `/admin/disputes/:id/assign` | Assign mediator |
| `PUT` | `/admin/disputes/:id/resolve` | Resolve dispute |
| `GET` | `/admin/fraud-alerts` | Get fraud alerts |
| `POST` | `/admin/users/:id/flag` | Flag user account |
| `POST` | `/admin/users/:id/blacklist` | Blacklist user |
| `GET` | `/admin/payments` | Monitor payment pipeline |
| `POST` | `/admin/payments/:id/force-refund` | Force refund |
| `GET` | `/admin/trust-config` | Get trust engine config |
| `PUT` | `/admin/trust-config` | Update trust engine config |
| `GET` | `/admin/audit-logs` | Get audit logs |
| `GET` | `/admin/analytics` | Platform analytics |
| `GET` | `/admin/system-health` | System health metrics |
| `GET` | `/admin/feature-flags` | Get feature flags |
| `PUT` | `/admin/feature-flags/:flag` | Toggle feature flag |

---

## WebSocket Events

> **URL**: `wss://ws.alakhservice.com/v1`
> **Auth**: Query param `?token=<jwt>`

### Subscribe to Events

```json
{
  "action": "subscribe",
  "channel": "booking:booking_abc123"
}
```

### Event Types

| Event | Channel | Description |
|-------|---------|-------------|
| `queue.position_updated` | `queue:<shop_id>` | Queue position changed |
| `booking.status_changed` | `booking:<id>` | Booking status updated |
| `booking.dispatched` | `booking:<id>` | Staff dispatched |
| `chat.message_received` | `chat:<shop_id>` | New chat message |
| `payment.verified` | `payment:<id>` | Payment confirmed |
| `fraud.alert_created` | `admin:fraud` | New fraud alert (admin) |
