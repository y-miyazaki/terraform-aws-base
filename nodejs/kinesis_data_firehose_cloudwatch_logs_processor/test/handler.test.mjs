import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";
import * as zlib from "node:zlib";
import { describe, it } from "node:test";

import {
    handler,
    loadJsonGzipBase64,
    processRecords,
    transformLogEvent,
} from "../index.mjs";

const __dirname = path.dirname(fileURLToPath(import.meta.url));

function encodeCloudWatchRecord(payload) {
    return zlib.gzipSync(Buffer.from(JSON.stringify(payload), "utf-8")).toString(
        "base64"
    );
}

describe("transformLogEvent", () => {
    it("appends a newline to the log message", () => {
        assert.equal(
            transformLogEvent({ message: "hello world" }),
            "hello world\n"
        );
    });
});

describe("processRecords", () => {
    it("drops CONTROL_MESSAGE records", () => {
        const records = processRecords([
            {
                recordId: "control-1",
                data: encodeCloudWatchRecord({
                    messageType: "CONTROL_MESSAGE",
                }),
            },
        ]);

        assert.deepEqual(records, [
            {
                result: "Dropped",
                recordId: "control-1",
            },
        ]);
    });

    it("transforms DATA_MESSAGE records", () => {
        const records = processRecords([
            {
                recordId: "data-1",
                data: encodeCloudWatchRecord({
                    messageType: "DATA_MESSAGE",
                    logEvents: [
                        { message: "first line" },
                        { message: "second line" },
                    ],
                }),
            },
        ]);

        assert.equal(records.length, 1);
        assert.equal(records[0].result, "Ok");
        assert.equal(records[0].recordId, "data-1");
        assert.equal(
            Buffer.from(records[0].data, "base64").toString("utf-8"),
            "first line\nsecond line\n"
        );
    });

    it("marks unknown message types as ProcessingFailed", () => {
        const records = processRecords([
            {
                recordId: "unknown-1",
                data: encodeCloudWatchRecord({
                    messageType: "UNKNOWN_MESSAGE",
                }),
            },
        ]);

        assert.deepEqual(records, [
            {
                result: "ProcessingFailed",
                recordId: "unknown-1",
            },
        ]);
    });
});

describe("loadJsonGzipBase64", () => {
    it("decodes gzip-compressed JSON payloads", () => {
        const payload = {
            messageType: "DATA_MESSAGE",
            logEvents: [{ message: "decoded message" }],
        };
        const encoded = encodeCloudWatchRecord(payload);

        assert.deepEqual(loadJsonGzipBase64(encoded), payload);
    });
});

describe("handler", () => {
    it("processes the sample Firehose event without AWS re-ingestion", async () => {
        const event = JSON.parse(
            await readFile(path.join(__dirname, "valid-sample-event.json"), "utf8")
        );

        const response = await handler(event);

        assert.equal(response.records.length, 2);
        assert.equal(
            response.records.filter((record) => record.result === "Ok").length,
            2
        );
    });
});
