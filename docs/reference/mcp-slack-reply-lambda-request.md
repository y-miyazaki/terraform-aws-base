# Slack Reply MCP Lambda Request

Request to build a minimal Model Context Protocol (MCP) server as a Lambda function and deliver it as a zip. This repository (`terraform-aws-base`) consumes the zip; the Lambda source lives in another repository.

> **Revision notes**
>
> - **Revision 2 (protocol `2026-07-28` only)**: the first version assumed the `initialize` handshake; revision 2 removed the handshake, protocol-level sessions, and the GET stream, and delivered `go_mcp_slack_reply.zip` (source: `cmd/mcp/mcp_slack_reply/`, module `go-lambda`, built with `scripts/go/build.sh cmd/mcp mcp arm64`).
> - **Revision 3 (this version, additive)**: **support both protocol generations.** AWS DevOps Agent does not document which MCP protocol version it speaks, and it validates the connection with `listTools` at registration. A server that rejects `initialize` would fail that validation. Keep everything delivered in revision 2 and add the legacy path described in [Legacy Protocol Path](#legacy-protocol-path).
> - **Still pending**: the [Related Change: Webhook Sender Lambda](#related-change-webhook-sender-lambda) has not been done yet. It is part of this request.
> - Specification references: <https://modelcontextprotocol.io/specification/2026-07-28/basic/transports/streamable-http>, `.../basic/versioning`, `.../basic/index`, `.../server/discover`, `.../server/tools`, and the `2025-11-25` revision of the same pages.

## Purpose

After AWS DevOps Agent investigates an alarm, it must reply to the original alert message (a Slack thread) with the Issue URL and the error summary, as the same Bot that posts the alerts today.

| Option                                         | Result                                                                                                              |
| ---------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| Slack hosted MCP server (`mcp.slack.com`)      | Rejected. It uses a user-token OAuth flow, so replies are posted under the authorizing user's name                  |
| Third-party self-hosted Slack MCP server       | Rejected. It would receive the Bot token, and its Lambda compatibility (stateless operation) is unverified          |
| Custom minimal MCP server on Lambda (this one) | Selected. The Bot token stays in our code, and the existing alert Lambdas already use the same token (`chat:write`) |

## Scope

- In scope: a stateless Streamable HTTP MCP server for a Lambda function URL, with one tool, answering both the `2026-07-28` protocol and the legacy `initialize`-based protocol (`2025-11-25`).
- Out of scope: search, history reads, new channel posts, reactions, file uploads, direct messages, SSE responses, `subscriptions/listen`, server-initiated messages, and session state of any kind.

## Runtime

| Item         | Value                                                                           |
| ------------ | ------------------------------------------------------------------------------- |
| Language     | Go (same as the existing Lambda functions)                                      |
| Runtime      | `provided.al2023`                                                               |
| Architecture | `arm64`                                                                         |
| Handler      | `bootstrap` (at the zip root)                                                   |
| Source       | `cmd/mcp/mcp_slack_reply/` (+ `README.md` in the same directory)                |
| Deliverable  | `go_mcp_slack_reply.zip` (same naming as the existing `go_*.zip` files)         |
| Invocation   | Lambda function URL, payload format 2.0, IAM authentication (SigV4) is expected |

The function URL IAM authentication is the access control, so the code does not implement its own authentication. The caller needs both `lambda:InvokeFunctionUrl` and `lambda:InvokeFunction`. The channel allowlist below is still mandatory, so a misconfigured URL cannot post to arbitrary channels.

### Environment Variables

| Name                                             | Required | Description                                                                                    |
| ------------------------------------------------ | -------- | ---------------------------------------------------------------------------------------------- |
| `SLACK_OAUTH_ACCESS_TOKEN`                       | Yes      | Bot token (`xoxb-`); same name as the existing Lambda functions                                |
| `SLACK_ALLOWED_CHANNEL_IDS`                      | Yes      | Comma-separated channel IDs that may receive replies; requests for other channels are rejected |
| `LOGGER_FORMATTER`, `LOGGER_OUT`, `LOGGER_LEVEL` | No       | Same names as the existing Lambda functions; defaults `json`, `stdout`, `info`                 |

Never write the token to logs, error messages, or responses.

## MCP Behavior

### Dispatch

Every request is a single `POST` carrying one JSON-RPC 2.0 message. Decide the protocol path per request, with no state shared between requests:

| Condition                                                                | Path                                                            |
| ------------------------------------------------------------------------ | --------------------------------------------------------------- |
| `params._meta` has `io.modelcontextprotocol/protocolVersion`             | `2026-07-28` path (see [HTTP Handling](#http-handling) onwards) |
| `method` is `initialize`, or the request has no `_meta` protocol version | [Legacy Protocol Path](#legacy-protocol-path)                   |

The shared pieces (HTTP method handling, `Origin`, the tool behavior, error handling, and the logging rules) are identical for both paths.

### HTTP Handling

- `POST`: accept one JSON-RPC 2.0 request and respond `200` with `application/json` (no SSE).
- `GET` and `DELETE`: respond `405 Method Not Allowed` (with `Allow: POST`).
- Stateless: do not issue `Mcp-Session-Id`; ignore an incoming `Mcp-Session-Id` and `Last-Event-ID`.
- `Origin`: if an `Origin` header is present, respond `403` (the caller is a server-side agent, not a browser).
- JSON-RPC notifications (no `id`): respond `202 Accepted` with no body.
- JSON-RPC batches (arrays) are not supported; return `-32600` with `400`.
- On the `2026-07-28` path, every result carries `"resultType": "complete"` and `_meta["io.modelcontextprotocol/serverInfo"]`.

### Request Metadata Validation (`2026-07-28` path)

| Check                                                                                                       | Failure                                                                             |
| ----------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------- |
| Body is valid JSON                                                                                          | `400`, `-32700`                                                                     |
| Body is a JSON-RPC 2.0 object with string `method` and string/integer `id` (not `null`)                     | `400`, `-32600`                                                                     |
| `params._meta` has `io.modelcontextprotocol/protocolVersion` (string) and `.../clientCapabilities` (object) | `400`, `-32602`                                                                     |
| `MCP-Protocol-Version` header present and equal to the `_meta` version                                      | `400`, `-32020` (HeaderMismatch)                                                    |
| Protocol version is `2026-07-28`                                                                            | `400`, `-32022` with `data: {"supported": ["2026-07-28", ...], "requested": "<v>"}` |
| `Mcp-Method` header present and equal to `method`                                                           | `400`, `-32020`                                                                     |
| `tools/call`: `Mcp-Name` header present and equal to `params.name` (decode `=?base64?...?=` first)          | `400`, `-32020`                                                                     |

An `initialize` request is **no longer rejected**; it is handled by the legacy path.

### Methods (`2026-07-28` path)

| Method            | Behavior                                                                                                         |
| ----------------- | ---------------------------------------------------------------------------------------------------------------- |
| `server/discover` | Return `supportedVersions: ["2026-07-28"]`, `capabilities` of `{"tools": {}}`, and `serverInfo` in `_meta`       |
| `ping`            | Return an empty result (only `resultType`). Not listed in the `2026-07-28` pages checked; kept for compatibility |
| `tools/list`      | Return the one tool below                                                                                        |
| `tools/call`      | Run the tool below; unknown tool name is `-32602`                                                                |
| Any other method  | `404` with JSON-RPC error `-32601` (Method not found)                                                            |

### Legacy Protocol Path

Purpose: let a client that still sends the `initialize` handshake (revision `2025-11-25`, and `2025-06-18` / `2025-03-26` if the effort is small) register and use the server. This is the likely case for AWS DevOps Agent until it is confirmed otherwise.

Rules (the server stays stateless):

- `initialize`: negotiate the protocol version (return the client's `protocolVersion` when it is `2025-11-25`, `2025-06-18`, or `2025-03-26`; otherwise return `2025-11-25`). Return `capabilities` of `{"tools": {}}` and `serverInfo`. **Do not issue `Mcp-Session-Id`.** Do not require one on later requests, and ignore one if sent.
- `notifications/initialized` and other notifications: `202` with no body.
- `ping`, `tools/list`, `tools/call`: accept without `_meta` metadata and without the `Mcp-Method` / `Mcp-Name` headers. Do not return `resultType` or `serverInfo` in `_meta` (legacy results are plain). If an `MCP-Protocol-Version` header is present, it must be one of the supported legacy versions; otherwise respond `400`. If it is absent, assume `2025-03-26`.
- `tools/list` and `tools/call` behave exactly as in the tool section below, including all validation and Slack handling.
- Unknown methods: `404` with `-32601`. Invalid JSON: `-32700`. Batches: `-32600`.
- Log at `info` the observed path (`legacy` or `2026-07-28`), method, protocol version, and client info (`clientInfo` when present), so the version AWS DevOps Agent actually speaks can be read from CloudWatch Logs.

### Tool: `slack_reply_to_thread`

Replies to an existing thread. `thread_ts` is required, so the tool cannot post a new message to a channel.

| Argument     | Type   | Required | Constraint                                                         |
| ------------ | ------ | -------- | ------------------------------------------------------------------ |
| `channel_id` | string | Yes      | `^[CGD][A-Z0-9]{8,}$`; must be in `SLACK_ALLOWED_CHANNEL_IDS`      |
| `thread_ts`  | string | Yes      | `^[0-9]{10}\.[0-9]{6}$`                                            |
| `text`       | string | Yes      | 1 to 3500 characters; reject longer input instead of truncating it |

Behavior:

1. Validate the arguments (including unknown arguments). Return violations as a tool error result (`isError: true`).
2. Neutralize `<!channel>`, `<!here>`, `<!everyone>` (also the `<!channel|label>` form), `@channel`, `@here`, and `@everyone` (case-insensitive) in `text`, replacing `@` with a full-width `＠`, so agent output cannot notify everyone.
3. Call Slack `chat.postMessage` with `channel`, `thread_ts`, and `text`. `reply_broadcast` is fixed to `false`.
4. On success, return `ok`, `channel`, and `ts` (the posted message) as a JSON string in a text `content` item.

Error handling:

- Slack `ok: false`: include the `error` value (for example `channel_not_found`, `not_in_channel`, `thread_not_found`, `invalid_auth`) in the tool error result. Never include the token.
- HTTP 429: honor `Retry-After` and retry at most twice, within the Lambda timeout.
- Set a timeout on the Slack HTTP request (about 10 seconds).

The `tools/list` JSON Schema must carry the constraints above (`pattern`, `minLength`, `maxLength`, `required`, `additionalProperties: false`).

## Non-Functional Requirements

- Do not log the token or the full `text`; log only its length and the channel ID.
- Keep dependencies minimal (standard library, `aws-lambda-go`, `logrus`, already in `go.mod`); explain any addition in the README.
- Work with 128 MB of memory and a 30-second timeout.
- Do not add other tools or features.

## Test Requirements

Mock the Slack API; do not call the real Slack API in tests. Cover at least:

- `server/discover`, `tools/list`, and `ping` success on the `2026-07-28` path.
- `tools/call`: success, a channel outside the allowlist, a malformed `thread_ts`, empty `text`, `text` over 3500 characters, and mention neutralization.
- Slack returning `ok: false`, a 429 retry, and a timeout.
- `GET` returns 405, an unknown method returns `-32601`, invalid JSON returns `-32700`, a batch returns `-32600`, a notification returns `202`.
- Metadata validation on the `2026-07-28` path: missing/mismatching `MCP-Protocol-Version`, `Mcp-Method`, `Mcp-Name` (`-32020`), missing `_meta` fields (`-32602`), an unsupported version in `_meta` (`-32022`), `Origin` (403), no `Mcp-Session-Id` in responses.
- **Legacy path**: `initialize` with `2025-11-25`, `2025-06-18`, and an unknown version (negotiation); no `Mcp-Session-Id` in the response; `notifications/initialized` returns `202`; `tools/list`, `tools/call`, and `ping` work without `_meta` and without `Mcp-Method` / `Mcp-Name`; an unsupported `MCP-Protocol-Version` header returns `400`; a request with no `_meta` and no `initialize` still works.
- Dispatch: the same tool call returns the same Slack result through both paths.
- Neither the logs nor the responses contain the token; logs do not contain the full `text`; the `info` log records the path, method, and protocol version.

## Acceptance Criteria

1. `go_mcp_slack_reply.zip` runs on Lambda (`provided.al2023`, `arm64`, handler `bootstrap`).
2. Calling the function URL (IAM authentication) with a SigV4 signature returns the expected MCP responses on **both** paths, and a reply in a verification Slack channel is posted under the Bot name.
3. All tests pass.
4. `cmd/mcp/mcp_slack_reply/README.md` documents the build steps, environment variables, the wire format of both paths (required headers, request/response JSON, error codes), the tool specification, and verification commands (including how to sign requests).
5. No secrets appear in the source, test data, or logs.

## Work in This Repository After Delivery

Not part of the request; listed for context.

- Place the zip at `lambda/outputs/go_mcp_slack_reply.zip` and create the Lambda function and the function URL (IAM authentication) with Terraform.
- Create a dedicated IAM role for AWS DevOps Agent that can only invoke this function URL, and register the server in AWS DevOps Agent as an AWS SigV4 MCP server (that role, Region, service name `lambda`). Allowlist only `slack_reply_to_thread`.
- Add the reply procedure to the GitHub and Notion skills: read the channel ID and the thread timestamp from the webhook `description`, then reply with the Issue URL and the error summary.

## Related Change: Webhook Sender Lambda

**Status: not done yet. Please include it in this delivery.**

The Lambda function that sends alarms to the DevOps Agent webhook must include the channel ID and the thread timestamp in `description`. The webhook accepts `data` but does not pass it to the agent; only `title`, `description`, `priority`, and the incident reference reach the agent.

Append one fixed-format line to `description`:

```text
slack_reply_target: channel_id=C0123456789 thread_ts=1700000000.123456
```

- Read `channel` and `ts` from the `chat.postMessage` response of the original alert message.
- Post to Slack first. If the Slack post fails, send the webhook without this line.
- Keep the existing alert content and notification behavior unchanged.
- Keep `incidentId` unique per alarm so that webhook deduplication does not drop events (existing behavior).
- Test both cases: with and without the line.
- Deliver the rebuilt zip of that Lambda under its existing file name in `lambda/outputs/`, and tell us which zip it is (the existing `go_cloudwatch_alarm_to_sns_to_slack.zip` or another).

## Open Questions

- Whether DevOps Agent can call a function URL with IAM authentication (SigV4, service name `lambda`) is not verified. If it cannot, switch to API key (Bearer) authentication and add a token check to the Lambda, or place API Gateway in front.
- Whether DevOps Agent speaks protocol `2026-07-28` or the legacy `initialize` handshake is not verified; the dual-path design above removes the dependency on the answer. The `info` log records what it actually sends.
- Whether a POST to a function URL needs an explicit `x-amz-content-sha256` header, and whether DevOps Agent's SigV4 signer sends it, is not verified (see the README fallback).
- `ping` is kept because the request asked for it, but it is not defined in the `2026-07-28` pages that were checked.
