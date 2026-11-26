import { strict as assert } from "node:assert";
import { test } from "node:test";
import { putRecordsBase, retryDelayMs } from "../index.mjs";

const noSleep = async () => {};
const call = (
    client,
    sleepFn = noSleep,
    maxAttempts = 3,
    deadline = Infinity,
) =>
    putRecordsBase(
        "stream",
        [{ Data: "a" }, { Data: "b" }],
        client,
        "putRecordBatch",
        "DeliveryStreamName",
        "RequestResponses",
        0,
        maxAttempts,
        sleepFn,
        deadline,
    );

test("retryDelayMs: has a floor, grows exponentially and is capped", () => {
    const min = () => 0;
    const max = () => 0.999999;
    assert.equal(retryDelayMs(0, min), 100);
    assert.equal(retryDelayMs(1, min), 200);
    assert.equal(retryDelayMs(2, min), 400);
    assert.ok(retryDelayMs(0, max) < 200);
    assert.ok(retryDelayMs(1, max) < 400);
    // capped at 5000ms: floor 2500, below 5000
    assert.equal(retryDelayMs(19, min), 2500);
    assert.ok(retryDelayMs(19, max) < 5000);
});

test("putRecordsBase: succeeds without sleeping when no record fails", async () => {
    const sleeps = [];
    const client = {
        putRecordBatch: async () => ({ RequestResponses: [{}, {}] }),
    };
    await call(client, async (ms) => sleeps.push(ms));
    assert.equal(sleeps.length, 0);
});

test("putRecordsBase: retries only failed records, with a delay between attempts", async () => {
    const sent = [];
    const sleeps = [];
    const client = {
        putRecordBatch: async ({ Records }) => {
            sent.push(Records.length);
            return {
                RequestResponses:
                    sent.length === 1
                        ? [{ ErrorCode: "ServiceUnavailableException" }, {}]
                        : Records.map(() => ({})),
            };
        },
    };
    await call(client, async (ms) => sleeps.push(ms));
    assert.deepEqual(sent, [2, 1]);
    assert.equal(sleeps.length, 1);
});

test("putRecordsBase: throws after maxAttempts, sleeping between attempts only", async () => {
    let calls = 0;
    const sleeps = [];
    const client = {
        putRecordBatch: async () => {
            calls++;
            return {
                RequestResponses: [
                    { ErrorCode: "ServiceUnavailableException" },
                    {},
                ],
            };
        },
    };
    await assert.rejects(
        call(client, async (ms) => sleeps.push(ms), 3),
        /Could not put records after 3 attempts/,
    );
    assert.equal(calls, 3);
    assert.equal(sleeps.length, 2);
});

test("putRecordsBase: passes the computed backoff to the sleep function", async () => {
    const sleeps = [];
    const client = {
        putRecordBatch: async () => ({
            RequestResponses: [
                { ErrorCode: "ServiceUnavailableException" },
                {},
            ],
        }),
    };
    await assert.rejects(call(client, async (ms) => sleeps.push(ms), 3));
    // attempt 0 -> ceiling 200 -> [100, 200); attempt 1 -> ceiling 400 -> [200, 400)
    assert.ok(sleeps[0] >= 100 && sleeps[0] < 200);
    assert.ok(sleeps[1] >= 200 && sleeps[1] < 400);
});

test("putRecordsBase: retries when the client call throws", async () => {
    let calls = 0;
    const client = {
        putRecordBatch: async () => {
            calls++;
            if (calls === 1) throw new Error("boom");
            return { RequestResponses: [{}, {}] };
        },
    };
    await call(client);
    assert.equal(calls, 2);
});

test("putRecordsBase: fails fast when the next backoff would pass the deadline", async () => {
    let calls = 0;
    const sleeps = [];
    const client = {
        putRecordBatch: async () => {
            calls++;
            return {
                RequestResponses: [
                    { ErrorCode: "ServiceUnavailableException" },
                    {},
                ],
            };
        },
    };
    await assert.rejects(
        call(client, async (ms) => sleeps.push(ms), 20, Date.now() - 1),
        /retry deadline/,
    );
    assert.equal(calls, 1);
    assert.equal(sleeps.length, 0);
});
