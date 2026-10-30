---
appliesTo: "*.go"
type: choice
criteria:
  client-safe: "A stable code and a short message, with the detail kept in logs."
  internal-detail: "Driver or SQL text, a stack trace, an internal hostname, or a file path."
violation:
  if:
    internal-detail: 0.7
---
# Error text returned to clients

Examine the paths that write an error response. If this file contains no code
that writes a response, choose `client-safe`: a wrapped internal error is not a
disclosure when no client sees it.

Choose `internal-detail` when a message returned to a client contains driver or
SQL text, a stack trace, an internal hostname, or a file path. Choose
`client-safe` when the response is a stable code and a short message, with the
detail written to logs instead.
