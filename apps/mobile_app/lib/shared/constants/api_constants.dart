/// API-related constants: headers, content types, and HTTP status codes.
library;

/// Constants used when constructing and interpreting HTTP requests/responses.
abstract final class ApiConstants {
  // ---------------------------------------------------------------------------
  // Headers
  // ---------------------------------------------------------------------------

  /// Standard `Content-Type` header key.
  static const String headerContentType = 'Content-Type';

  /// Standard `Accept` header key.
  static const String headerAccept = 'Accept';

  /// Standard `Authorization` header key.
  static const String headerAuthorization = 'Authorization';

  /// Custom header carrying the device's locale.
  static const String headerAcceptLanguage = 'Accept-Language';

  /// Custom header for the app version (set by the client).
  static const String headerAppVersion = 'X-App-Version';

  /// Custom header for the platform (`android` | `ios`).
  static const String headerPlatform = 'X-Platform';

  /// Custom header for the unique device identifier.
  static const String headerDeviceId = 'X-Device-Id';

  /// Custom header carrying the correlation / trace ID for distributed tracing.
  static const String headerRequestId = 'X-Request-Id';

  // ---------------------------------------------------------------------------
  // Content Types
  // ---------------------------------------------------------------------------

  /// `application/json; charset=utf-8`
  static const String contentTypeJson = 'application/json; charset=utf-8';

  /// `multipart/form-data`
  static const String contentTypeMultipart = 'multipart/form-data';

  /// `application/x-www-form-urlencoded`
  static const String contentTypeFormEncoded =
      'application/x-www-form-urlencoded';

  /// `application/octet-stream` (binary file upload).
  static const String contentTypeOctetStream = 'application/octet-stream';

  // ---------------------------------------------------------------------------
  // HTTP Status Codes — 2xx Success
  // ---------------------------------------------------------------------------

  /// 200 OK
  static const int statusOk = 200;

  /// 201 Created
  static const int statusCreated = 201;

  /// 202 Accepted (async processing)
  static const int statusAccepted = 202;

  /// 204 No Content
  static const int statusNoContent = 204;

  // ---------------------------------------------------------------------------
  // HTTP Status Codes — 3xx Redirection
  // ---------------------------------------------------------------------------

  /// 301 Moved Permanently
  static const int statusMovedPermanently = 301;

  /// 304 Not Modified (used for conditional requests / ETag caching)
  static const int statusNotModified = 304;

  // ---------------------------------------------------------------------------
  // HTTP Status Codes — 4xx Client Errors
  // ---------------------------------------------------------------------------

  /// 400 Bad Request
  static const int statusBadRequest = 400;

  /// 401 Unauthorised
  static const int statusUnauthorised = 401;

  /// 403 Forbidden
  static const int statusForbidden = 403;

  /// 404 Not Found
  static const int statusNotFound = 404;

  /// 409 Conflict
  static const int statusConflict = 409;

  /// 422 Unprocessable Entity
  static const int statusUnprocessableEntity = 422;

  /// 429 Too Many Requests (rate limiting)
  static const int statusTooManyRequests = 429;

  // ---------------------------------------------------------------------------
  // HTTP Status Codes — 5xx Server Errors
  // ---------------------------------------------------------------------------

  /// 500 Internal Server Error
  static const int statusInternalServerError = 500;

  /// 502 Bad Gateway
  static const int statusBadGateway = 502;

  /// 503 Service Unavailable
  static const int statusServiceUnavailable = 503;

  /// 504 Gateway Timeout
  static const int statusGatewayTimeout = 504;

  // ---------------------------------------------------------------------------
  // Pagination query parameters
  // ---------------------------------------------------------------------------

  /// Query parameter name for the page number.
  static const String queryPage = 'page';

  /// Query parameter name for the page size / limit.
  static const String queryLimit = 'limit';

  /// Query parameter name for cursor-based pagination.
  static const String queryCursor = 'cursor';

  /// Query parameter name for free-text search.
  static const String querySearch = 'q';

  // ---------------------------------------------------------------------------
  // Misc
  // ---------------------------------------------------------------------------

  /// Bearer token prefix for the `Authorization` header value.
  static const String bearerPrefix = 'Bearer ';

  /// Timeout (in seconds) after which a multipart upload is aborted.
  static const int uploadTimeoutSeconds = 120;
}
